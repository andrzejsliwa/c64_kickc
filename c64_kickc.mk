VERBOSE   ?= true

VICE_PATH     ?= /usr/local/bin/x64sc
VICE_OPTS     ?=

DEBUGGER_PATH ?= /Applications/C64\ Debugger.app/Contents/MacOS/C64Debugger
DEBUGGER_OPTS ?= -pass -unpause -autojmp -wait 250

KICKC_HOME          ?= .
KICKC_STDINCLUDE    ?= $(KICKC_HOME)/include
KICKC_STDLIB        ?= $(KICKC_HOME)/lib
KICKC_FRAGMENT_HOME ?= $(KICKC_HOME)/fragment
KICKC_PLATFORM      ?= $(KICKC_HOME)/target
KICKC_JAR           ?= jar/kickc-0.8.4.jar
KICKASS_JAR         ?= jar/KickAss.jar

EXTENSION_ASSEMBLY ?=.asm
EXTENSION_C        ?=.c
EXTENSION_INCLUDES ?=.i
EXTENSION_PROGRAM  ?=.prg

ifdef VERBOSE
    OUTPUT_COMMAND=
	OUTPUT_OPTIONS=
else
	OUTPUT_COMMAND=@
	OUTPUT_OPTIONS= #2>&1 > /dev/null
endif

SOURCE_DIR = src
LIB_DIR    = lib
BUILD_DIR  = build

ASM_FILES = $(wildcard $(BUILD_DIR)/*$(EXTENSION_ASSEMBLY))
ASM_PRGS  = $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_FILES:$(EXTENSION_ASSEMBLY)=$(EXTENSION_PROGRAM))))
ASM_SOURCES  = $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_FILES:$(EXTENSION_ASSEMBLY)=$(EXTENSION_ASSEMBLY))))
C_FILES   = $(wildcard $(SOURCE_DIR)/*$(EXTENSION_C))
C_ASMS  = $(addprefix $(BUILD_DIR)/,$(notdir $(C_FILES:$(EXTENSION_C)=$(EXTENSION_ASSEMBLY))))
C_SOURCES  = $(addprefix $(BUILD_DIR)/,$(notdir $(C_FILES:$(EXTENSION_C)=$(EXTENSION_C))))


all:
	$(OUTPUT_COMMAND)make start $(DEFAULT_PRG)

.PHONY : run_debug

start: clean compile run_vice ## build and start emulator (optionally with name of program)

debug: clean compile run_debug ## build and run in debugger (optionally with name of program)

$(BUILD_DIR):
	$(OUTPUT_COMMAND)mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%$(EXTENSION_ASSEMBLY): $(SOURCE_DIR)/%$(EXTENSION_C)
	$(OUTPUT_COMMAND)java -jar $(KICKC_JAR) \
		-F $(KICKC_FRAGMENT_HOME) \
		$< \
		-I $(KICKC_STDINCLUDE) \
		-odir=$(BUILD_DIR) \
		-L $(KICKC_STDLIB) \
		-P $(KICKC_PLATFORM) \

$(BUILD_DIR)/%$(EXTENSION_PROGRAM): $(BUILD_DIR)/%$(EXTENSION_ASSEMBLY)
	$(OUTPUT_COMMAND)java -jar $(KICKASS_JAR) \
		$< \
		-bytedumpfile ../$@.bytedump \
		-o $@ \
		-afo \
		-aom \
		-showmem \
		-debugdump \
		-symbolfile \
		-symbolfiledir ../$(BUILD_DIR) \

clean: ## clean build directory
	$(OUTPUT_COMMAND)rm -r $(BUILD_DIR) || true

compile: $(BUILD_DIR) $(C_ASMS) $(ASM_PRGS) ## compile KICK C source files (src/*.c)

ifeq (start,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "start"
  START_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn argument to starting config
  ifneq ($(START_ARGS),)
	APP_NAME  := $(firstword $(START_ARGS))
	START_APP := $(DISK):$(APP_NAME)
  endif

  $(eval $(START_ARGS):;@:)
endif

ifeq (run_debug,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "debug"
  DEBUG_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn argument to starting config
  ifneq ($(DEBUG_ARGS),)
	APP_NAME  := $(firstword $(DEBUG_ARGS))
  endif

  $(eval $(DEBUG_ARGS):;@:)
endif

run_vice:
	$(OUTPUT_COMMAND) $(VICE_PATH) $(VICE_OPTS) \
	$(BUILD_DIR)/$(APP_NAME)$(EXTENSION_PROGRAM) 2>&1 $(OUTPUT_OPTIONS) &

run_debug:
	$(OUTPUT_COMMAND)$(DEBUGGER_PATH) \
		-prg $(BUILD_DIR)/$(APP_NAME)$(EXTENSION_PROGRAM) \
		$(DEBUGGER_OPTS) $(OUTPUT_OPTIONS)

define print_help
	grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(1) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-20s\033[0m%s\n", $$1, $$2}'
endef

help:
	@printf "\033[36mHelp: \033[0m\n"
	@$(foreach file, $(MAKEFILE_LIST), $(call print_help, $(file));)


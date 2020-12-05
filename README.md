# c64_kickc.mk

Example project for C64 KickC

## Usage

```bash
*[main][~/game]$ make help
Help:
  make start               build and start emulator (optionally with name of program)
  make debug               build and run in debugger (optionally with name of program)
  make clean               clean build directory
  make compile             compile KICK C source files (src/*.c)
```

Basic Run (compile and execute C64Debugger)
```bash
*[main][~/game]$ make
...
```

Verbose Run (compile and execute C64Debugger)
```bash
*[main][~/game]$ VERBOSE=true make
...
```

Run Specific Prg (compile and execute C64Debugger)
```bash
*[main][~/game]$ make start empty
...
```

## Configuration

In Makefile you can override paths or other configurations (in this case debugger and vice are available in PATH)

```Makefile
DEFAULT_PRG = game
DEBUGGER_PATH = C64Debugger
VICE_PATH     = x64sc

include c64_kickc.mk
```

## Examples

In order to run examples, you need to copy them to src directory
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

Basic Build & Run in Vice
```bash
*[main][~/game]$ make
...
```

Basic Build & Run in C64Debugger
```bash
*[main][~/game]$ make debug
...
```
Verbose Build & Run in Vice
```bash
*[main][~/game]$ VERBOSE=true make
...
```

Build & Run Specific Prg in Vice
```bash
*[main][~/game]$ make start empty
...
```

Build & Run Specific Prg in C64Debugger
```bash
*[main][~/game]$ make debug empty
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
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
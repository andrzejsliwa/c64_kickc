# kickc_rake

Example rake project for KickC

## Prerequires

- install ruby/rake

- install Command Runner extension - https://marketplace.visualstudio.com/items?itemName=edonet.vscode-command-runner

- install Kick Assembler studio extensions - https://marketplace.visualstudio.com/items?itemName=sanmont.kickass-studio

- configure Keyboard shortcut:

```json
    {
        "key": "f6",
        "command": "command-runner.run",
        "args": { "command": "debug file" }
    }
```

- open project in vscode

## Usage

```bash
*[main][~/c64_kickc]$ rake -T
rake clean                 # clean project
rake compile_all           # compile all src/*.(c|asm|bas) programs
rake compile_asm[program]  # assemble all (build|src)/*.s programs
rake compile_bas[program]  # convert all (src)/*.bas
rake compile_c[program]    # compile program
rake debug[program]        # compile & debug program
rake init_project          # initialize project (from level of kickc folder stored in kickc release)
rake list_programs         # list available programs
rake start[program]        # compile & run program
rake start_basic[program]  # convert & run basic program
```

Basic Build & Run in Vice

```bash
*[main][~/c64_kickc]$ rake
...
```

Basic Build & Run in C64Debugger

```bash
*[main][~/c64_kickc]$ rake debug
...
```

Build & Run Specific Prg in Vice

```bash
*[main][~/c64_kickc]$ rake start
...
```

Build & Run Specific Prg in C64Debugger

```bash
*[main][~/c64_kickc]$ rake debug PROGRAM=color_sprites_
...
```

## Links

[Ultimate C64 Memory Map](https://www.pagetable.com/c64ref/c64mem/)
[Basic Encoding with PETCOM](https://www.c64-wiki.com/wiki/PETSCII_Codes_in_Listings)
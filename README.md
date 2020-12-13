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
*[main][~/game]$ rake -T
rake clean                 # clean project
rake compile_all           # compile all src/*.c programs
rake compile_asm[program]  # assemble all build/*.asm programs
rake compile_c[program]    # compile program
rake debug[program]        # compile & debug program
rake init_project          # initialize project (from level of kickc folder stored in kickc release)
rake list_programs         # list available programs
rake start[program]        # compile & run program
```

Basic Build & Run in Vice
```bash
*[main][~/game]$ rake
...
```

Basic Build & Run in C64Debugger
```bash
*[main][~/game]$ rake debug
...
```

Build & Run Specific Prg in Vice
```bash
*[main][~/game]$ rake start
...
```

Build & Run Specific Prg in C64Debugger
```bash
*[main][~/game]$ rake debug PROGRAM=empty
...
```
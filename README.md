# kickc_rake

Example rake project for KickC

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
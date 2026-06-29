# Anvil

Anvil is a register-VM assembly language for writing HTTP backends directly in assembly. The VM exposes core I/O, an embedded KV and table database, JSON building and parsing, and a full HTTP server through a compact syscall table — all implemented in Zig 0.15.2, standard library only. You write `.anvil` source files, the assembler produces `.avb` images, and the runtime executes them in an isolated 1 MiB heap with a 16-register machine.

## Build & run

```sh
zig build          # build the anvil binary
zig build test     # run the full test suite

./zig-out/bin/anvil asm examples/hello.anvil -o hello.avb   # assemble source → image
./zig-out/bin/anvil dis hello.avb                            # disassemble image
./zig-out/bin/anvil run examples/hello.anvil                 # run source directly
./zig-out/bin/anvil run hello.avb                            # run pre-assembled image
```

## ISA overview

Anvil has 16 general-purpose registers `r0`–`r15`; `a0`–`a3` are aliases for `r0`–`r3` (syscall arguments and return value). Instructions include arithmetic (`add`, `sub`, `mul`, `div`, `mod`), logic (`and`, `or`, `xor`, `not`), moves (`mov`, `load`, `store`), control flow (`jmp`, `je`, `jne`, `jlt`, `jle`, `jgt`, `jge`, `call`, `ret`), address loading (`lea`), and `halt` / `syscall`.

Strings are built by word-packing: `store [rX+off], rY` writes an i64 word (8 bytes, little-endian) so the ASCII bytes sit contiguously in the heap buffer.

## Syscall table

### Core (0x00–0x05)

| Hex  | Dec | Name        | Description                                      |
|------|-----|-------------|--------------------------------------------------|
| 0x00 |   0 | `exit`      | `a0` = exit code; halt the VM                    |
| 0x01 |   1 | `print_int` | Print signed decimal of `a0` + newline to stdout |
| 0x02 |   2 | `write`     | Write `a2` bytes from `mem[a1]` to fd `a0`       |
| 0x03 |   3 | `read`      | Read up to `a2` bytes from fd `a0` into `mem[a1]`; `r0` = bytes read |
| 0x04 |   4 | `alloc`     | Allocate `a0` bytes from the bump heap; `r0` = address |
| 0x05 |   5 | `free`      | Release allocation at `a0` (best-effort)          |


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


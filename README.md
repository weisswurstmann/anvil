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

### Database (0x20–0x26)

| Hex  | Dec | Name          | Description                                              |
|------|-----|---------------|----------------------------------------------------------|
| 0x20 |  32 | `db_open`     | Open KV store at path `mem[a0..a0+a1]`; `r0` = 0 or -1  |
| 0x21 |  33 | `db_set`      | Set key `mem[a0..a0+a1]` to value `mem[a2..a2+a3]`       |
| 0x22 |  34 | `db_get`      | Get key into `mem[a2..a2+a3]`; `r0` = full length or -1  |
| 0x23 |  35 | `db_del`      | Delete key `mem[a0..a0+a1]`; `r0` = 0 or -1              |
| 0x24 |  36 | `db_close`    | Close the open KV store                                   |
| 0x25 |  37 | `tbl_insert`  | Insert record into named table; `r0` = new row id or -1  |
| 0x26 |  38 | `tbl_get`     | Retrieve row by id; `r0` = record length or -1            |

### JSON (0x30–0x3A)

| Hex  | Dec | Name            | Description                                               |
|------|-----|-----------------|-----------------------------------------------------------|
| 0x30 |  48 | `json_parse`    | Parse JSON text from `mem[a0..a0+a1]`; `r0` = handle      |
| 0x31 |  49 | `json_stringify`| Serialize handle `a0` into `mem[a1..a1+a2]`; `r0` = length |
| 0x32 |  50 | `json_obj`      | Create empty JSON object; `r0` = handle                   |
| 0x33 |  51 | `json_arr`      | Create empty JSON array; `r0` = handle                    |
| 0x34 |  52 | `json_set`      | Set key (ptr/len in `a1`/`a2`) on object `a0` to val `a3` |
| 0x35 |  53 | `json_push`     | Append value `a1` to array `a0`                           |
| 0x36 |  54 | `json_get`      | Get key (ptr/len in `a1`/`a2`) from object `a0`; `r0` = handle |
| 0x37 |  55 | `json_str`      | Create JSON string from `mem[a0..a0+a1]`; `r0` = handle   |
| 0x38 |  56 | `json_num`      | Create JSON number from integer `a0`; `r0` = handle        |
| 0x39 |  57 | `json_get_num`  | Extract i64 value from number handle `a0`; `r0` = value    |
| 0x3A |  58 | `json_get_str`  | Copy string from handle `a0` into `mem[a1..a1+a2]`; `r0` = length |

### HTTP (0x40–0x48)

| Hex  | Dec | Name           | Description                                                   |
|------|-----|----------------|---------------------------------------------------------------|
| 0x40 |  64 | `http_serve`   | Bind port `a0` (0 = ephemeral), enter accept loop with handler at `a1`; re-enters handler per request; `r0` = 0 on stop |
| 0x41 |  65 | `http_method`  | `r0` = method code (0=GET 1=POST 2=PUT 3=DELETE 4=PATCH 5=HEAD 6=other) |
| 0x42 |  66 | `http_path`    | Copy request path into `mem[a0..a0+a1]`; `r0` = full path length |
| 0x43 |  67 | `http_body`    | Copy request body into `mem[a0..a0+a1]`; `r0` = full body length |
| 0x44 |  68 | `http_header`  | Look up request header name at `mem[a0..a0+a1]`; `r0` = value length or -1 |
| 0x45 |  69 | `resp_status`  | Set response status code to `a0` (default 200)                |
| 0x46 |  70 | `resp_header`  | Append response header (name at `a0`/`a1`, value at `a2`/`a3`) |
| 0x47 |  71 | `resp_body`    | Set response body from `mem[a0..a0+a1]`                       |
| 0x48 |  72 | `http_stop`    | Signal the serve loop to stop after this request               |


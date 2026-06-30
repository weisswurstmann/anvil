const std = @import("std");
const Token = @import("token.zig").Token;
const Kind = @import("token.zig").Kind;

test "tokenize mov instruction" {
    const toks = try tokenize(std.testing.allocator, "mov r0, 42\n");
    defer std.testing.allocator.free(toks);
    try std.testing.expectEqual(Kind.ident, toks[0].kind);
    try std.testing.expectEqualStrings("mov", toks[0].text);
    try std.testing.expectEqual(Kind.reg, toks[1].kind);
    try std.testing.expectEqualStrings("r0", toks[1].text);
    try std.testing.expectEqual(Kind.comma, toks[2].kind);
    try std.testing.expectEqual(Kind.number, toks[3].kind);
    try std.testing.expectEqualStrings("42", toks[3].text);
    try std.testing.expectEqual(Kind.newline, toks[4].kind);
    try std.testing.expectEqual(Kind.eof, toks[5].kind);
}


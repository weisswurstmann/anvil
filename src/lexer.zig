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

test "comments and labels" {
    const toks = try tokenize(std.testing.allocator, "_start:  ; go\n.text\n");
    defer std.testing.allocator.free(toks);
    try std.testing.expectEqual(Kind.label_colon, toks[0].kind);
    try std.testing.expectEqualStrings("_start", toks[0].text);
    try std.testing.expectEqual(Kind.newline, toks[1].kind);
    try std.testing.expectEqual(Kind.directive, toks[2].kind);
    try std.testing.expectEqualStrings(".text", toks[2].text);
}

test "negative number literal" {
    const toks = try tokenize(std.testing.allocator, "mov r0, -5\n");
    defer std.testing.allocator.free(toks);
    try std.testing.expectEqual(Kind.number, toks[3].kind);
    try std.testing.expectEqualStrings("-5", toks[3].text);
}
test "minus then non-digit is not a number" {
    // a bare '-' (no digit after) must NOT become a number token
    const toks = try tokenize(std.testing.allocator, "mov r0, - 5\n");
    defer std.testing.allocator.free(toks);
    // toks[3] should be the number 5 (the lone '-' is skipped as today)
    try std.testing.expectEqual(Kind.number, toks[3].kind);
    try std.testing.expectEqualStrings("5", toks[3].text);
}

pub fn tokenize(alloc: std.mem.Allocator, src: []const u8) ![]Token {
    var list = std.ArrayList(Token){};
    errdefer list.deinit(alloc);

    var i: usize = 0;
    var line: u32 = 1;



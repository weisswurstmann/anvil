pub const Kind = enum {
    ident,
    number,
    reg,
    str,
    directive,
    label_colon,
    comma,
    lbracket,
    rbracket,
    plus,
    newline,
    eof,
};

pub const Token = struct {
    kind: Kind,
    text: []const u8,
    line: u32,
};

const std = @import("std");
test "token holds kind/text/line" {
    const t = Token{ .kind = .ident, .text = "mov", .line = 3 };
    try std.testing.expectEqual(Kind.ident, t.kind);
    try std.testing.expectEqualStrings("mov", t.text);
    try std.testing.expectEqual(@as(u32, 3), t.line);
}

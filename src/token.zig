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



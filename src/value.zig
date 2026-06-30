const std = @import("std");

pub const Word = i64;
pub const Flags = struct { zero: bool = false, sign: bool = false };
pub const Regs = struct {
    r: [16]Word = [_]Word{0} ** 16,
    pub fn get(self: Regs, i: u8) Word {
        return self.r[i];
    }
    pub fn set(self: *Regs, i: u8, v: Word) void {
        self.r[i] = v;
    }
};

test "regs get/set and flags default" {
    var regs = Regs{};
    try std.testing.expectEqual(@as(Word, 0), regs.get(3));
    regs.set(3, -7);
    try std.testing.expectEqual(@as(Word, -7), regs.get(3));
    const f = Flags{};
    try std.testing.expect(!f.zero and !f.sign);
}

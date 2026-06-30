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


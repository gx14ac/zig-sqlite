const std = @import("std");
pub const c = @import("c.zig").c;

pub const DB = struct {
    const self = @This();

    pub const File = [:0]const u8;

    pub fn init() !void {}
};

pub fn main() !void {}

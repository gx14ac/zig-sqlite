const std = @import("std");
const sqlite = @import("sqlite");
pub const c = @import("../c.zig").c;

pub export fn main() callconv(.C) void {
    zigMain() catch unreachable;
}

pub fn zigMain() !void {
    std.debug.print("starting fuzz..\n", .{});
    var db = try sqlite.DB.init(":memory", c.SQLITE_OPEN_CREATE);
    defer db.deinit();
}

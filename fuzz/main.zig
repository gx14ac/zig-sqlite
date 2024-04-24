const std = @import("std");
const sqlite = @import("sqlite");

pub export fn main() callconv(.C) void {
    zigMain() catch unreachable;
}

pub fn zigMain() !void {
    std.debug.print("starting fuzz..\n", .{});
    var db = try sqlite.DB.init("test.db");
    defer db.deinit();
}

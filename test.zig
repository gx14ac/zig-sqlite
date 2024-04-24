const std = @import("std");
const build_options = @import("build_options");
const mem = std.mem;
const testing = std.testing;

const DB = @import("sqlite.zig").DB;

pub fn testDB() !DB {}

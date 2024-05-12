const std = @import("std");
const build_options = @import("build_options");
const mem = std.mem;
const testing = std.testing;
pub const c = @import("c.zig").c;

const Sqlite = @import("sqlite.zig").Sqlite;

fn testDB() Sqlite {
    var db = Sqlite.init("test.sqlite", c.SQLITE_OPEN_CREATE) catch unreachable;
    db.exec(
        \\
        \\	create table test (
        \\		id integer primary key not null,
        \\		cint integer not null default(0),
        \\		cintn integer null,
        \\		creal real not null default(0.0),
        \\		crealn real null,
        \\		ctext text not null default(''),
        \\		ctextn text null,
        \\		cblob blob not null default(''),
        \\		cblobn blob null,
        \\		uniq int unique null
        \\	)
    ) catch unreachable;
    return db;
}

test "test db" {
    var conn = testDB();
    defer conn.deinit();
}

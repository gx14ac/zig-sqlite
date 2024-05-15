const std = @import("std");
const build_options = @import("build_options");
const mem = std.mem;
const testing = std.testing;
pub const c = @import("c.zig").c;
const t = std.testing;

const Sqlite = @import("sqlite.zig").Sqlite;

fn testDB() Sqlite {
    var db = Sqlite.init("test.sqlite", c.SQLITE_OPEN_CREATE) catch unreachable;
    db.execNoArgs(
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

test "test exec" {
    const conn = testDB();
    defer conn.close();

    conn.exec(
        \\
        \\	insert into test (cint, creal, ctext, cblob)
        \\	values (?1, ?2, ?3, ?4)
    , .{ -3, 2.2, "three", "four" }) catch unreachable;

    try t.expectEqual(@as(usize, 1), conn.changes());
}

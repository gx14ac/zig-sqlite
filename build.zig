const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const c_flags = &[_][]const u8{"-std=c99"};

    // linking sqlite c library
    const sqlite_lib = b.addStaticLibrary(.{
        .name = "sqlite",
        .target = target,
        .optimize = optimize,
    });

    sqlite_lib.addIncludePath(.{ .path = "c/" });
    sqlite_lib.addCSourceFiles(.{
        .files = &[_][]const u8{
            "c/sqlite3.c",
            "c/workaround.c",
        },
        .flags = c_flags,
    });
    sqlite_lib.linkLibC();
    sqlite_lib.installHeader(.{ .path = "c/sqlite3.h" }, "sqlite3.h");

    b.installArtifact(sqlite_lib);

    // create sqlite module
    const sqlite_mod = b.addModule("sqlite", .{
        .root_source_file = .{ .path = "sqlite.zig" },
        .link_libc = true,
    });
    sqlite_mod.addIncludePath(.{ .path = "c/" });
    sqlite_mod.linkLibrary(sqlite_lib);
}

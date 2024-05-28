const std = @import("std");
const ResolvedTarget = std.Build.ResolvedTarget;

fn getTarget(original_target: ResolvedTarget, bundled: bool) ResolvedTarget {
    if (bundled) {
        var tmp = original_target;

        if (tmp.result.isGnuLibC()) {
            const min_glibc_version = std.SemanticVersion{
                .major = 2,
                .minor = 28,
                .patch = 0,
            };
            const ver = tmp.result.os.version_range.linux.glibc;
            if (ver.order(min_glibc_version) == .lt) {
                std.debug.panic("sqlite requires glibc version >= 2.28", .{});
            }
        }

        return tmp;
    }

    return original_target;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const c_flags = &[_][]const u8{"-std=c99"};

    // linking sqlite c library for main package
    //
    const sqlite_lib = b.addStaticLibrary(.{
        .name = "sqlite",
        .target = target,
        .optimize = optimize,
    });

    sqlite_lib.addIncludePath(b.path("c/"));
    sqlite_lib.addCSourceFiles(.{
        .files = &[_][]const u8{
            "c/sqlite3.c",
            "c/workaround.c",
        },
        .flags = c_flags,
    });
    sqlite_lib.linkLibC();
    sqlite_lib.installHeader(b.path("c/sqlite3.h"), "sqlite3.h");

    b.installArtifact(sqlite_lib);

    // create sqlite module
    const sqlite_mod = b.addModule("sqlite", .{
        .root_source_file = b.path("sqlite.zig"),
        .link_libc = true,
    });
    sqlite_mod.addIncludePath(b.path("c/"));
    sqlite_mod.linkLibrary(sqlite_lib);

    // main test
    //
    const lib_test = b.addTest(.{
        .root_source_file = b.path("test.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_test.addCSourceFile(.{ .file = b.path("c/sqlite3.c"), .flags = c_flags });
    lib_test.addIncludePath(b.path("c"));
    lib_test.linkLibC();

    const lib_run_test = b.addRunArtifact(lib_test);
    lib_run_test.has_side_effects = true;

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&lib_run_test.step);
}

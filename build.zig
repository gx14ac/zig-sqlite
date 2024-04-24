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

    // fuzzing
    //
    const lib = b.addStaticLibrary(.{
        .name = "sqlite",
        .target = getTarget(target, true),
        .optimize = optimize,
    });
    lib.addCSourceFile(.{ .file = .{ .path = "c/sqlite3.c" }, .flags = c_flags });
    lib.addIncludePath(.{ .path = "c" });
    lib.linkLibC();

    const fuzz_compile_run = b.step("fuzz", "Build executable for fuzz testing using afl-clang-lto");

    // configure executable path
    const fuzz_debug_exe = b.addExecutable(.{
        .name = "fuzz-debug",
        .root_source_file = .{ .path = "fuzz/main.zig" },
        .target = getTarget(target, true),
        .optimize = optimize,
    });
    fuzz_debug_exe.addIncludePath(.{ .path = "c" });
    fuzz_debug_exe.linkLibrary(lib);
    fuzz_debug_exe.root_module.addImport("sqlite", sqlite_mod);
    const install_fuzz_debug_exe = b.addInstallArtifact(fuzz_debug_exe, .{});
    fuzz_compile_run.dependOn(&install_fuzz_debug_exe.step);
}

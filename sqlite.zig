const std = @import("std");
pub const c = @import("c.zig").c;
const mem = std.mem;
const versionGreaterThanOrEqualTo = @import("c.zig").versionGreaterThanOrEqualTo;

// sqlite errors
//
pub const SQLiteExtendedIOError = error{
    SQLiteIOErrRead,
    SQLiteIOErrShortRead,
    SQLiteIOErrWrite,
    SQLiteIOErrFsync,
    SQLiteIOErrDirFsync,
    SQLiteIOErrTruncate,
    SQLiteIOErrFstat,
    SQLiteIOErrUnlock,
    SQLiteIOErrRDLock,
    SQLiteIOErrDelete,
    SQLiteIOErrBlocked,
    SQLiteIOErrNoMem,
    SQLiteIOErrAccess,
    SQLiteIOErrCheckReservedLock,
    SQLiteIOErrLock,
    SQLiteIOErrClose,
    SQLiteIOErrDirClose,
    SQLiteIOErrSHMOpen,
    SQLiteIOErrSHMSize,
    SQLiteIOErrSHMLock,
    SQLiteIOErrSHMMap,
    SQLiteIOErrSeek,
    SQLiteIOErrDeleteNoEnt,
    SQLiteIOErrMmap,
    SQLiteIOErrGetTempPath,
    SQLiteIOErrConvPath,
    SQLiteIOErrVnode,
    SQLiteIOErrAuth,
    SQLiteIOErrBeginAtomic,
    SQLiteIOErrCommitAtomic,
    SQLiteIOErrRollbackAtomic,
    SQLiteIOErrData,
    SQLiteIOErrCorruptFS,
};

pub const SQLiteExtendedCantOpenError = error{
    SQLiteCantOpenNoTempDir,
    SQLiteCantOpenIsDir,
    SQLiteCantOpenFullPath,
    SQLiteCantOpenConvPath,
    SQLiteCantOpenDirtyWAL,
    SQLiteCantOpenSymlink,
};

pub const SQLiteExtendedReadOnlyError = error{
    SQLiteReadOnlyRecovery,
    SQLiteReadOnlyCantLock,
    SQLiteReadOnlyRollback,
    SQLiteReadOnlyDBMoved,
    SQLiteReadOnlyCantInit,
    SQLiteReadOnlyDirectory,
};

pub const SQLiteExtendedConstraintError = error{
    SQLiteConstraintCheck,
    SQLiteConstraintCommitHook,
    SQLiteConstraintForeignKey,
    SQLiteConstraintFunction,
    SQLiteConstraintNotNull,
    SQLiteConstraintPrimaryKey,
    SQLiteConstraintTrigger,
    SQLiteConstraintUnique,
    SQLiteConstraintVTab,
    SQLiteConstraintRowID,
    SQLiteConstraintPinned,
};

pub const SQLiteExtendedError = error{
    SQLiteErrorMissingCollSeq,
    SQLiteErrorRetry,
    SQLiteErrorSnapshot,

    SQLiteLockedSharedCache,
    SQLiteLockedVTab,

    SQLiteBusyRecovery,
    SQLiteBusySnapshot,
    SQLiteBusyTimeout,

    SQLiteCorruptVTab,
    SQLiteCorruptSequence,
    SQLiteCorruptIndex,

    SQLiteAbortRollback,
};

pub const SQLiteError = error{
    SQLiteError,
    SQLiteInternal,
    SQLitePerm,
    SQLiteAbort,
    SQLiteBusy,
    SQLiteLocked,
    SQLiteNoMem,
    SQLiteReadOnly,
    SQLiteInterrupt,
    SQLiteIOErr,
    SQLiteCorrupt,
    SQLiteNotFound,
    SQLiteFull,
    SQLiteCantOpen,
    SQLiteProtocol,
    SQLiteEmpty,
    SQLiteSchema,
    SQLiteTooBig,
    SQLiteConstraint,
    SQLiteMismatch,
    SQLiteMisuse,
    SQLiteNoLFS,
    SQLiteAuth,
    SQLiteRange,
    SQLiteNotADatabase,
    SQLiteNotice,
    SQLiteWarning,
};

pub const Error = SQLiteError ||
    SQLiteExtendedError ||
    SQLiteExtendedIOError ||
    SQLiteExtendedCantOpenError ||
    SQLiteExtendedReadOnlyError ||
    SQLiteExtendedConstraintError;

pub fn errorFromResultCode(code: c_int) Error {
    // These errors are only available since 3.22.0.
    if (comptime versionGreaterThanOrEqualTo(3, 22, 0)) {
        switch (code) {
            c.SQLITE_ERROR_MISSING_COLLSEQ => return error.SQLiteErrorMissingCollSeq,
            c.SQLITE_ERROR_RETRY => return error.SQLiteErrorRetry,
            c.SQLITE_READONLY_CANTINIT => return error.SQLiteReadOnlyCantInit,
            c.SQLITE_READONLY_DIRECTORY => return error.SQLiteReadOnlyDirectory,
            else => {},
        }
    }

    // These errors are only available since 3.25.0.
    if (comptime versionGreaterThanOrEqualTo(3, 25, 0)) {
        switch (code) {
            c.SQLITE_ERROR_SNAPSHOT => return error.SQLiteErrorSnapshot,
            c.SQLITE_LOCKED_VTAB => return error.SQLiteLockedVTab,
            c.SQLITE_CANTOPEN_DIRTYWAL => return error.SQLiteCantOpenDirtyWAL,
            c.SQLITE_CORRUPT_SEQUENCE => return error.SQLiteCorruptSequence,
            else => {},
        }
    }
    // These errors are only available since 3.31.0.
    if (comptime versionGreaterThanOrEqualTo(3, 31, 0)) {
        switch (code) {
            c.SQLITE_CANTOPEN_SYMLINK => return error.SQLiteCantOpenSymlink,
            c.SQLITE_CONSTRAINT_PINNED => return error.SQLiteConstraintPinned,
            else => {},
        }
    }
    // These errors are only available since 3.32.0.
    if (comptime versionGreaterThanOrEqualTo(3, 32, 0)) {
        switch (code) {
            c.SQLITE_IOERR_DATA => return error.SQLiteIOErrData, // See https://sqlite.org/cksumvfs.html
            c.SQLITE_BUSY_TIMEOUT => return error.SQLiteBusyTimeout,
            c.SQLITE_CORRUPT_INDEX => return error.SQLiteCorruptIndex,
            else => {},
        }
    }
    // These errors are only available since 3.34.0.
    if (comptime versionGreaterThanOrEqualTo(3, 34, 0)) {
        switch (code) {
            c.SQLITE_IOERR_CORRUPTFS => return error.SQLiteIOErrCorruptFS,
            else => {},
        }
    }

    switch (code) {
        c.SQLITE_ERROR => return error.SQLiteError,
        c.SQLITE_INTERNAL => return error.SQLiteInternal,
        c.SQLITE_PERM => return error.SQLitePerm,
        c.SQLITE_ABORT => return error.SQLiteAbort,
        c.SQLITE_BUSY => return error.SQLiteBusy,
        c.SQLITE_LOCKED => return error.SQLiteLocked,
        c.SQLITE_NOMEM => return error.SQLiteNoMem,
        c.SQLITE_READONLY => return error.SQLiteReadOnly,
        c.SQLITE_INTERRUPT => return error.SQLiteInterrupt,
        c.SQLITE_IOERR => return error.SQLiteIOErr,
        c.SQLITE_CORRUPT => return error.SQLiteCorrupt,
        c.SQLITE_NOTFOUND => return error.SQLiteNotFound,
        c.SQLITE_FULL => return error.SQLiteFull,
        c.SQLITE_CANTOPEN => return error.SQLiteCantOpen,
        c.SQLITE_PROTOCOL => return error.SQLiteProtocol,
        c.SQLITE_EMPTY => return error.SQLiteEmpty,
        c.SQLITE_SCHEMA => return error.SQLiteSchema,
        c.SQLITE_TOOBIG => return error.SQLiteTooBig,
        c.SQLITE_CONSTRAINT => return error.SQLiteConstraint,
        c.SQLITE_MISMATCH => return error.SQLiteMismatch,
        c.SQLITE_MISUSE => return error.SQLiteMisuse,
        c.SQLITE_NOLFS => return error.SQLiteNoLFS,
        c.SQLITE_AUTH => return error.SQLiteAuth,
        c.SQLITE_RANGE => return error.SQLiteRange,
        c.SQLITE_NOTADB => return error.SQLiteNotADatabase,
        c.SQLITE_NOTICE => return error.SQLiteNotice,
        c.SQLITE_WARNING => return error.SQLiteWarning,

        c.SQLITE_IOERR_READ => return error.SQLiteIOErrRead,
        c.SQLITE_IOERR_SHORT_READ => return error.SQLiteIOErrShortRead,
        c.SQLITE_IOERR_WRITE => return error.SQLiteIOErrWrite,
        c.SQLITE_IOERR_FSYNC => return error.SQLiteIOErrFsync,
        c.SQLITE_IOERR_DIR_FSYNC => return error.SQLiteIOErrDirFsync,
        c.SQLITE_IOERR_TRUNCATE => return error.SQLiteIOErrTruncate,
        c.SQLITE_IOERR_FSTAT => return error.SQLiteIOErrFstat,
        c.SQLITE_IOERR_UNLOCK => return error.SQLiteIOErrUnlock,
        c.SQLITE_IOERR_RDLOCK => return error.SQLiteIOErrRDLock,
        c.SQLITE_IOERR_DELETE => return error.SQLiteIOErrDelete,
        c.SQLITE_IOERR_BLOCKED => return error.SQLiteIOErrBlocked,
        c.SQLITE_IOERR_NOMEM => return error.SQLiteIOErrNoMem,
        c.SQLITE_IOERR_ACCESS => return error.SQLiteIOErrAccess,
        c.SQLITE_IOERR_CHECKRESERVEDLOCK => return error.SQLiteIOErrCheckReservedLock,
        c.SQLITE_IOERR_LOCK => return error.SQLiteIOErrLock,
        c.SQLITE_IOERR_CLOSE => return error.SQLiteIOErrClose,
        c.SQLITE_IOERR_DIR_CLOSE => return error.SQLiteIOErrDirClose,
        c.SQLITE_IOERR_SHMOPEN => return error.SQLiteIOErrSHMOpen,
        c.SQLITE_IOERR_SHMSIZE => return error.SQLiteIOErrSHMSize,
        c.SQLITE_IOERR_SHMLOCK => return error.SQLiteIOErrSHMLock,
        c.SQLITE_IOERR_SHMMAP => return error.SQLiteIOErrSHMMap,
        c.SQLITE_IOERR_SEEK => return error.SQLiteIOErrSeek,
        c.SQLITE_IOERR_DELETE_NOENT => return error.SQLiteIOErrDeleteNoEnt,
        c.SQLITE_IOERR_MMAP => return error.SQLiteIOErrMmap,
        c.SQLITE_IOERR_GETTEMPPATH => return error.SQLiteIOErrGetTempPath,
        c.SQLITE_IOERR_CONVPATH => return error.SQLiteIOErrConvPath,
        c.SQLITE_IOERR_VNODE => return error.SQLiteIOErrVnode,
        c.SQLITE_IOERR_AUTH => return error.SQLiteIOErrAuth,
        c.SQLITE_IOERR_BEGIN_ATOMIC => return error.SQLiteIOErrBeginAtomic,
        c.SQLITE_IOERR_COMMIT_ATOMIC => return error.SQLiteIOErrCommitAtomic,
        c.SQLITE_IOERR_ROLLBACK_ATOMIC => return error.SQLiteIOErrRollbackAtomic,

        c.SQLITE_LOCKED_SHAREDCACHE => return error.SQLiteLockedSharedCache,

        c.SQLITE_BUSY_RECOVERY => return error.SQLiteBusyRecovery,
        c.SQLITE_BUSY_SNAPSHOT => return error.SQLiteBusySnapshot,

        c.SQLITE_CANTOPEN_NOTEMPDIR => return error.SQLiteCantOpenNoTempDir,
        c.SQLITE_CANTOPEN_ISDIR => return error.SQLiteCantOpenIsDir,
        c.SQLITE_CANTOPEN_FULLPATH => return error.SQLiteCantOpenFullPath,
        c.SQLITE_CANTOPEN_CONVPATH => return error.SQLiteCantOpenConvPath,

        c.SQLITE_CORRUPT_VTAB => return error.SQLiteCorruptVTab,

        c.SQLITE_READONLY_RECOVERY => return error.SQLiteReadOnlyRecovery,
        c.SQLITE_READONLY_CANTLOCK => return error.SQLiteReadOnlyCantLock,
        c.SQLITE_READONLY_ROLLBACK => return error.SQLiteReadOnlyRollback,
        c.SQLITE_READONLY_DBMOVED => return error.SQLiteReadOnlyDBMoved,

        c.SQLITE_ABORT_ROLLBACK => return error.SQLiteAbortRollback,

        c.SQLITE_CONSTRAINT_CHECK => return error.SQLiteConstraintCheck,
        c.SQLITE_CONSTRAINT_COMMITHOOK => return error.SQLiteConstraintCommitHook,
        c.SQLITE_CONSTRAINT_FOREIGNKEY => return error.SQLiteConstraintForeignKey,
        c.SQLITE_CONSTRAINT_FUNCTION => return error.SQLiteConstraintFunction,
        c.SQLITE_CONSTRAINT_NOTNULL => return error.SQLiteConstraintNotNull,
        c.SQLITE_CONSTRAINT_PRIMARYKEY => return error.SQLiteConstraintPrimaryKey,
        c.SQLITE_CONSTRAINT_TRIGGER => return error.SQLiteConstraintTrigger,
        c.SQLITE_CONSTRAINT_UNIQUE => return error.SQLiteConstraintUnique,
        c.SQLITE_CONSTRAINT_VTAB => return error.SQLiteConstraintVTab,
        c.SQLITE_CONSTRAINT_ROWID => return error.SQLiteConstraintRowID,

        else => std.debug.panic("invalid result code {}", .{code}),
    }
}

pub const Blob = struct {
    value: []const u8,
};

pub const Sqlite = struct {
    const Self = @This();

    conn: *c.sqlite3,

    pub fn init(file: []const u8, flags: c_int) !Self {
        var full_flags = flags;
        if (flags & c.SQLITE_OPEN_READONLY != c.SQLITE_OPEN_READONLY) {
            full_flags |= c.SQLITE_OPEN_READWRITE;
        }

        var conn: ?*c.sqlite3 = null;
        const result = c.sqlite3_open_v2(file.ptr, &conn, full_flags, null);
        if (result != c.SQLITE_OK) {
            return errorFromResultCode(result);
        }

        return Self{ .conn = conn.? };
    }

    pub fn close(self: Self) void {
        _ = c.sqlite3_close_v2(self.conn);
    }

    pub fn prepare(self: Self, sql: []const u8, values: anytype) !Statement {
        var n_stmt: ?*c.sqlite3_stmt = null;
        const result = c.sqlite3_prepare_v2(self.conn, sql.ptr, @intCast(sql.len), &n_stmt, null);
        if (result != c.SQLITE_OK) {
            return errorFromResultCode(result);
        }

        const stmt = n_stmt.?;
        if (values.len > 0) {
            inline for (values, 0..) |value, i| {
                try bindValue(@TypeOf(value), stmt, value, i + 1);
            }
        }

        return .{
            .stmt = stmt,
            .conn = self.conn,
        };
    }

    pub fn execNoArgs(self: Self, sql: [*:0]const u8) !void {
        const result = c.sqlite3_exec(self.conn, sql, null, null, null);
        if (result != c.SQLITE_OK) {
            return errorFromResultCode(result);
        }
    }

    pub fn exec(self: Self, sql: []const u8, values: anytype) !void {
        const stmt = try self.prepare(sql, values);
        defer stmt.deinit();
        try stmt.stepToCompletion();
    }

    pub fn changes(self: Self) usize {
        return @intCast(c.sqlite3_changes(self.conn));
    }
};

fn bindValue(comptime T: type, stmt: *c.sqlite3_stmt, value: anytype, bind_index: c_int) !void {
    var rc: c_int = 0;

    switch (@typeInfo(T)) {
        .Null => rc = c.sqlite3_bind_null(stmt, bind_index),
        .Int, .ComptimeInt => rc = c.sqlite3_bind_int64(stmt, bind_index, @intCast(value)),
        .Float, .ComptimeFloat => rc = c.sqlite3_bind_double(stmt, bind_index, value),
        .Bool => {
            if (value) {
                rc = c.sqlite3_bind_int64(stmt, bind_index, @intCast(1));
            } else {
                rc = c.sqlite3_bind_int64(stmt, bind_index, @intCast(0));
            }
        },
        .Pointer => |ptr| {
            switch (ptr.size) {
                .One => switch (@typeInfo(ptr.child)) {
                    .Array => |arr| {
                        if (arr.child == u8) {
                            rc = c.sqlite3_bind_text(stmt, bind_index, value.ptr, @intCast(value.len), c.SQLITE_STATIC);
                        } else {
                            bindError(T);
                        }
                    },
                    else => bindError(T),
                },
                .Slice => switch (ptr.child) {
                    u8 => rc = c.sqlite3_bind_text(stmt, bind_index, value.ptr, @intCast(value.len), c.SQLITE_STATIC),
                    else => bindError(T),
                },
                else => bindError(T),
            }
        },
        .Array => return bindValue(@TypeOf(&value), stmt, &value, bind_index),
        .Optional => |opt| {
            if (value) |v| {
                return bindValue(opt.child, stmt, v, bind_index);
            } else {
                rc = c.sqlite3_bind_null(stmt, bind_index);
            }
        },
        .Struct => {
            if (T == Blob) {
                const inner = value.value;
                rc = c.sqlite3_bind_blob(stmt, bind_index, @ptrCast(inner), @intCast(inner.len), c.SQLITE_STATIC);
            } else {
                bindError(T);
            }
        },
        else => bindError(T),
    }

    if (rc != c.SQLITE_OK) {
        return errorFromResultCode(rc);
    }
}

fn bindError(comptime T: type) void {
    @compileError("cannot bind value of type " ++ @typeName(T));
}

// `Statement`
// An interface for database manipulation that provides the ability to bind parameters
// before compiling SQL statements and submitting them to the database.
// Specific values in a query can be set as parameters. Parameters are set to values at runtime.
pub const Statement = struct {
    const Self = @This();

    conn: *c.sqlite3,
    stmt: *c.sqlite3_stmt,

    pub fn deinit(self: Self) void {
        _ = c.sqlite3_finalize(self.stmt);
    }

    pub fn stepToCompletion(self: Self) !void {
        const stmt = self.stmt;
        while (true) {
            switch (c.sqlite3_step(stmt)) {
                c.SQLITE_DONE => return,
                c.SQLITE_ROW => continue,
                else => |result| return errorFromResultCode(result),
            }
        }
    }
};

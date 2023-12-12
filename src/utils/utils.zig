const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const ascii = std.ascii;
const fmt = std.fmt;
const fs = std.fs;
const print = std.debug.print;

pub fn getNumbersFromSlise(comptime T: type, slice: []const u8, allocator: Allocator) !ArrayList(T) {
    var result = ArrayList(T).init(allocator);
    var start: i32 = -1;
    for (slice, 0..) |c, i| {
        if (ascii.isDigit(c) or c == '-') {
            if (start == -1) start = @intCast(i);
        } else {
            if (start != -1) {
                if (slice[i - 1] == '-') {
                    start = -1;
                    continue;
                }
                const n = try fmt.parseInt(T, slice[@intCast(start)..i], 10);
                try result.append(n);
                start = -1;
            }
        }
    }
    if (start != -1) {
        const n = try fmt.parseInt(T, slice[@intCast(start)..slice.len], 10);
        try result.append(n);
        start = -1;
    }

    return result;
}

test "getNumbersFromSlise" {
    var simple = "1,2,3";
    const res1 = try getNumbersFromSlise(u8, simple, std.testing.allocator);
    defer res1.deinit();
    try std.testing.expect(res1.items.len == 3);
    try std.testing.expect(res1.items[2] == 3);
    try std.testing.expect(res1.items[0] == 1);
    var mid = "   -123 321";
    const res2 = try getNumbersFromSlise(i64, mid, std.testing.allocator);
    defer res2.deinit();
    try std.testing.expect(res2.items.len == 2);
    try std.testing.expect(res2.items[1] == 321);
    try std.testing.expect(res2.items[0] == -123);
    var symb = "   - 4";
    const res3 = try getNumbersFromSlise(i64, symb, std.testing.allocator);
    defer res3.deinit();
    try std.testing.expect(res3.items.len == 1);
}

pub const Data = ArrayList(ArrayList(u8));

pub fn getData(path: []const u8, allocator: Allocator) !Data {
    const file = fs.cwd().openFile(path, .{}) catch |err| label: {
        print("unable to open file: {}\n", .{err});
        const stderr = std.io.getStdErr();
        break :label stderr;
    };

    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var data = ArrayList(ArrayList(u8)).init(allocator);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var value = ArrayList(u8).init(allocator);
        try value.appendSlice(line);
        try data.append(value);
    }

    return data;
}

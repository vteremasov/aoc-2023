const std = @import("std");
const utils = @import("../utils/utils.zig");
const ArrayList = std.ArrayList;
const print = std.debug.print;
const fs = std.fs;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

pub fn all(comptime T: type, data: ArrayList(T), comptime pred: fn (d: T) bool) bool {
    for (data.items) |item| {
        if (!pred(item)) return false;
    }

    return true;
}

pub fn parseNums(data: ArrayList(ArrayList(u8))) !ArrayList(ArrayList(i64)) {
    var result = ArrayList(ArrayList(i64)).init(allocator);

    for (data.items) |line| {
        var parsed = try utils.getNumbersFromSlise(i64, line.items, allocator);
        try result.append(parsed);
    }

    return result;
}

pub fn isZero(n: i64) bool {
    return n == 0;
}

pub fn getDiffs(data: ArrayList(i64)) !ArrayList(i64) {
    var result = ArrayList(i64).init(allocator);
    var counter: usize = 1;

    while (counter < data.items.len) {
        try result.append(data.items[counter] - data.items[counter - 1]);
        counter += 1;
    }

    return result;
}

test "getDiffs" {
    var sec: [6]i64 = .{ 1, 3, 6, 10, 15, 21 };
    var data = ArrayList(i64).init(allocator);
    defer data.deinit();
    try data.appendSlice(&sec);
    var res = try getDiffs(data);
    try std.testing.expect(res.items.len == 5);
    try std.testing.expect(res.items[4] == 6);
}

pub fn getDiffSec(data: ArrayList(i64), comptime get: fn (l: []i64) i64) !ArrayList(i64) {
    var result = ArrayList(i64).init(allocator);
    var diffs = ArrayList(ArrayList(i64)).init(allocator);
    defer diffs.deinit();

    try diffs.append(data);
    var current = try getDiffs(data);

    while (true) {
        if (!all(i64, current, isZero)) {
            try diffs.append(current);
        } else {
            break;
        }
        current = try getDiffs(current);
    }

    for (diffs.items) |d| {
        try result.append(get(d.items));
    }

    return result;
}

test "getDiffSec" {
    var sec: [6]i64 = .{ 1, 3, 6, 10, 15, 21 };
    var data = ArrayList(i64).init(allocator);
    defer data.deinit();
    try data.appendSlice(&sec);
    var res = try getDiffSec(data);
    try std.testing.expect(res.items.len == 3);
    var sec2: [6]i64 = .{ 10, 13, 16, 21, 30, 45 };
    _ = data.shrinkAndFree(0);
    try data.appendSlice(&sec2);
    var res2 = try getDiffSec(data);
    try std.testing.expect(res2.items.len == 4);
    try std.testing.expect(res2.items[res2.items.len - 1] == 2);
}

pub fn sum(data: []i64) i64 {
    var result: i64 = 0;

    for (data) |n| {
        result += n;
    }

    return result;
}

pub fn sub(data: []i64) i64 {
    var result: i64 = 0;
    var counter: i64 = @intCast(data.len - 1);

    while (counter >= 0) {
        result = data[@as(usize, @intCast(counter))] - result;
        counter -= 1;
    }

    return result;
}

pub fn head(l: []i64) i64 {
    return l[l.len - 1];
}

pub fn solution1(data: ArrayList(ArrayList(u8))) !i64 {
    var nums = try parseNums(data);
    var history = ArrayList(i64).init(allocator);
    defer nums.deinit();
    defer history.deinit();

    for (nums.items) |row| {
        var sec = try getDiffSec(row, head);
        defer sec.deinit();
        var h = sum(sec.items);
        try history.append(h);
    }

    return sum(history.items);
}

pub fn tail(l: []i64) i64 {
    return l[0];
}

pub fn solution2(data: ArrayList(ArrayList(u8))) !i64 {
    var nums = try parseNums(data);
    var history = ArrayList(i64).init(allocator);
    defer nums.deinit();
    defer history.deinit();

    for (nums.items) |row| {
        var sec = try getDiffSec(row, tail);
        defer sec.deinit();
        var h = sub(sec.items);
        try history.append(h);
    }

    return sum(history.items);
}

pub fn aocDay9() !i64 {
    const file = fs.cwd().openFile("input/day_9_input", .{}) catch |err| label: {
        print("unable to open file: {}\n", .{err});
        const stderr = std.io.getStdErr();
        break :label stderr;
    };

    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var data = ArrayList(ArrayList(u8)).init(allocator);
    defer data.deinit();
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var value = ArrayList(u8).init(allocator);
        try value.appendSlice(line);
        try data.append(value);
    }

    return try solution2(data);
}

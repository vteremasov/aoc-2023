const std = @import("std");
const utils = @import("../utils/utils.zig");
const ArrayList = std.ArrayList;
const print = std.debug.print;
const fs = std.fs;
const mem = std.mem;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

pub fn solution1(timesStr: []const u8, distsStr: []const u8) !i64 {
    const times = try utils.getNumbersFromSlise(i64, timesStr, allocator);
    defer times.deinit();
    const dists = try utils.getNumbersFromSlise(i64, distsStr, allocator);
    defer dists.deinit();

    var result: i64 = 1;

    for (0..times.items.len) |i| {
        var counter: i64 = 0;
        for (0..@intCast(times.items[i] + 1)) |j| {
            if (@as(i64, @intCast(j)) * (times.items[i] - @as(i64, @intCast(j))) > dists.items[i]) {
                counter += 1;
            }
        }
        result *= counter;
    }

    return result;
}

pub fn aocDay6() !i64 {
    const file = fs.cwd().openFile("input/day_6_input", .{}) catch |err| label: {
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

    var timesIt = mem.splitScalar(u8, data.items[0].items, ':');
    var distIt = mem.splitScalar(u8, data.items[1].items, ':');
    _ = timesIt.next(); // skip word
    _ = distIt.next(); // skip word
    const timesStr = timesIt.next() orelse "";
    const distsStr = distIt.next() orelse "";

    var result1: i64 = try solution1(timesStr, distsStr);
    _ = result1;

    var timesStr2: [1024]u8 = undefined;
    var distsStr2: [1024]u8 = undefined;
    _ = mem.replace(u8, timesStr, " ", "", &timesStr2);
    _ = mem.replace(u8, distsStr, " ", "", &distsStr2);

    var result2: i64 = try solution1(&timesStr2, &distsStr2);

    return result2;
}

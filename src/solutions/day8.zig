const std = @import("std");
const ArrayList = std.ArrayList;
const HM = std.StringArrayHashMap;
const print = std.debug.print;
const fs = std.fs;
const mem = std.mem;

var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

pub fn lcm(a: i64, b: i64) i64 {
    var max = @max(a, b);
    var min = @min(a, b);
    var res: i64 = max;
    while (true) {
        if (@rem(res, min) == 0) return res;
        res += max;
    }
}

test "lcm" {
    try std.testing.expect(lcm(16, 20) == 80);
    try std.testing.expect(lcm(2, 3) == 6);
}

pub fn getAllByTail(items: [][]const u8, pat: []const u8) !ArrayList(ArrayList(u8)) {
    var result = ArrayList(ArrayList(u8)).init(allocator);
    for (items) |item| {
        if (mem.endsWith(u8, item, pat)) {
            var val = ArrayList(u8).init(allocator);
            try val.appendSlice(item);
            try result.append(val);
        }
    }

    return result;
}

pub fn endWithZ(item: []const u8) bool {
    return mem.endsWith(u8, item, "Z");
}

pub fn eqZ(item: []const u8) bool {
    return mem.eql(u8, item, "ZZZ");
}

pub fn solution2(dirs: []u8, hashData: HM([]u8)) !i64 {
    var movedCounter: i64 = 1;
    var starts = try getAllByTail(hashData.keys(), "A");
    var ways = ArrayList(i64).init(allocator);
    for (starts.items) |s| {
        try ways.append(try solution1(s.items, endWithZ, dirs, hashData));
    }
    for (ways.items) |item| {
        movedCounter = lcm(movedCounter, item);
    }

    return movedCounter;
}

pub fn solution1(start: []const u8, comptime end: fn ([]const u8) bool, dirs: []u8, hashData: HM([]u8)) !i64 {
    var dirIndex: usize = 0;
    var movedCounter: i64 = 0;
    var current: [3]u8 = undefined;
    @memcpy(&current, start);

    while (!end(&current)) {
        if (dirs[dirIndex] == 'L') {
            var c = hashData.get(&current) orelse "";
            @memcpy(&current, c[7..10]);
        }
        if (dirs[dirIndex] == 'R') {
            var c = hashData.get(&current) orelse "";
            @memcpy(&current, c[12..15]);
        }
        dirIndex = (dirIndex + 1) % dirs.len;
        movedCounter += 1;
    }

    return movedCounter;
}

pub fn aocDay8() !i64 {
    const file = fs.cwd().openFile("input/day_8_input", .{}) catch |err| label: {
        print("unable to open file: {}\n", .{err});
        const stderr = std.io.getStdErr();
        break :label stderr;
    };

    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var data = ArrayList(ArrayList(u8)).init(allocator);
    var hashData = HM([]u8).init(allocator);
    defer data.deinit();
    defer hashData.deinit();
    var counter: u64 = 0;
    var dirsBuf: [1024]u8 = undefined;
    var dirs: []u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var value = ArrayList(u8).init(allocator);
        try value.appendSlice(line);
        try data.append(value);
        if (counter > 1) {
            try hashData.put(value.items[0..3], value.items);
        }

        if (counter == 0) {
            mem.copy(u8, &dirsBuf, line);
            dirs = dirsBuf[0..line.len];
        }

        counter += 1;
    }

    const result1 = try solution1("AAA", eqZ, dirs, hashData);
    _ = result1;
    const result2 = try solution2(dirs, hashData);

    return result2;
}

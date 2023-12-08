const std = @import("std");
const fmt = std.fmt;
const ascii = std.ascii;
const ArrayList = std.ArrayList;
const print = std.debug.print;
const fs = std.fs;
const mem = std.mem;
const HM = std.StringArrayHashMap;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

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

    var dirIndex: usize = 0;
    var movedCounter: i64 = 0;
    var current: [3]u8 = "AAA".*;
    while (!mem.eql(u8, &current, "ZZZ")) {
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

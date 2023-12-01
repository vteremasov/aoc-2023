const std = @import("std");
const ArrayList = std.ArrayList;
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const NumerRecord = struct { number: u8, index: usize };
const LinesData = ArrayList(ArrayList(NumerRecord));
const Numbers = enum { one, two, three, four, five, six, seven, eight, nine };
var numbers = &[_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn aoc_day_1() !i64 {
    std.debug.print("start reading file\n", .{});
    const file = std.fs.cwd().openFile("input/day_1_input", .{}) catch |err| label: {
        std.debug.print("unable to open file: {}\n", .{err});
        const stderr = std.io.getStdErr();
        break :label stderr;
    };

    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var allNumbers = LinesData.init(allocator);
    defer allNumbers.deinit();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (numbers) |n| {
            var index: usize = @intCast(0);
            while (std.mem.indexOfPos(u8, line, index, n)) |i| {
                index = i + 1;
                const case = std.meta.stringToEnum(Numbers, n) orelse @panic("Cannot be true");
                switch (case) {
                    .one => line[i + 1] = '1',
                    .two => line[i + 1] = '2',
                    .three => line[i + 2] = '3',
                    .four => line[i + 1] = '4',
                    .five => line[i + 1] = '5',
                    .six => line[i + 1] = '6',
                    .seven => line[i + 2] = '7',
                    .eight => line[i + 2] = '8',
                    .nine => line[i + 1] = '9',
                }
            }
        }

        var lineNumbers = ArrayList(NumerRecord).init(allocator);
        for (0.., line) |index, elem| {
            if (std.ascii.isDigit(elem)) {
                try lineNumbers.append(NumerRecord{ .number = elem, .index = index });
            }
        }
        try allNumbers.append(lineNumbers);
    }

    var pairs = ArrayList([2]u8).init(allocator);
    for (allNumbers.items) |lineNumbers| {
        var firstIndex: i32 = @as(i32, std.math.maxInt(i32));
        var first: u8 = undefined;

        var lastIndex = @as(i32, -1);
        var last: u8 = undefined;

        for (lineNumbers.items) |line| {
            if (line.index < firstIndex) {
                firstIndex = @intCast(line.index);
                first = line.number;
            }

            if (line.index > lastIndex) {
                lastIndex = @intCast(line.index);
                last = line.number;
            }
        }

        try pairs.append(.{ first, last });
    }

    var result: i64 = 0;

    for (pairs.items) |pair| {
        result += try std.fmt.parseInt(i64, &pair, 10);
    }

    return result;
}

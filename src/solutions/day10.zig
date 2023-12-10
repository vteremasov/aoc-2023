const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;
const fs = std.fs;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

const Data = ArrayList(ArrayList(u8));

pub fn getData() !Data {
    const file = fs.cwd().openFile("input/day_10_input", .{}) catch |err| label: {
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

const Point = struct {
    x: usize,
    y: usize,
    dir: u8,
    pub fn eq(self: Point, other: Point) bool {
        return self.x == other.x and self.y == other.y;
    }
};

pub fn findAnimal(data: Data) Point {
    var result = Point{
        .x = 0,
        .y = 0,
        .dir = 'S',
    };
    for (data.items, 0..) |row, y| {
        for (row.items, 0..) |col, x| {
            if (col == 'S') {
                result.x = x;
                result.y = y;
                break;
            }
        }
    }
    return result;
}

// | is a vertical pipe connecting north and south.
// - is a horizontal pipe connecting east and west.
// L is a 90-degree bend connecting north and east.
// J is a 90-degree bend connecting north and west.
// 7 is a 90-degree bend connecting south and west.
// F is a 90-degree bend connecting south and east.
// . is ground; there is no pipe in this tile.
// S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.

pub fn getNextL(a: Point, c: u8, result: *ArrayList(Point)) !void {
    switch (c) {
        '-' => try result.append(Point{
            .x = a.x - 1,
            .y = a.y,
            .dir = 'L',
        }),
        'L' => try result.append(Point{
            .x = a.x - 1,
            .y = a.y,
            .dir = 'U',
        }),
        'F' => try result.append(Point{
            .x = a.x - 1,
            .y = a.y,
            .dir = 'D',
        }),
        'S' => try result.append(Point{
            .x = a.x - 1,
            .y = a.y,
            .dir = 'S',
        }),
        else => {
            //ignore
        },
    }
}
pub fn getNextR(a: Point, c: u8, result: *ArrayList(Point)) !void {
    switch (c) {
        '-' => try result.append(Point{
            .x = a.x + 1,
            .y = a.y,
            .dir = 'R',
        }),
        'J' => try result.append(Point{
            .x = a.x + 1,
            .y = a.y,
            .dir = 'U',
        }),
        '7' => try result.append(Point{
            .x = a.x + 1,
            .y = a.y,
            .dir = 'D',
        }),
        'S' => try result.append(Point{
            .x = a.x + 1,
            .y = a.y,
            .dir = 'S',
        }),
        else => {},
    }
}

pub fn getNextU(a: Point, c: u8, result: *ArrayList(Point)) !void {
    switch (c) {
        '|' => try result.append(Point{
            .x = a.x,
            .y = a.y - 1,
            .dir = 'U',
        }),
        'F' => try result.append(Point{
            .x = a.x,
            .y = a.y - 1,
            .dir = 'R',
        }),
        '7' => try result.append(Point{
            .x = a.x,
            .y = a.y - 1,
            .dir = 'L',
        }),
        'S' => try result.append(Point{
            .x = a.x,
            .y = a.y - 1,
            .dir = 'S',
        }),
        else => {},
    }
}

pub fn getNextD(a: Point, c: u8, result: *ArrayList(Point)) !void {
    switch (c) {
        '|' => try result.append(Point{
            .x = a.x,
            .y = a.y + 1,
            .dir = 'D',
        }),
        'L' => try result.append(Point{
            .x = a.x,
            .y = a.y + 1,
            .dir = 'R',
        }),
        'J' => try result.append(Point{
            .x = a.x,
            .y = a.y + 1,
            .dir = 'L',
        }),
        'S' => try result.append(Point{
            .x = a.x,
            .y = a.y + 1,
            .dir = 'S',
        }),
        else => {},
    }
}

pub fn getNext(a: Point, data: Data, result: *ArrayList(Point)) !void {
    switch (a.dir) {
        'L' => try getNextL(a, data.items[a.y].items[a.x - 1], result),
        'R' => try getNextR(a, data.items[a.y].items[a.x + 1], result),
        'U' => try getNextU(a, data.items[a.y - 1].items[a.x], result),
        'D' => try getNextD(a, data.items[a.y + 1].items[a.x], result),
        else => unreachable,
    }
}

pub fn getStarts(data: Data, a: Point) !ArrayList(Point) {
    var result = ArrayList(Point).init(allocator);
    if (@as(i64, @intCast(a.x)) - 1 >= 0) {
        try getNextL(a, data.items[a.y].items[a.x - 1], &result);
    }
    if (a.x + 1 < data.items[a.y].items.len) {
        try getNextR(a, data.items[a.y].items[a.x + 1], &result);
    }
    if (@as(i64, @intCast(a.y)) - 1 >= 0) {
        try getNextU(a, data.items[a.y - 1].items[a.x], &result);
    }
    if (a.y + 1 < data.items.len) {
        try getNextD(a, data.items[a.y + 1].items[a.x], &result);
    }
    return result;
}

pub fn part1() !i64 {
    var data = try getData();
    defer data.deinit();
    var animal = findAnimal(data);
    var starts = try getStarts(data, animal);
    var path1 = ArrayList(Point).init(allocator);
    var path2 = ArrayList(Point).init(allocator);
    var curr1 = starts.items[0];
    var curr2 = starts.items[1];
    try path1.append(starts.items[0]);
    try path2.append(starts.items[1]);

    while (!curr1.eq(curr2)) {
        try getNext(curr1, data, &path1);
        try getNext(curr2, data, &path2);
        curr1 = path1.items[path1.items.len - 1];
        curr2 = path2.items[path2.items.len - 1];
    }

    return @intCast(path1.items.len);
}

pub fn checkConn(s: []u8, c: u8) bool {
    for (s) |i| {
        if (i == c) return true;
        if (i != '-') return false;
    }

    return false;
}

test "checkConn" {
    var s1 = ".|F--7||||||||FJ...".*;

    try std.testing.expect(checkConn(s1[15..], 'J'));
}

pub fn isPart(s: []Point, x: usize, y: usize) bool {
    for (s) |i| {
        if (i.x == x and i.y == y) return true;
    }

    return false;
}

pub fn part2() !i64 {
    var data = try getData();
    defer data.deinit();
    var animal = findAnimal(data);
    var starts = try getStarts(data, animal);
    var path = ArrayList(Point).init(allocator);
    var curr = starts.items[0];
    try path.append(starts.items[0]);

    while (!curr.eq(animal)) {
        try getNext(curr, data, &path);
        curr = path.items[path.items.len - 1];
    }

    // For my input only
    data.items[animal.y].items[animal.x] = 'J';

    var countD: i64 = 0;
    var points = ArrayList(Point).init(allocator);
    for (data.items, 0..) |row, y| {
        var color = false;
        for (row.items, 0..) |el, x| {
            var part = isPart(path.items, x, y);
            if (el == '.') countD += 1;
            if (part) {
                if (el == '|' or (el == 'L' and checkConn(row.items[x + 1 ..], '7')) or (el == 'F' and checkConn(row.items[x + 1 ..], 'J'))) {
                    color = !color;
                }
            }
            if (color and (el == '.' or !part)) {
                try points.append(Point{
                    .x = x,
                    .y = y,
                    .dir = 'I',
                });
            }
        }
    }

    return @intCast(points.items.len);
}

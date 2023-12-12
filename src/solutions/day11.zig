const std = @import("std");
const utils = @import("../utils/utils.zig");
const print = std.debug.print;
const ArrayList = std.ArrayList;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

const Point = struct {
    x: usize,
    y: usize,
};

pub fn findGalaxies(data: utils.Data) !ArrayList(Point) {
    var result = ArrayList(Point).init(allocator);
    for (data.items, 0..) |line, y| {
        for (line.items, 0..) |g, x| {
            if (g == '#') {
                try result.append(Point{ .x = x, .y = y });
            }
        }
    }

    return result;
}

pub fn isEmptySpaceX(space: []u8) bool {
    for (space) |s| {
        if (s != '.') return false;
    }

    return true;
}
pub fn getEmptySpacesY(space: utils.Data) !ArrayList(usize) {
    var result = ArrayList(usize).init(allocator);
    for (space.items, 0..) |line, y| {
        if (!isEmptySpaceX(line.items)) {
            continue;
        } else {
            try result.append(y);
        }
    }

    return result;
}

pub fn getEmptySpacesX(space: utils.Data) !ArrayList(usize) {
    var result = ArrayList(usize).init(allocator);
    for (0..space.items[0].items.len) |i| {
        var empty = true;
        for (space.items) |line| {
            if (line.items[i] != '.') {
                empty = false;
            }
        }
        if (empty) {
            try result.append(i);
        }
    }

    return result;
}

pub fn in(n: usize, arr: ArrayList(usize)) bool {
    for (arr.items) |item| {
        if (n == item) return true;
    }

    return false;
}

pub fn sum(sl: []usize) usize {
    var result: usize = 0;
    for (sl) |item| {
        result += item;
    }

    return result;
}

pub fn part1() !usize {
    var data = try utils.getData("input/day_11_input", allocator);
    var galaxies = try findGalaxies(data);
    var emptyX = try getEmptySpacesX(data);
    var emptyY = try getEmptySpacesY(data);
    var paths = ArrayList(usize).init(allocator);
    var len = galaxies.items.len;
    for (0..len) |i| {
        var g = galaxies.items[i];
        for (i..len) |j| {
            var g2 = galaxies.items[j];
            if (g.x == g2.x and g.y == g2.y) {
                continue;
            }
            var expX: i64 = 0;
            var minX = @min(g.x, g2.x);
            var maxX = @max(g.x, g2.x);
            for (emptyX.items) |n| {
                if (n > minX and n < maxX) expX += 1;
            }
            var expY: i64 = 0;
            var minY = @min(g.y, g2.y);
            var maxY = @max(g.y, g2.y);
            for (emptyY.items) |n| {
                if (n > minY and n < maxY) expY += 1;
            }
            var xd: usize = @intCast(try std.math.absInt(@as(i64, @intCast(g2.x)) - @as(i64, @intCast(g.x))) + expX);
            var yd: usize = @intCast(try std.math.absInt(@as(i64, @intCast(g2.y)) - @as(i64, @intCast(g.y))) + expY);
            try paths.append(xd + yd);
        }
    }
    return sum(paths.items);
}

pub fn part2() !usize {
    var data = try utils.getData("input/day_11_input", allocator);
    var galaxies = try findGalaxies(data);
    var emptyX = try getEmptySpacesX(data);
    var emptyY = try getEmptySpacesY(data);
    var paths = ArrayList(usize).init(allocator);
    var len = galaxies.items.len;
    for (0..len) |i| {
        var g = galaxies.items[i];
        for (i..len) |j| {
            var g2 = galaxies.items[j];
            if (g.x == g2.x and g.y == g2.y) {
                continue;
            }
            var expX: i64 = 0;
            var minX = @min(g.x, g2.x);
            var maxX = @max(g.x, g2.x);
            for (emptyX.items) |n| {
                if (n > minX and n < maxX) expX += 1_000_000 - 1;
            }
            var expY: i64 = 0;
            var minY = @min(g.y, g2.y);
            var maxY = @max(g.y, g2.y);
            for (emptyY.items) |n| {
                if (n > minY and n < maxY) expY += 1_000_000 - 1;
            }
            var xd: usize = @intCast(try std.math.absInt(@as(i64, @intCast(g2.x)) - @as(i64, @intCast(g.x))) + expX);
            var yd: usize = @intCast(try std.math.absInt(@as(i64, @intCast(g2.y)) - @as(i64, @intCast(g.y))) + expY);
            try paths.append(xd + yd);
        }
    }
    return sum(paths.items);
}

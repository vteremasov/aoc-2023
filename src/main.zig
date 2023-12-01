const std = @import("std");
const day1 = @import("./solutions/day1.zig");

pub fn main() !void {
    var result = try day1.aoc_day_1();
    std.debug.print("Day 1 result: {}\n", .{result});
}

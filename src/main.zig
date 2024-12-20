const std = @import("std");
const day1 = @import("./solutions/day1.zig");
const day2 = @import("./solutions/day2.zig");
const day3 = @import("./solutions/day3.zig");
const day4 = @import("./solutions/day4.zig");
const day5 = @import("./solutions/day5.zig");
const day6 = @import("./solutions/day6.zig");
const day7 = @import("./solutions/day7.zig");
const day8 = @import("./solutions/day8.zig");
const day9 = @import("./solutions/day9.zig");
const day10 = @import("./solutions/day10.zig");
const day11 = @import("./solutions/day11.zig");
const day12 = @import("./solutions/day12.zig");

const print = std.debug.print;

const Commands = enum {
    solve,
    init,
    help,
};

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);
    const commandArg = args[1];
    const command = std.meta.stringToEnum(Commands, commandArg) orelse {
        const errorMsg = try std.fmt.allocPrint(gpa, "Error: Unknown command `{s}`. Try `help` to see commands", .{commandArg});
        @panic(errorMsg);
    };

    switch (command) {
        .solve => {
            if (args.len < 3) {
                @panic("Error: Provide day number to solve");
            }
            const dayArg = args[2];
            if (std.mem.eql(u8, dayArg, "day1")) {
                var result = try day1.aoc_day_1();
                print("Day 1 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day2")) {
                var result = try day2.aocDay2();
                print("Day 2 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day3")) {
                var result = try day3.aocDay3();
                print("Day 3 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day4")) {
                var result = try day4.aocDay4();
                print("Day 4 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day5")) {
                var result = try day5.aocDay5();
                print("Day 5 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day6")) {
                var result = try day6.aocDay6();
                print("Day 6 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day7")) {
                var result = try day7.aocDay7();
                print("Day 7 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day8")) {
                var result = try day8.aocDay8();
                print("Day 8 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day9")) {
                var result = try day9.aocDay9();
                print("Day 9 result: {}\n", .{result});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day10")) {
                var result1 = try day10.part1();
                var result2 = try day10.part2();
                print("Day 10 part 1: {}\n", .{result1});
                print("Day 10 part 2: {}\n", .{result2});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day11")) {
                var result1 = try day11.part1();
                var result2 = try day11.part2();
                print("Day 11 part 1: {}\n", .{result1});
                print("Day 11 part 2: {}\n", .{result2});
                return;
            }
            if (std.mem.eql(u8, dayArg, "day12")) {
                var result1 = try day12.part1();
                print("Day 12 part 1: {}\n", .{result1});
                var result2 = try day12.part2();
                print("Day 12 part 2: {}\n", .{result2});
                return;
            } else {
                @panic(try std.fmt.allocPrint(gpa, "Error: `{s}` day not found", .{dayArg}));
            }
        },
        else => {
            print("{} not implemented yet.", .{command});
            @panic("Exiting");
        },
    }

    // for (args, 0..) |arg, i| {
    // std.debug.print("{}: {s}\n", .{ i, arg });
    // }

}

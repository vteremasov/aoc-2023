const std = @import("std");
const day1 = @import("./solutions/day1.zig");
const day2 = @import("./solutions/day2.zig");
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
                std.debug.print("Day 1 result: {}\n", .{result});
            }
            if (std.mem.eql(u8, dayArg, "day2")) {
                var result = try day2.aocDay2();
                std.debug.print("Day 2 result: {}\n", .{result});
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

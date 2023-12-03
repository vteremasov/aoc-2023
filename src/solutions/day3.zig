const std = @import("std");
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const print = std.debug.print;
const fs = std.fs;
const ascii = std.ascii;
const mem = std.mem;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

pub fn isSymb(ch: u8) bool {
    if (!ascii.isAlphanumeric(ch)) {
        switch (ch) {
            '.' => return false,
            else => return true,
        }
    }
    return false;
}

test "isSymb" {
    try std.testing.expect(isSymb('%'));
    try std.testing.expect(!isSymb('.'));
    try std.testing.expect(!isSymb('r'));
}

pub fn getAdjacents(data: ArrayList(ArrayList(u8))) !ArrayList(i64) {
    var numbers = ArrayList(i64).init(allocator);

    for (data.items, 0..) |line, lIndex| {
        var currNumber = ArrayList(u8).init(allocator);
        defer currNumber.deinit();
        var isAdjacent = false;
        for (line.items, 0..) |ch, chIndex| {
            if (ascii.isDigit(ch)) {
                if (chIndex > 0) {
                    if (isSymb(line.items[chIndex - 1])) {
                        isAdjacent = true;
                    }
                }
                if (chIndex < line.items.len - 1) {
                    if (isSymb(line.items[chIndex + 1])) {
                        isAdjacent = true;
                    }
                }
                if (lIndex > 0) {
                    const topLine = data.items[lIndex - 1];
                    if (isSymb(topLine.items[chIndex])) {
                        isAdjacent = true;
                    }
                    if (chIndex > 0) {
                        if (isSymb(topLine.items[chIndex - 1])) {
                            isAdjacent = true;
                        }
                    }
                    if (chIndex < line.items.len - 1) {
                        if (isSymb(topLine.items[chIndex + 1])) {
                            isAdjacent = true;
                        }
                    }
                }
                if (lIndex < data.items.len - 1) {
                    const bottomLine = data.items[lIndex + 1];
                    if (isSymb(bottomLine.items[chIndex])) {
                        isAdjacent = true;
                    }
                    if (chIndex > 0) {
                        if (isSymb(bottomLine.items[chIndex - 1])) {
                            isAdjacent = true;
                        }
                    }
                    if (chIndex < line.items.len - 1) {
                        if (isSymb(bottomLine.items[chIndex + 1])) {
                            isAdjacent = true;
                        }
                    }
                }
                try currNumber.append(ch);
            } else {
                if (currNumber.items.len > 0) {
                    if (isAdjacent) {
                        const n = try std.fmt.parseInt(i64, currNumber.items, 10);
                        try numbers.append(n);
                        isAdjacent = false;
                    }
                    currNumber.clearAndFree();
                }
            }

            if (line.items.len - 1 == chIndex and currNumber.items.len > 0) {
                if (isAdjacent) {
                    const n = try std.fmt.parseInt(i64, currNumber.items, 10);
                    try numbers.append(n);
                    isAdjacent = false;
                }
                currNumber.clearAndFree();
            }
        }
    }

    return numbers;
}

pub fn isStar(ch: u8) bool {
    return switch (ch) {
        '*' => true,
        else => false,
    };
}

test "isStar" {
    try std.testing.expect(isStar('*'));
    try std.testing.expect(!isStar('$'));
}

pub fn getGears(data: ArrayList(ArrayList(u8))) !ArrayList(i64) {
    var numbers = ArrayList(i64).init(allocator);
    var stars = StringHashMap(ArrayList(i64)).init(allocator);
    defer stars.deinit();

    for (data.items, 0..) |line, lIndex| {
        for (line.items, 0..) |ch, chIndex| {
            switch (ch) {
                '*' => {
                    const key = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex, chIndex });
                    var arr = ArrayList(i64).init(allocator);
                    try stars.put(key, arr);
                },
                else => {
                    //ignore
                },
            }
        }
    }
    for (data.items, 0..) |line, lIndex| {
        var currNumber = ArrayList(u8).init(allocator);
        defer currNumber.deinit();
        var isAdjacent = false;
        var address: []u8 = undefined;
        for (line.items, 0..) |ch, chIndex| {
            if (ascii.isDigit(ch)) {
                if (chIndex > 0) {
                    if (isStar(line.items[chIndex - 1])) {
                        isAdjacent = true;
                        address = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex, chIndex - 1 });
                    }
                }
                if (chIndex < line.items.len - 1) {
                    if (isStar(line.items[chIndex + 1])) {
                        isAdjacent = true;
                        address = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex, chIndex + 1 });
                    }
                }
                if (lIndex > 0) {
                    const topLine = data.items[lIndex - 1];
                    if (isStar(topLine.items[chIndex])) {
                        isAdjacent = true;
                        address = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex - 1, chIndex });
                    }
                    if (chIndex > 0) {
                        if (isStar(topLine.items[chIndex - 1])) {
                            isAdjacent = true;
                            address = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex - 1, chIndex - 1 });
                        }
                    }
                    if (chIndex < line.items.len - 1) {
                        if (isStar(topLine.items[chIndex + 1])) {
                            isAdjacent = true;
                            address = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex - 1, chIndex + 1 });
                        }
                    }
                }
                if (lIndex < data.items.len - 1) {
                    const bottomLine = data.items[lIndex + 1];
                    if (isStar(bottomLine.items[chIndex])) {
                        isAdjacent = true;
                        address = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex + 1, chIndex });
                    }
                    if (chIndex > 0) {
                        if (isStar(bottomLine.items[chIndex - 1])) {
                            isAdjacent = true;
                            address = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex + 1, chIndex - 1 });
                        }
                    }
                    if (chIndex < line.items.len - 1) {
                        if (isStar(bottomLine.items[chIndex + 1])) {
                            isAdjacent = true;
                            address = try std.fmt.allocPrint(allocator, "{}_{}", .{ lIndex + 1, chIndex + 1 });
                        }
                    }
                }
                try currNumber.append(ch);
            } else {
                if (currNumber.items.len > 0) {
                    if (isAdjacent) {
                        const n = try std.fmt.parseInt(i64, currNumber.items, 10);
                        var arr = stars.getPtr(address) orelse {
                            @panic("Finding numbers does not work");
                        };
                        try arr.*.append(n);
                        isAdjacent = false;
                    }
                    currNumber.clearAndFree();
                }
            }

            if (line.items.len - 1 == chIndex and currNumber.items.len > 0) {
                if (isAdjacent) {
                    const n = try std.fmt.parseInt(i64, currNumber.items, 10);
                    var arr = stars.getPtr(address) orelse {
                        @panic("Finding numbers does not work");
                    };
                    try arr.*.append(n);
                    isAdjacent = false;
                }
                currNumber.clearAndFree();
            }
        }
    }

    var it = stars.iterator();
    while (it.next()) |kv| {
        if (kv.value_ptr.*.items.len == 2) {
            try numbers.append(kv.value_ptr.*.items[0] * kv.value_ptr.*.items[1]);
        }
    }

    return numbers;
}

pub fn aocDay3() !i128 {
    const file = fs.cwd().openFile("input/day_3_input", .{}) catch |err| label: {
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

    var result1: i128 = 0;
    // var ns = try getAdjacents(data);
    var ns = try getGears(data);

    for (ns.items) |n| {
        result1 += n;
    }

    ns.deinit();

    return result1;
}

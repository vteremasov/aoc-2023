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

pub fn getNumbersFromSlise(slice: []const u8) !ArrayList([]const u8) {
    var result = ArrayList([]const u8).init(allocator);
    var start: i8 = -1;
    for (slice, 0..) |c, i| {
        if (ascii.isDigit(c)) {
            if (start == -1) start = @intCast(i);
        } else {
            if (start != -1) {
                try result.append(slice[@intCast(start)..i]);
                start = -1;
            }
        }
    }
    if (start != -1) {
        try result.append(slice[@intCast(start)..slice.len]);
        start = -1;
    }

    return result;
}

test "getNumbersFromSlise" {
    var simple = "1,2,3";
    const res1 = try getNumbersFromSlise(simple);
    defer res1.deinit();
    try std.testing.expect(res1.items.len == 3);
    try std.testing.expect(res1.items[2][0] == '3');
    try std.testing.expect(res1.items[0][0] == '1');
    var mid = "   123 321";
    const res2 = try getNumbersFromSlise(mid);
    defer res2.deinit();
    try std.testing.expect(res2.items.len == 2);
}

pub fn inArr(s: []const u8, arr: ArrayList([]const u8)) bool {
    for (arr.items) |el| {
        if (mem.eql(u8, s, el)) {
            return true;
        }
    }

    return false;
}

pub fn partOneResults(data: ArrayList(ArrayList(u8))) !ArrayList(i64) {
    var result = ArrayList(i64).init(allocator);
    var counter: i64 = 0;
    for (data.items) |line| {
        var cardGameIt = mem.splitScalar(u8, line.items, '|');
        const cardNGame = cardGameIt.next() orelse "";
        const game = cardGameIt.next() orelse "";
        var cardsIt = mem.splitScalar(u8, cardNGame, ':');
        _ = cardsIt.next(); // Skip `Card N:`
        const cards = cardsIt.next() orelse "";
        var cardNs = try getNumbersFromSlise(cards);
        defer cardNs.deinit();
        var gameNs = try getNumbersFromSlise(game);
        defer gameNs.deinit();
        for (cardNs.items) |card| {
            if (inArr(card, gameNs)) {
                if (counter == 0) {
                    counter = 1;
                } else {
                    counter = counter << 1;
                }
            }
        }
        if (counter > 0) {
            try result.append(counter);
            counter = 0;
        }
    }
    return result;
}

pub fn partTwoResults(data: ArrayList(ArrayList(u8))) !ArrayList(i64) {
    var results = ArrayList(i64).init(allocator);
    var allCards = ArrayList(ArrayList(i64)).init(allocator);
    defer allCards.deinit();
    for (data.items, 0..) |line, li| {
        _ = li;
        var cardGameIt = mem.splitScalar(u8, line.items, '|');
        const cardNGame = cardGameIt.next() orelse "";
        const game = cardGameIt.next() orelse "";
        var cardsIt = mem.splitScalar(u8, cardNGame, ':');
        _ = cardsIt.next(); // Skip `Card N:`
        const cards = cardsIt.next() orelse "";
        var cardNs = try getNumbersFromSlise(cards);
        defer cardNs.deinit();
        var gameNs = try getNumbersFromSlise(game);
        defer gameNs.deinit();

        var locals: i64 = 0;

        for (cardNs.items) |card| {
            if (inArr(card, gameNs)) {
                locals += 1;
            }
        }
        var tmp = ArrayList(i64).init(allocator);
        try tmp.append(locals);
        try allCards.append(tmp);
    }

    // This is so crazy. I couln't come up with a good solution
    for (allCards.items, 0..) |match, i| {
        if (match.items[0] == 0 or i + 1 > allCards.items.len) continue;
        for (i + 1..i + 1 + @as(usize, @intCast(match.items[0]))) |j| {
            for (0..@intCast(match.items.len)) |_| {
                try allCards.items[j].append(allCards.items[j].items[0]);
            }
        }
    }

    for (allCards.items) |row| {
        try results.append(@intCast(row.items.len));
    }

    return results;
}

pub fn aocDay4() !i64 {
    const file = fs.cwd().openFile("input/day_4_input", .{}) catch |err| label: {
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
        // print("{s}\n", .{line});
        var value = ArrayList(u8).init(allocator);
        try value.appendSlice(line);
        try data.append(value);
    }

    const winning = try partOneResults(data);
    defer winning.deinit();
    const cards = try partTwoResults(data);

    var result: i64 = 0;

    for (cards.items) |n| {
        result += n;
    }

    return result;
}

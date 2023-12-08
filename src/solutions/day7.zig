const std = @import("std");
const fmt = std.fmt;
const ascii = std.ascii;
const ArrayList = std.ArrayList;
const print = std.debug.print;
const fs = std.fs;
const mem = std.mem;
const HM = std.AutoArrayHashMap;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

pub fn compU8(ch1: u8, ch2: u8) bool {
    const ch1D = ascii.isDigit(ch1);
    const ch2D = ascii.isDigit(ch2);
    if (ch1D and ch2D) {
        return ch1 > ch2;
    }

    if (ch1D) {
        return false;
    }

    if (ch2D) {
        return true;
    }

    switch (ch1) {
        'A' => if (ch2 == 'A') return false,
        'K' => if (ch2 == 'A') return false,
        'Q' => if (ch2 == 'A' or ch2 == 'K') return false,
        'J' => if (ch2 == 'A' or ch2 == 'K' or ch2 == 'Q') return false,
        'T' => if (ch2 == 'A' or ch2 == 'K' or ch2 == 'J' or ch2 == 'Q') return false,
        else => return true,
    }

    return true;
}

test "compU8" {
    try std.testing.expect(compU8('9', '5') == true);
    try std.testing.expect(compU8('2', '4') == false);
    try std.testing.expect(compU8('A', 'K') == true);
    try std.testing.expect(compU8('J', 'K') == false);
    try std.testing.expect(compU8('T', '9') == true);
}

const Hand = struct {
    cards: []const u8,
    bid: i64,
    cache: HM(u8, u8),

    pub fn init(cards: []const u8, bid: i64) !Hand {
        var cache = HM(u8, u8).init(allocator);

        // there is always 5 of them
        for (0..5) |i| {
            var c = cache.get(cards[i]);

            if (c) |ca| {
                try cache.put(cards[i], ca + 1);
            } else {
                try cache.put(cards[i], 1);
            }
        }

        return Hand{
            .cards = cards,
            .bid = bid,
            .cache = cache,
        };
    }

    pub fn compare(self: Hand, other: Hand) bool {
        if (self.cache.count() == other.cache.count()) {
            var selfMax: u8 = 0;
            var otherMax: u8 = 0;

            for (self.cache.values()) |v| {
                if (v > selfMax) {
                    selfMax = v;
                }
            }

            for (other.cache.values()) |v| {
                if (v > otherMax) {
                    otherMax = v;
                }
            }

            if (selfMax == otherMax) {
                for (0..5) |i| {
                    if (self.cards[i] != other.cards[i]) {
                        return compU8(self.cards[i], other.cards[i]);
                    }
                }
            }

            return selfMax > otherMax;
        }

        if (self.cache.count() < other.cache.count()) {
            return true;
        }

        return false;
    }
};

pub fn compHands(_: void, h1: Hand, h2: Hand) bool {
    return h2.compare(h1);
}

test "compHands" {
    const h1 = try Hand.init("32T3K", 500);
    const h2 = try Hand.init("T55J5", 300);
    const h3 = try Hand.init("QQQJA", 300);
    const h4 = try Hand.init("555A5", 300);
    const h5 = try Hand.init("KQQ8K", 300);

    try std.testing.expect(compHands({}, h2, h1) == false);
    try std.testing.expect(compHands({}, h2, h2) == false);
    try std.testing.expect(compHands({}, h2, h3) == true);
    try std.testing.expect(compHands({}, h3, h2) == false);
    try std.testing.expect(compHands({}, h5, h4) == true);
}

pub fn solution1(data: ArrayList(ArrayList(u8))) !i64 {
    var hands = ArrayList(Hand).init(allocator);
    for (data.items) |line| {
        var lineIt = mem.splitScalar(u8, line.items, ' ');
        var handSl = lineIt.next() orelse "";
        const nSl = lineIt.next() orelse "";
        const bid = try fmt.parseInt(i64, nSl, 10);
        var hand = try Hand.init(handSl, bid);
        try hands.append(hand);
    }

    var sorted = try hands.toOwnedSlice();

    std.sort.block(Hand, sorted, {}, compHands);

    var result: i64 = 0;

    for (sorted, 0..) |s, i| {
        print("{s} {}\n", .{ s.cards, s.bid });
        result += (@as(i64, @intCast(i)) + 1) * s.bid;
    }

    return result;
}

// not 246629977

pub fn aocDay7() !i64 {
    const file = fs.cwd().openFile("input/day_7_input", .{}) catch |err| label: {
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

    const result1 = try solution1(data);

    return result1;
}

const std = @import("std");
const ArrayList = std.ArrayList;
const print = std.debug.print;
const fs = std.fs;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

const GameRound = struct {
    red: i64,
    green: i64,
    blue: i64,
};

const GameResult = struct {
    id: i64,
    isPossible: bool,
};

const Limit = GameRound{
    .red = 12,
    .green = 13,
    .blue = 14,
};

pub fn getGameResult(gameRecord: []u8) !GameResult {
    var replaced: [2048]u8 = undefined;
    _ = std.mem.replace(u8, gameRecord, ",", "", &replaced);
    var game = std.mem.splitScalar(u8, &replaced, ' ');
    _ = game.next(); // skip Game word
    var it = std.mem.splitScalar(u8, game.next() orelse "0", ':');
    const gi = it.next() orelse "0";
    const gameId = try std.fmt.parseInt(i64, gi, 10);
    var result = GameResult{ .id = gameId, .isPossible = true };

    var currCount: i64 = 0;
    while (game.next()) |token| {
        if (std.ascii.isDigit(token[0])) {
            currCount = try std.fmt.parseInt(i64, token, 10);
            continue;
        }
        if ((std.mem.eql(u8, token, "red") or std.mem.eql(u8, token, "red;")) and currCount > Limit.red) {
            result.isPossible = false;
            break;
        }
        if ((std.mem.eql(u8, token, "green") or std.mem.eql(u8, token, "green;")) and currCount > Limit.green) {
            result.isPossible = false;
            break;
        }
        if ((std.mem.eql(u8, token, "blue") or std.mem.eql(u8, token, "blue;")) and currCount > Limit.blue) {
            result.isPossible = false;
            break;
        }
    }
    return result;
}

pub fn getFewestNumbers(gameRecord: []u8) !GameRound {
    var buf: [1024]u8 = undefined;
    var replaces = std.mem.replace(u8, gameRecord, ",", "", &buf);
    var output = buf[0 .. gameRecord.len - replaces];
    var game = std.mem.splitScalar(u8, output, ' ');
    _ = game.next(); // skip Game word
    _ = game.next(); // skip game id
    var result = GameRound{ .red = 1, .green = 1, .blue = 1 };

    var currCount: i64 = 0;
    while (game.next()) |token| {
        if (std.ascii.isDigit(token[0])) {
            currCount = try std.fmt.parseInt(i64, token, 10);
            continue;
        }
        if ((std.mem.eql(u8, token, "red") or std.mem.eql(u8, token, "red;")) and currCount > result.red) {
            result.red = currCount;
        }
        if ((std.mem.eql(u8, token, "green") or std.mem.eql(u8, token, "green;")) and currCount > result.green) {
            result.green = currCount;
        }
        if ((std.mem.eql(u8, token, "blue") or std.mem.eql(u8, token, "blue;")) and currCount > result.blue) {
            result.blue = currCount;
        }
    }
    return result;
}

pub fn aocDay2() !i64 {
    const file = fs.cwd().openFile("input/day_2_input", .{}) catch |err| label: {
        std.debug.print("unable to open file: {}\n", .{err});
        const stderr = std.io.getStdErr();
        break :label stderr;
    };

    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [2048]u8 = undefined;
    var result: i64 = 0;
    var fewestNumbers: i64 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const game = try getGameResult(line);
        if (game.isPossible) {
            result += game.id;
        }
        const numbers = try getFewestNumbers(line);
        fewestNumbers += numbers.red * numbers.green * numbers.blue;
    }

    return fewestNumbers;
}

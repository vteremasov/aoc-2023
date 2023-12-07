const std = @import("std");
const utils = @import("../utils/utils.zig");
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;
const print = std.debug.print;
const fs = std.fs;
const ascii = std.ascii;
const mem = std.mem;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

const Range = struct {
    dest: i128,
    sourse: i128,
    rep: i128,

    pub fn init(dest: i128, source: i128, rep: i128) Range {
        return Range{
            .dest = dest,
            .sourse = source,
            .rep = rep,
        };
    }

    pub fn sourceInRange(self: Range, num: i128) bool {
        return self.sourse <= num and num <= self.sourse + self.rep - 1;
    }
    pub fn getDestInRange(self: Range, sourse: i128) !i128 {
        if (self.sourceInRange(sourse)) {
            var diff: i128 = sourse - self.sourse;
            return self.dest + diff;
        }

        return sourse * 1;
    }
};

test "Range" {
    const r = Range.init(52, 50, 48);
    try std.testing.expectEqual(true, r.sourceInRange(55));
    try std.testing.expect(57 == try r.getDestInRange(55));
}

var SEED_TO_SOIL_MAP = "seed-to-soil".*;
var SOIL_TO_FERTILIZERS = "soil-to-fertilizer".*;
var FERTILIZERS_TO_WATER = "fertilizer-to-water".*;
var WATER_TO_LIGHT = "water-to-light".*;
var LIGHT_TO_TEMP = "light-to-temperature".*;
var TEMP_TO_HIMUD = "temperature-to-humidity".*;
var HUMI_TO_LOCATION = "humidity-to-location".*;

pub fn mapStoD(sourse: i128, map: ?ArrayList(Range)) !i128 {
    var result: i128 = -1;
    if (map) |seedMap| {
        for (seedMap.items) |sm| {
            if (sm.sourceInRange(sourse)) {
                result = try sm.getDestInRange(sourse);
            }
        }
        if (result == -1) {
            result = sourse;
        }
    }
    return result;
}

pub fn getSeedRanges(seeds: ArrayList(i128)) !ArrayList(i128) {
    var result = ArrayList(i128).init(allocator);
    var counter: usize = 0;

    while (counter < seeds.items.len) {
        var s = seeds.items[counter];
        var e = seeds.items[counter + 1];
        print("from {} ops: {}\n", .{ s, e });
        for (0..@intCast(e)) |seed| {
            try result.append(s + seed);
        }
        counter += 2;
    }

    return result;
}

test "getSeedRanges" {
    var data = ArrayList(i128).init(allocator);
    defer data.deinit();

    try data.append(79);
    try data.append(14);

    var res1 = try getSeedRanges(data);
    try std.testing.expect(res1.items.len == 14);
    try std.testing.expect(res1.items[0] == 79);
}

pub fn getLocations(seeds: ArrayList(i128), data: ArrayList(ArrayList(u8))) !i128 {
    var result: i128 = std.math.maxInt(i128);
    defer seeds.deinit();
    var ranges = try buildRanges(data);
    var progress: usize = 0;

    for (seeds.items, 0..) |seed, i| {
        var optSeedMap = ranges.get(&SEED_TO_SOIL_MAP);
        var soil: i128 = try mapStoD(seed, optSeedMap);
        var fertMap = ranges.get(&SOIL_TO_FERTILIZERS);
        var fert = try mapStoD(soil, fertMap);
        var waterMap = ranges.get(&FERTILIZERS_TO_WATER);
        var water = try mapStoD(fert, waterMap);
        var lightMap = ranges.get(&WATER_TO_LIGHT);
        var light = try mapStoD(water, lightMap);
        var tempMap = ranges.get(&LIGHT_TO_TEMP);
        var temp = try mapStoD(light, tempMap);
        var humidMap = ranges.get(&TEMP_TO_HIMUD);
        var humid = try mapStoD(temp, humidMap);
        var locationMap = ranges.get(&HUMI_TO_LOCATION);
        var location = try mapStoD(humid, locationMap);
        const newProgress = i * 100 / seeds.items.len;

        if (newProgress != progress and newProgress % 5 == 0) {
            progress = newProgress;
            print("progress: {}%\n", .{progress});
        }

        if (location < result) {
            result = location;
        }
    }

    return result;
}

pub fn buildRanges(data: ArrayList(ArrayList(u8))) !StringHashMap(ArrayList(Range)) {
    var maps = StringHashMap(ArrayList(Range)).init(allocator);
    var key: []u8 = undefined;
    for (data.items) |line| {
        if (mem.indexOf(u8, line.items, &SEED_TO_SOIL_MAP) != null) {
            key = &SEED_TO_SOIL_MAP;
        }
        if (mem.indexOf(u8, line.items, &SOIL_TO_FERTILIZERS) != null) {
            key = &SOIL_TO_FERTILIZERS;
        }
        if (mem.indexOf(u8, line.items, &FERTILIZERS_TO_WATER) != null) {
            key = &FERTILIZERS_TO_WATER;
        }
        if (mem.indexOf(u8, line.items, &WATER_TO_LIGHT) != null) {
            key = &WATER_TO_LIGHT;
        }
        if (mem.indexOf(u8, line.items, &LIGHT_TO_TEMP) != null) {
            key = &LIGHT_TO_TEMP;
        }
        if (mem.indexOf(u8, line.items, &TEMP_TO_HIMUD) != null) {
            key = &TEMP_TO_HIMUD;
        }
        if (mem.indexOf(u8, line.items, &HUMI_TO_LOCATION) != null) {
            key = &HUMI_TO_LOCATION;
        }

        if (line.items.len > 0 and ascii.isDigit(line.items[0]) and !mem.eql(u8, key, undefined)) {
            const nums = try utils.getNumbersFromSlise(i128, line.items, allocator);
            defer nums.deinit();
            var arr = maps.get(key) orelse ArrayList(Range).init(allocator);
            try arr.append(Range.init(nums.items[0], nums.items[1], nums.items[2]));
            try maps.put(key, arr);
        }
    }

    return maps;
}

pub fn aocDay5() !i128 {
    const file = fs.cwd().openFile("input/day_5_input", .{}) catch |err| label: {
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

    var seedsIt = mem.splitScalar(u8, data.items[0].items, ':');
    _ = seedsIt.next(); // skip `Seeds`
    var seeds1 = try utils.getNumbersFromSlise(i128, seedsIt.next() orelse "", allocator);
    defer seeds1.deinit();

    var seeds2 = try getSeedRanges(seeds1);
    defer seeds2.deinit();

    // const location1 = try getLocations(seeds1, data);
    const location2 = try getLocations(seeds2, data);

    return location2;
}

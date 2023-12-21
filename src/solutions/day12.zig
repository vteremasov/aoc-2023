const std = @import("std");
const utils = @import("../utils/utils.zig");
const mem = std.mem;
const print = std.debug.print;
const ArrayList = std.ArrayList;
var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = aa.allocator();

fn allFit(line: []i64, target_runs: []usize) !bool {
    const n = line.len;
    var runs = ArrayList(usize).init(allocator);

    var i: usize = 0;

    while (i < n) {
        while (i < n and line[i] == 0) i += 1;

        if (i == n) break;

        var j = i;
        var c: usize = 0;

        while (j < n and line[j] != 0) {
            j += 1;
            c += 1;
        }

        try runs.append(c);
        i = j;
    }

    if (runs.items.len == target_runs.len) {
        for (runs.items, 0..) |r, ind| {
            if (r != target_runs[ind]) return false;
        }

        return true;
    }

    return false;
}

fn ways(s: []const u8, target_runs: []usize) !i64 {
    var l = ArrayList(i64).init(allocator);
    var idxs = ArrayList(usize).init(allocator);
    defer l.deinit();
    defer idxs.deinit();

    for (s, 0..) |x, i| {
        switch (x) {
            '.' => try l.append(0),
            '?' => {
                try l.append(-1);
                try idxs.append(i);
            },
            '#' => try l.append(1),
            else => unreachable,
        }
    }

    var count: i64 = 0;

    for (0..(@as(usize, 1) << @as(u6, @intCast(idxs.items.len)))) |mask| {
        var l_copy = try l.clone();
        for (idxs.items, 0..) |idx, i| {
            if (mask & (@as(usize, 1) << @as(u6, @intCast(i))) != 0) l_copy.items[idx] = 0 else l_copy.items[idx] = 1;
        }

        if (try allFit(l_copy.items, target_runs)) count += 1;
    }

    return count;
}

pub fn part1() !i64 {
    var data = try utils.getData("input/day_12_input", allocator);

    var counter: i64 = 0;
    var progress = std.Progress{};
    const node = progress.start("day 12 part 1", data.items.len);
    defer node.end();

    for (data.items) |line| {
        var lint_it = mem.splitScalar(u8, line.items, ' ');
        var springs = lint_it.next() orelse "";
        var target = try utils.getNumbersFromSlise(usize, lint_it.next() orelse "", allocator);

        var res = try ways(springs, target.items);
        counter += res;
        node.completeOne();
    }

    return counter;
}

fn waysDP(s: []u8, target_runs: []usize) !i64 {
    var max: usize = 0;
    for (target_runs) |num| {
        if (num > max) max = num;
    }
    var n = s.len;
    var m = target_runs.len;

    var dp_matrix = ArrayList(ArrayList(ArrayList(i64))).init(allocator);

    for (0..n) |_| {
        var n_list = ArrayList(ArrayList(i64)).init(allocator);
        for (0..m) |_| {
            var m_list = ArrayList(i64).init(allocator);
            for (0..max + 1) |_| {
                try m_list.append(0);
            }
            try n_list.append(m_list);
        }
        try dp_matrix.append(n_list);
    }

    for (0..n) |i| {
        const x = s[i];
        for (0..m) |j| {
            for (0..target_runs[j] + 1) |k| {
                //base
                if (i == 0) {
                    if (j != 0) {
                        dp_matrix.items[i].items[j].items[k] = 0;
                        continue;
                    }
                    if (x == '#') {
                        if (k != 1) {
                            dp_matrix.items[i].items[j].items[k] = 0;
                            continue;
                        }
                        dp_matrix.items[i].items[j].items[k] = 1;
                        continue;
                    }
                    if (x == '.') {
                        if (k != 0) {
                            dp_matrix.items[i].items[j].items[k] = 0;
                            continue;
                        }
                        dp_matrix.items[i].items[j].items[k] = 1;
                        continue;
                    }
                    if (x == '?') {
                        if (k > 1) {
                            dp_matrix.items[i].items[j].items[k] = 0;
                            continue;
                        }
                        dp_matrix.items[i].items[j].items[k] = 1;
                        continue;
                    }
                }
                // process
                var ans_work: i64 = 0;

                if (k != 0) {
                    ans_work = 0;
                } else if (j > 0) {
                    std.debug.assert(k == 0);
                    ans_work = dp_matrix.items[i - 1].items[j - 1].items[target_runs[j - 1]];
                    ans_work += dp_matrix.items[i - 1].items[j].items[0];
                } else {
                    const count = mem.count(u8, s[0..i], "#");
                    ans_work = if (count == 0) 1 else 0;
                }

                var ans_brok: i64 = 0;

                if (k != 0) {
                    ans_brok = dp_matrix.items[i - 1].items[j].items[k - 1];
                }

                switch (x) {
                    '.' => dp_matrix.items[i].items[j].items[k] = ans_work,
                    '#' => dp_matrix.items[i].items[j].items[k] = ans_brok,
                    else => dp_matrix.items[i].items[j].items[k] = ans_work + ans_brok,
                }
            }
        }
    }

    return dp_matrix.items[n - 1].items[dp_matrix.items[n - 1].items.len - 1].items[0];
}

pub fn part2() !i64 {
    var data = try utils.getData("input/day_12_input", allocator);

    var counter: i64 = 0;
    var progress = std.Progress{};
    const node = progress.start("day 12 part 2", data.items.len);
    defer node.end();

    for (data.items) |line| {
        var lint_it = mem.splitScalar(u8, line.items, ' ');
        var springs = lint_it.next().?;
        var target = try utils.getNumbersFromSlise(usize, lint_it.next().?, allocator);
        var target_extended = ArrayList(usize).init(allocator);
        var springs_extended = try allocator.alignedAlloc(u8, null, springs.len * 5 + 5);
        const slice = try target.toOwnedSlice();
        for (0..5) |i| {
            var start = if (i == 0) i else springs.len * i + i;
            var end = if (i == 0) springs.len else springs.len + start;

            if (i != 4) {
                springs_extended[end] = '?';
            }

            @memcpy(springs_extended[start..end], springs);

            try target_extended.appendSlice(slice);
        }
        springs_extended[springs_extended.len - 1] = '.';
        try target_extended.append(0);

        counter += try waysDP(springs_extended, target_extended.items);
        node.completeOne();
    }

    return counter;
}

const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;
const indexOfMax = std.mem.indexOfMax;
const max = std.mem.max;
const print = std.debug.print;
const splitScaler = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;
const pow = std.math.pow;

const Solutions = struct { sol1: usize = 0, sol2: usize = 0 };
const puzzel_input = @embedFile("input/day05");
const trimed_input = std.mem.trim(u8, puzzel_input, "\n");

const test_input =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
;

const Range = struct {
    start: usize,
    end: usize,

    fn containes(self: Range, value: usize) bool {
        return value >= self.start and value <= self.end;
    }
};

const Database = struct {
    fresh_ingredients: ArrayList(Range),
    available_ingredients: ArrayList(usize),

    fn count_fresh_ingredients(self: Database) usize {
        var count: usize = 0;
        for (self.available_ingredients.items) |ingredient| {
            for (self.fresh_ingredients.items) |range| {
                if (range.containes(ingredient)) {
                    count += 1;
                    break;
                }
            }
        }
        return count;
    }
};

pub fn parse_input(input: []const u8) !Database {
    var db = Database{
        .fresh_ingredients = ArrayList(Range).empty,
        .available_ingredients = ArrayList(usize).empty,
    };

    var lines = splitScaler(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        const range_values = std.mem.cut(u8, line, "-");
        const start = try parseInt(usize, range_values.?.@"0", 10);
        const end = try parseInt(usize, range_values.?.@"1", 10);
        try db.fresh_ingredients.append(allocator, Range{ .start = start, .end = end });
    }
    while (lines.next()) |line| {
        const indgredient = try parseInt(usize, line, 10);
        try db.available_ingredients.append(allocator, indgredient);
    }

    return db;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    const db = try parse_input(trimed_input);
    solutions.sol1 = db.count_fresh_ingredients();
    solutions.sol2 = 0;
    return solutions;
}

test "parse_input" {
    const db = try parse_input(test_input);
    try std.testing.expectEqual(4, db.fresh_ingredients.items.len);
    try std.testing.expectEqual(6, db.available_ingredients.items.len);
}

test "range" {
    const range: Range = .{ .start = 8, .end = 34 };
    try std.testing.expect(range.containes(8));
    try std.testing.expect(range.containes(10));
    try std.testing.expect(!range.containes(35));
    try std.testing.expect(range.containes(34));
}

test "sample_input" {
    const db = try parse_input(test_input);
    try std.testing.expectEqual(3, db.count_fresh_ingredients());
}

const std = @import("std");
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const splitScaler = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;

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

const Range_Point_Type = enum { Start, End };

const Range_Point = struct {
    index: usize,
    type: Range_Point_Type,

    fn lessThan(context: void, a: Range_Point, b: Range_Point) bool {
        _ = context;
        if (a.index == b.index) {
            return a.type == Range_Point_Type.Start and b.type == Range_Point_Type.End;
        }
        return a.index < b.index;
    }
};

const Database = struct {
    fresh_ranges: ArrayList(Range_Point),
    available_ingredients: ArrayList(usize),

    fn add_range(self: *Database, start: usize, end: usize) !void {
        const start_point = Range_Point{
            .index = start,
            .type = Range_Point_Type.Start,
        };
        const end_point = Range_Point{
            .index = end,
            .type = Range_Point_Type.End,
        };
        try self.fresh_ranges.append(allocator, start_point);
        try self.fresh_ranges.append(allocator, end_point);
        std.mem.sort(Range_Point, self.fresh_ranges.items, {}, Range_Point.lessThan);

        var fresh: usize = 0;
        var indexs_to_trim = ArrayList(usize).empty;

        for (self.fresh_ranges.items, 0..) |range_item, i| {
            switch (range_item.type) {
                Range_Point_Type.Start => {
                    fresh += 1;
                    if (fresh > 1) {
                        try indexs_to_trim.append(allocator, i);
                    }
                },
                Range_Point_Type.End => {
                    fresh -= 1;
                    if (fresh > 0) {
                        try indexs_to_trim.append(allocator, i);
                    }
                },
            }
        }

        std.mem.reverse(usize, indexs_to_trim.items);

        for (indexs_to_trim.items) |i| {
            _ = self.fresh_ranges.orderedRemove(i);
        }
    }

    fn is_fresh(self: Database, ingredient: usize) bool {
        var low: usize = 0;
        var high: usize = 0;
        var fresh: bool = false;

        for (self.fresh_ranges.items) |range_point| {
            if (ingredient == range_point.index) return true;

            low = high;
            high = range_point.index;

            if (low < ingredient and ingredient < high) {
                return fresh;
            }

            if (range_point.type == Range_Point_Type.Start) {
                fresh = true;
            } else {
                fresh = false;
            }
        }

        return fresh;
    }

    fn count_fresh_ingredients(self: Database) usize {
        var count: usize = 0;
        for (self.available_ingredients.items) |ingredient| {
            if (self.is_fresh(ingredient)) {
                count += 1;
            }
        }
        return count;
    }

    fn fresh_capacity(self: Database) usize {
        var low: usize = 0;
        var high: usize = 0;
        var fresh: bool = false;
        var capacity: usize = 0;

        for (self.fresh_ranges.items) |range_point| {
            low = high;
            high = range_point.index;

            if (fresh) {
                capacity += ((high - low) + 1);
            }

            if (range_point.type == Range_Point_Type.Start) {
                fresh = true;
            } else {
                fresh = false;
            }
        }

        return capacity;
    }
};

pub fn parse_input(input: []const u8) !Database {
    var db = Database{
        .fresh_ranges = ArrayList(Range_Point).empty,
        .available_ingredients = ArrayList(usize).empty,
    };

    var lines = splitScaler(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break;
        const range_values = std.mem.cut(u8, line, "-");
        const start = try parseInt(usize, range_values.?.@"0", 10);
        const end = try parseInt(usize, range_values.?.@"1", 10);
        try db.add_range(start, end);
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
    solutions.sol2 = db.fresh_capacity();
    return solutions;
}

test "parse_input" {
    const db = try parse_input(test_input);
    try std.testing.expectEqual(6, db.available_ingredients.items.len);
    try std.testing.expectEqual(4, db.fresh_ranges.items.len);
}

test "sample_input" {
    const db = try parse_input(test_input);
    // Part 1
    try std.testing.expectEqual(3, db.count_fresh_ingredients());
    // Part 2
    try std.testing.expectEqual(14, db.fresh_capacity());
}

test "range_point" {
    const a = Range_Point{
        .index = 4,
        .type = Range_Point_Type.Start,
    };
    const b = Range_Point{
        .index = 7,
        .type = Range_Point_Type.End,
    };
    const c = Range_Point{
        .index = 7,
        .type = Range_Point_Type.Start,
    };
    try std.testing.expect(Range_Point.lessThan({}, a, b));
    try std.testing.expect(Range_Point.lessThan({}, c, b));
    try std.testing.expect(!Range_Point.lessThan({}, b, c));
}

test "is_fresh" {
    const db = try parse_input(test_input);
    try std.testing.expect(!db.is_fresh(1));
    try std.testing.expect(db.is_fresh(5));
    try std.testing.expect(!db.is_fresh(8));
    try std.testing.expect(db.is_fresh(11));
    try std.testing.expect(db.is_fresh(17));
    try std.testing.expect(!db.is_fresh(32));
}

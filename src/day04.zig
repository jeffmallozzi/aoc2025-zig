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
const input = @embedFile("input/day04");
const test_input =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

const Location = struct { row: usize, col: usize };

const Spot = struct {
    contents: u8 = '.',
    countNeighors: usize = 0,
};

var wareHouse: std.AutoHashMap(Location, Spot) = .init(allocator);

fn solution1(gridInput: []const u8) !usize {
    var accessableRolls: usize = 0;

    var rowIndex: usize = 0;
    var rows = splitScaler(u8, gridInput, '\n');
    while (rows.next()) |row| {
        for (0..row.len) |colIndex| {
            wareHouse.put(.{ .row = rowIndex, .col = colIndex }, .{
                .contents = row[colIndex],
            });
        }
        rowIndex += 1;
    }

    return accessableRolls;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    solutions.sol1 = try solution1(input);
    solutions.sol2 = 0;
    return solutions;
}

test "Test Solution 1" {
    try std.testing.expectEqual(13, solution1(test_input));
}

// test "Test Solution 2" {
//     try std.testing.expectEqual(3121910778619, solution(test_input, 12));
// }

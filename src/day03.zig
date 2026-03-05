const std = @import("std");
const Solutions = struct { sol1: usize = 0, sol2: usize = 0 };
const input = @embedFile("input/day03");
const test_input =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;
const indexOfMax = std.mem.indexOfMax;
const max = std.mem.max;
const print = std.debug.print;
const splitScaler = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;
const pow = std.math.pow;

fn getJoltage(bank: []const u8, size: usize) !usize {
    //try expect(bank.len >= size);

    if (bank.len == size) {
        return try parseInt(usize, bank, 10);
    }

    const index = indexOfMax(u8, bank[0 .. bank.len - (size - 1)]);
    const value = try parseInt(usize, bank[index .. index + 1], 10);

    if (size == 1) {
        return value;
    }

    return (value * (pow(usize, 10, size - 1))) + try getJoltage(bank[index + 1 ..], size - 1);
}

fn solution(ratings: []const u8, size: usize) !usize {
    var result: usize = 0;
    var bankIter = splitScaler(u8, ratings, '\n');
    while (bankIter.next()) |bank| {
        if (bank.len < 1) {
            continue;
        }

        result += try getJoltage(bank, size);
    }

    return result;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    solutions.sol1 = try solution(input, 2);
    solutions.sol2 = try solution(input, 12);
    return solutions;
}

test "Test Solution 1" {
    try std.testing.expectEqual(357, solution(test_input, 2));
}

test "Test Solution 2" {
    try std.testing.expectEqual(3121910778619, solution(test_input, 12));
}

test "Joltage" {
    try std.testing.expectEqual(12, getJoltage("12", 2));
    try std.testing.expectEqual(98, getJoltage("987654321111111", 2));
    try std.testing.expectEqual(999, getJoltage("99000900", 3));
}

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
const puzzle_input = @embedFile("input/day06");
const trimed_input = std.mem.trim(u8, puzzle_input, "\n ");
const test_input =
    \\123 328  51 64
    \\ 45 64  387 23
    \\  6 98  215 314
    \\*   +   *   +
;

const Problem = struct {
    numbers: ArrayList(usize),
    operator: u8,
};

fn parse_input(input: []const u8) ArrayList(Problem) {
    // Need to split on varying amout of spaces ...
    const lines = std.mem.split
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    solutions.sol1 = 0;
    solutions.sol2 = 0;
    return solutions;
}

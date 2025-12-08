const std = @import("std");
const aoc2025_zig = @import("aoc2025_zig");
const days = @import("day01.zig");

pub fn main() !void {
    const solutions = try days.get_solutions();
    std.debug.print("Solution 1: {d}\n", .{solutions.sol1});
    std.debug.print("solution 2: {d}\n", .{solutions.sol2});
}

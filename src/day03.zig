const std = @import("std");
const Solutions = struct { sol1: usize = 0, sol2: usize = 0 };
const input = @embedFile("input/day03");
//const inputTrimed = std.mem.trim(u8, input, " \n");
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
const print = std.debug.print;
const splitScaler = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;

fn solution1(ratings: []const u8) !usize {
    var result: usize = 0;
    var bankIter = splitScaler(u8, ratings, '\n');
    while (bankIter.next()) |bank| {
        if (bank.len < 2) {
            continue;
        }
        print("Checking bank: {s}\n", .{bank});
        const tensIndex = indexOfMax(u8, bank[0 .. bank.len - 1]);
        print("Tens index: {d}\n", .{tensIndex});
        const onesIndex = indexOfMax(u8, bank[tensIndex + 1 ..]) + tensIndex + 1;
        print("Ones index: {d}\n", .{onesIndex});
        const joltage = [2]u8{ bank[tensIndex], bank[onesIndex] };
        print("Joltage string: {s}\n", .{joltage});
        result += try parseInt(u8, &joltage, 10);
    }

    return result;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    solutions.sol1 = try solution1(input);
    solutions.sol2 = 0;
    return solutions;
}

test "Test Solution 1" {
    try std.testing.expectEqual(357, solution1(test_input));
}

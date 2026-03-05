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
const max = std.mem.max;
const print = std.debug.print;
const splitScaler = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;
const pow = std.math.pow;


fn getJoltage(bank: []const u8, size: usize) !usize {
    //try expect(bank.len >= size);
    print("Geting joltage of size {d} from bank: {s}\n", .{size, bank});

    if (bank.len == size) {
        print("Bank: {s} is of size: {d}\n", .{bank,size});
        return try parseInt(u8, bank, 10);
    }

    const index = indexOfMax(u8, bank[0..bank.len - (size-1)]);
    print("The index of the max value is {d}\n", .{index});
    const value = try parseInt(u8, bank[index..index+1], 10);
    print("The max value is {d}\n", .{value});

    if (size == 1) {
        print("Bank is size 1 so returning value {d}\n", .{value});
        return value;
    }


    return (value * (std.mat)) + try getJoltage(bank[index+1..], size-1);

}

fn solution1(ratings: []const u8) !usize {
    var result: usize = 0;
    var bankIter = splitScaler(u8, ratings, '\n');
    while (bankIter.next()) |bank| {
        if (bank.len < 1) {
            continue;
        }

        result += try getJoltage(bank, 2);

        // const tensIndex = indexOfMax(u8, bank[0 .. bank.len - 1]);
        // const onesIndex = indexOfMax(u8, bank[tensIndex + 1 ..]) + tensIndex + 1;
        // const joltage = [2]u8{ bank[tensIndex], bank[onesIndex] };
        // result += try parseInt(u8, &joltage, 10);
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

test "Joltage" {
    try std.testing.expectEqual(12, getJoltage("12", 2));
    try std.testing.expectEqual(98, getJoltage("987654321111111", 2));
}

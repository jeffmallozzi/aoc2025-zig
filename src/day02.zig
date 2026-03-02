const std = @import("std");
const Solutions = struct { sol1: i32 = 0, sol2: i32 = 0 };
const input = @embedFile("input/day02");
const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;
const print = std.debug.print;
const splitScaler = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;

fn solution1(idRanges: []const u8) !i32 {
    var rangeIter = splitScaler(u8, idRanges, ',');
    var result: i32 = 0;

    while (rangeIter.next()) |range| {
        var lowHigh = splitScaler(u8, range, '-');
        const low: i32 = try parseInt(i32, lowHigh.next(), u8).?;
        const high: i32 = try parseInt(i32, lowHigh.next(), u8).? + 1;

        for (low..high) |id| {
            const idString = try std.fmt.allocPrint(allocator, "{dl}", .{id});
            if (repeats(idString)) {
                result += id;
            }
        }
    }
}

fn repeats(string: []const u8) !bool {
    if (string.len < 2) {
        return false;
    }

    const mid = string.len / 2;
    if (eql(u8, string[0..mid], string[mid..])) {
        return true;
    }

    return false;
}

fn is_valid_id(id: i32) !bool {
    var id_copy = id;
    print("Checking ID: {}\n", .{id_copy});
    var digits: ArrayList(i32) = .empty;
    defer digits.deinit(allocator);

    print("Initializing ArrayList: {}\n", .{digits});

    while (id_copy > 0) {
        const digit = @rem(id_copy, 10);
        print("Inserting digit: {}\n", .{digit});
        try digits.insert(allocator, 0, digit);
        //try digits.append(allocator, digit);
        print("Digit list: {}\n", .{digits});
        id_copy -= digit;
        if (id_copy > 0) {
            id_copy = @divTrunc(id_copy, 10);
        }
    }

    print("Complete digit list: {}\n", .{digits});

    //any odd length ID is valid
    if (@rem(digits.items.len, 2) == 1) {
        print("Found and odd number of digits, returning true\n", .{});
        return true;
    }

    const mid = digits.items.len / 2;
    if (eql(i32, digits.items[0..mid], digits.items[mid..])) {
        return false;
    }

    return true;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    solutions.sol1 = 0;
    solutions.sol2 = 0;
    return solutions;
}

test "Is Valid 1" {
    try std.testing.expectEqual(is_valid_id(123), true);
    try std.testing.expectEqual(is_valid_id(1212), false);
    try std.testing.expectEqual(is_valid_id(1), true);
    //try std.testing.expectEqual(is_valid_id(0), true);
}

test "Repeats" {
    try std.testing.expectEqual(repeats("boo"), false);
    try std.testing.expectEqual(repeats("BB"), true);
}

test "Solution 1" {
    try std.testing.expectEqual(solution1(test_input), 1227775554);
}

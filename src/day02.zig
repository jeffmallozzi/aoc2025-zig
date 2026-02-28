const std = @import("std");
const Solutions = struct { sol1: i32 = 0, sol2: i32 = 0 };
const input = @embedFile("input/day02");
const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

const ArrayList = std.ArrayList;
const allocator = std.testing.allocator;

fn is_valid_id(id: i32) bool {
    var digits = ArrayList(i32).empty;
    defer digits.deinit(allocator);

    while (id > 0) {
        const digit = @rem(id, 10);
        try digits.insert(allocator, 0, digit);
        id -= digit;
        if (id > 0) {
            id = @divTrunc(id, 10);
        }
    }

    if (@rem(digits.len, 2) == 1) {
        return true;
    }

    var a = 0;
    var b = digits.len;

    while (a < digits.len) {
        if (digits[a] != digits[b]) {
            return true;
        }
        a += 1;
        b += 1;
    }

    return false;
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
}

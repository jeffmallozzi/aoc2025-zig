const std = @import("std");
const Solutions = struct { sol1: usize = 0, sol2: usize = 0 };
const input = @embedFile("input/day02");
const inputTrimed = std.mem.trim(u8, input, " \n");
const test_input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;
const print = std.debug.print;
const splitScaler = std.mem.splitScalar;
const parseInt = std.fmt.parseInt;

fn solution1(idRanges: []const u8) !usize {
    var rangeIter = splitScaler(u8, idRanges, ',');
    var result: usize = 0;

    while (rangeIter.next()) |range| {
        //print("Checking range of IDs: {s}\n", .{range});
        var lowHigh = splitScaler(u8, range, '-');
        const low: usize = try parseInt(usize, lowHigh.next().?, 10);
        const high: usize = try parseInt(usize, lowHigh.next().?, 10) + 1;

        for (low..high) |id| {
            const idString = try std.fmt.allocPrint(allocator, "{d}", .{id});
            if (try repeats(idString)) {
                result += id;
            }
        }
    }

    return result;
}

fn solution2(idRanges: []const u8) !usize {
    var rangeIter = splitScaler(u8, idRanges, ',');
    var result: usize = 0;

    while (rangeIter.next()) |range| {
        //print("Checking range of IDs: {s}\n", .{range});
        var lowHigh = splitScaler(u8, range, '-');
        const low: usize = try parseInt(usize, lowHigh.next().?, 10);
        const high: usize = try parseInt(usize, lowHigh.next().?, 10) + 1;

        for (low..high) |id| {
            const idString = try std.fmt.allocPrint(allocator, "{d}", .{id});
            for (2..idString.len + 1) |i| {
                if (try repeats_n(idString, i)) {
                    result += id;
                    break;
                }
            }
        }
    }

    return result;
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

fn repeats_n(string: []const u8, n: usize) !bool {
    if (@rem(string.len, n) != 0) {
        return false;
    }

    const width = string.len / n;

    for (1..n) |i| {
        if (!eql(u8, string[0..width], string[width * i .. width * (i + 1)])) {
            return false;
        }
    }

    return true;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    solutions.sol1 = try solution1(inputTrimed);
    solutions.sol2 = try solution2(inputTrimed);
    return solutions;
}

test "Repeats" {
    try std.testing.expectEqual(repeats("boo"), false);
    try std.testing.expectEqual(repeats("BB"), true);
}

test "Repeats N" {
    try std.testing.expectEqual(repeats_n("aaa", 3), true);
    try std.testing.expectEqual(repeats_n("abcabcabcabc", 4), true);
    try std.testing.expectEqual(repeats_n("hello", 3), false);
}

test "Solution 1" {
    try std.testing.expectEqual(solution1(test_input), 1227775554);
}

test "Solution 2" {
    try std.testing.expectEqual(solution2(test_input), 4174379265);
}

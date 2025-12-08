const std = @import("std");
const Solutions = struct { sol1: i32 = 0, sol2: i32 = 0 };
const input = @embedFile("input/day01");
const test_input =
    \\L68
    \\L30
    \\R48
    \\L5
    \\R60
    \\L55
    \\L1
    \\L99
    \\R14
    \\L82
;

const Safe = struct {
    dial: i32 = 50,
    count_clicks_past_zero: i32 = 0,
    count_stops_at_zero: i32 = 0,

    fn click_left(self: *Safe) void {
        self.dial -= 1;
        if (self.dial == -1) {
            self.dial = 99;
        }
        if (self.dial == 0) {
            self.count_clicks_past_zero += 1;
        }
    }

    fn click_right(self: *Safe) void {
        self.dial += 1;
        if (self.dial == 100) {
            self.dial = 0;
            self.count_clicks_past_zero += 1;
        }
    }

    fn turn_dial(self: *Safe, direction: Direction, number: i32) void {
        var iter = number;
        switch (direction) {
            Direction.right => {
                while (iter > 0) {
                    self.click_right();
                    iter -= 1;
                }
            },
            Direction.left => {
                while (iter > 0) {
                    self.click_left();
                    iter -= 1;
                }
            },
        }
        if (self.dial == 0) self.count_stops_at_zero += 1;
    }
};

const Direction = enum { left, right };

fn count_zeros(turns: []const u8) !Safe {
    var safe = Safe{};

    var turnsIter = std.mem.splitScalar(u8, turns, '\n');
    while (turnsIter.next()) |turn| {
        if (turn.len == 0) {
            continue;
        }
        var direction: ?Direction = null;
        if (turn[0] == 'L') {
            direction = Direction.left;
        }
        if (turn[0] == 'R') {
            direction = Direction.right;
        }

        const number = try std.fmt.parseInt(i32, turn[1..], 10);
        safe.turn_dial(direction.?, number);
    }

    return safe;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    const safe = try count_zeros(input);
    solutions.sol1 = safe.count_stops_at_zero;
    solutions.sol2 = safe.count_clicks_past_zero;
    return solutions;
}

test "test safe" {
    var test_safe = Safe{};
    test_safe.turn_dial(Direction.right, 23);
    try std.testing.expectEqual(test_safe.dial, 73);
}

test "test input" {
    const test_solutions = try count_zeros(test_input);
    try std.testing.expectEqual(test_solutions.count_stops_at_zero, 3);
    try std.testing.expectEqual(test_solutions.count_clicks_past_zero, 6);
}

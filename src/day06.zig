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

const Operator = enum { Star, Plus };

const Problem = struct {
    numbers: ArrayList(usize),
    operator: Operator,

    fn solution(self: *const Problem) usize {
        var reusult: usize = if (self.operator == Operator.Plus) 0 else 1;

        for (self.numbers.items) |num| {
            switch (self.operator) {
                Operator.Plus => {
                    reusult += num;
                },
                Operator.Star => {
                    reusult *= num;
                },
            }
        }

        return reusult;
    }
};

fn parse_input(input: []const u8) !ArrayList(Problem) {
    // Need to split on varying amout of spaces ...
    var problems: ArrayList(Problem) = .empty;
    var lines = std.mem.splitBackwardsScalar(u8, input, '\n');
    const operators = lines.first();
    var token_opps = std.mem.tokenizeAny(u8, operators, " ");

    while (token_opps.next()) |operator| {
        const opp = if (std.mem.eql(u8, operator, "*")) Operator.Star else Operator.Plus;
        const prob = Problem{
            .numbers = .empty,
            .operator = opp,
        };
        try problems.append(allocator, prob);
    }

    while (lines.next()) |line| {
        //std.debug.print("{s}\n", .{line});
        var numbers = std.mem.tokenizeAny(u8, line, " ");
        var i: usize = 0;
        while (numbers.next()) |number| : (i += 1) {
            //std.debug.print("{s} ", .{number});
            const num = try parseInt(usize, number, 10);
            try problems.items[i].numbers.append(allocator, num);
        }
    }

    return problems;
}

pub fn sum_problems(problems: ArrayList(Problem)) usize {
    var result: usize = 0;
    for (problems.items) |problem| {
        result += problem.solution();
    }
    return result;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    const problems = try parse_input(trimed_input);
    solutions.sol1 = sum_problems(problems);
    solutions.sol2 = 0;
    return solutions;
}

test "parse_input" {
    const problems = try parse_input(test_input);
    try std.testing.expectEqual(4, problems.items.len);
}

test "problem" {
    var problem = Problem{
        .numbers = .empty,
        .operator = Operator.Plus,
    };
    try problem.numbers.append(allocator, 4);
    try problem.numbers.append(allocator, 5);
    try problem.numbers.append(allocator, 6);
    try std.testing.expectEqual(15, problem.solution());
}

test "Part_one" {
    const problems = try parse_input(test_input);
    try std.testing.expectEqual(4277556, sum_problems(problems));
}

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
const input = @embedFile("input/day04");
const test_input =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

const North: []const Direction = &.{Direction.Up};
const NorthEast: []const Direction = &.{ Direction.Up, Direction.Right };
const East: []const Direction = &.{Direction.Right};
const SouthEast: []const Direction = &.{ Direction.Right, Direction.Down };
const South: []const Direction = &.{Direction.Down};
const SouthWest: []const Direction = &.{ Direction.Down, Direction.Left };
const West: []const Direction = &.{Direction.Left};
const NorthWes: []const Direction = &.{ Direction.Left, Direction.Up };

const Location = struct { row: usize, col: usize };

const Spot = struct {
    contents: u8 = '.',
    countNeighors: usize = 0,
};

fn getNeighbor(location: Location, directions: []const Direction) !Location {
    var row = location.row;
    var col = location.col;

    for (directions) |direction| {
        switch (direction) {
            Direction.Up => {
                row = try std.math.sub(usize, row, 1);
            },
            Direction.Down => {
                row += 1;
            },
            Direction.Left => {
                col = try std.math.sub(usize, col, 1);
            },
            Direction.Right => {
                col += 1;
            },
        }
    }

    return Location{ .row = row, .col = col };
}

fn getNeighbors(location: Location) []?Location {
    var neighbors: [8]?Location = undefined;

    neighbors[0] = getNeighbor(location, North) catch null;
    neighbors[1] = getNeighbor(location, &[_]Direction{ Direction.Up, Direction.Right }) catch null;
    neighbors[2] = getNeighbor(location, &[_]Direction{Direction.Right}) catch null;
    neighbors[3] = getNeighbor(location, &[_]Direction{ Direction.Right, Direction.Down }) catch null;
    neighbors[4] = getNeighbor(location, &[_]Direction{Direction.Down}) catch null;
    neighbors[5] = getNeighbor(location, &[_]Direction{ Direction.Down, Direction.Left }) catch null;
    neighbors[6] = getNeighbor(location, &[_]Direction{Direction.Left}) catch null;
    neighbors[7] = getNeighbor(location, &[_]Direction{ Direction.Left, Direction.Up }) catch null;

    return &neighbors;
}

fn addSpot(wareHouse: *std.AutoHashMap(Location, Spot), location: Location, spot: Spot) !void {
    //try wareHouse.put(location, spot);
    var localspot = spot;
    print("Adding spot at {d},{d}\n", .{ location.row, location.col });
    if (localspot.contents == '@') {
        const neighbors = getNeighbors(location);

        for (neighbors) |neighbor| {
            if (neighbor != null) {
                print("Found neighbor at {d},{d}\n", .{ neighbor.?.row, neighbor.?.col });
                const val = wareHouse.getPtr(neighbor.?);
                if (val) |loc| {
                    if (loc.contents == '@') {
                        print("Found roll at location\n", .{});
                        loc.countNeighors += 1;
                        localspot.countNeighors += 1;
                    }
                }
            }
        }
    }
    try wareHouse.put(location, localspot);
}

fn solution1(gridInput: []const u8) !usize {
    const trimedInput = std.mem.trim(u8, gridInput, "\n");
    var warehouse: std.AutoHashMap(Location, Spot) = .init(allocator);
    var accessableRolls: usize = 0;

    var rowIndex: usize = 0;
    var rows = splitScaler(u8, trimedInput, '\n');
    while (rows.next()) |row| {
        for (row, 0..) |item, colIndex| {
            try addSpot(&warehouse, Location{ .row = rowIndex, .col = colIndex }, Spot{ .contents = item });
        }
        rowIndex += 1;
    }

    var warehouseSpots = warehouse.valueIterator();
    while (warehouseSpots.next()) |spot| {
        print("Spot contains {s}, and has {d} adjacent rolls\n", .{ &.{spot.contents}, spot.countNeighors });
        if ((spot.countNeighors < 4) and (spot.contents == '@')) {
            print("Found accessable roll\n", .{});
            accessableRolls += 1;
        }
    }

    return accessableRolls;
}

pub fn get_solutions() !Solutions {
    var solutions = Solutions{};
    solutions.sol1 = try solution1(input);
    solutions.sol2 = 0;
    return solutions;
}

test "Test Solution 1" {
    try std.testing.expectEqual(13, solution1(test_input));
}

// test "Test Solution 2" {
//     try std.testing.expectEqual(3121910778619, solution(test_input, 12));
// }

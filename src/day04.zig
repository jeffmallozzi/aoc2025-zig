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
const NorthWest: []const Direction = &.{ Direction.Left, Direction.Up };

const Location = struct { row: usize, col: usize };

const Neighbors = struct {
    north: ?Location = null,
    northeast: ?Location = null,
    east: ?Location = null,
    southeast: ?Location = null,
    south: ?Location = null,
    southwest: ?Location = null,
    west: ?Location = null,
    northwest: ?Location = null,
    index: usize = 0,
    fn next(self: *Neighbors) ?Location {
        while (self.index < 8) {
            switch (self.index) {
                0 => {
                    self.index += 1;
                    if (self.north) |_| {
                        return self.north;
                    }
                },
                1 => {
                    self.index += 1;
                    if (self.northeast != null) {
                        return self.northeast;
                    }
                },
                2 => {
                    self.index += 1;
                    if (self.east != null) {
                        return self.east;
                    }
                },
                3 => {
                    self.index += 1;
                    if (self.southeast != null) {
                        return self.southeast;
                    }
                },
                4 => {
                    self.index += 1;
                    if (self.south != null) {
                        return self.south;
                    }
                },
                5 => {
                    self.index += 1;
                    if (self.southwest != null) {
                        return self.southwest;
                    }
                },
                6 => {
                    self.index += 1;
                    if (self.west != null) {
                        return self.west;
                    }
                },
                7 => {
                    self.index += 1;
                    if (self.northwest != null) {
                        return self.northwest;
                    }
                },
                else => {
                    return null;
                },
            }
        }
        return null;
    }
};

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

fn getNeighbors(location: Location) Neighbors {
    var neighbors: Neighbors = .{};

    neighbors.north = getNeighbor(location, North) catch null;
    neighbors.northeast = getNeighbor(location, NorthEast) catch null;
    neighbors.east = getNeighbor(location, East) catch null;
    neighbors.southeast = getNeighbor(location, SouthEast) catch null;
    neighbors.south = getNeighbor(location, South) catch null;
    neighbors.southwest = getNeighbor(location, SouthWest) catch null;
    neighbors.west = getNeighbor(location, West) catch null;
    neighbors.northwest = getNeighbor(location, NorthWest) catch null;

    return neighbors;
}

fn addSpot(wareHouse: *std.AutoHashMap(Location, Spot), location: Location, spot: Spot) !void {
    //try wareHouse.put(location, spot);
    var localspot = spot;
    //print("Adding spot at {d},{d}\n", .{ location.row, location.col });
    if (localspot.contents == '@') {
        var neighbors = getNeighbors(location);

        while (neighbors.next()) |neighbor| {
            //print("Found neighbor at {d},{d}\n", .{ neighbor.row, neighbor.col });
            const val = wareHouse.getPtr(neighbor);
            if (val) |loc| {
                if (loc.contents == '@') {
                    //print("Found roll at location\n", .{});
                    loc.countNeighors += 1;
                    localspot.countNeighors += 1;
                }
            }
        }
    }
    try wareHouse.put(location, localspot);
}

fn removeRoll(warehouse: *std.AutoHashMap(Location, Spot), location: Location) !void {
    const itemPtr = try warehouse.getPtr(location);
    if (itemPtr) |item| {
        if (item.contents == '@') {
            if (item.countNeigbors > 4) {
                var neighbors = getNeighbors(location);
                while (neighbors.next()) |neighbor| {
                    const neighborptr = try warehouse.getPtr(neighbor);
                    neighborptr.?.countNeighors -= 1;
                }
                item.contents = '.';
            }
        }
    }
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
        //print("Spot contains {s}, and has {d} adjacent rolls\n", .{ &.{spot.contents}, spot.countNeighors });
        if ((spot.countNeighors < 4) and (spot.contents == '@')) {
            //print("Found accessable roll\n", .{});
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

test "Get Neighbor" {
    try std.testing.expectError(error.Overflow, getNeighbor(Location{ .row = 0, .col = 0 }, North));
    try std.testing.expectError(error.Overflow, getNeighbor(Location{ .row = 0, .col = 0 }, West));
    try std.testing.expectError(error.Overflow, getNeighbor(Location{ .row = 0, .col = 0 }, NorthWest));
    try std.testing.expectEqual(Location{ .row = 0, .col = 1 }, getNeighbor(Location{ .row = 1, .col = 1 }, North));
    try std.testing.expectEqual(Location{ .row = 2, .col = 1 }, getNeighbor(Location{ .row = 1, .col = 1 }, South));
    try std.testing.expectEqual(Location{ .row = 1, .col = 2 }, getNeighbor(Location{ .row = 1, .col = 1 }, East));
    try std.testing.expectEqual(Location{ .row = 1, .col = 0 }, getNeighbor(Location{ .row = 1, .col = 1 }, West));
    try std.testing.expectEqual(Location{ .row = 0, .col = 2 }, getNeighbor(Location{ .row = 1, .col = 1 }, NorthEast));
    try std.testing.expectEqual(Location{ .row = 2, .col = 2 }, getNeighbor(Location{ .row = 1, .col = 1 }, SouthEast));
    try std.testing.expectEqual(Location{ .row = 0, .col = 0 }, getNeighbor(Location{ .row = 1, .col = 1 }, NorthWest));
    try std.testing.expectEqual(Location{ .row = 2, .col = 0 }, getNeighbor(Location{ .row = 1, .col = 1 }, SouthWest));
}

test "Get Neighbors" {
    const output: Neighbors = .{ .north = null, .northeast = null, .east = Location{ .row = 0, .col = 1 }, .southeast = Location{ .row = 1, .col = 1 }, .south = Location{ .row = 1, .col = 0 }, .southwest = null, .west = null, .northwest = null };
    try std.testing.expectEqual(output, getNeighbors(Location{ .row = 0, .col = 0 }));
}

test "Test Solution 1" {
    try std.testing.expectEqual(13, solution1(test_input));
}

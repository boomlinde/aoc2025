const std = @import("std");

const input = @embedFile("inputs/1");

pub fn main() anyerror!void {
    var dial: i32 = 50;
    var current: i32 = 0;
    var dir: i32 = 1;

    var stops: usize = 0;
    var crossings: usize = 0;

    for (input) |b| {
        switch (b) {
            'L' => dir = -1,
            'R' => dir = 1,
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => {
                current = current * 10 + b - '0';
            },
            '\n' => if (current != 0) {
                turn(&dial, &stops, &crossings, current * dir);
                current = 0;
            },
            else => unreachable,
        }
    }

    std.debug.print("{}\n{}\n", .{ stops, crossings });
}

fn turn(dial: *i32, stops: *usize, crossings: *usize, change: i32) void {
    const old = dial.*;
    const new = @mod(old + change, 100);

    const sign: i32 = if (change > 0) 1 else -1;
    const signed_revs = @as(i32, @intCast(@abs(change) / 100)) * sign;
    const sum = old + change - signed_revs * 100;
    const cross = old != 0 and (sum >= 100 or sum < 0 or new == 0);

    crossings.* += @abs(signed_revs) + @as(usize, if (cross) 1 else 0);
    dial.* = new;
    if (new == 0) stops.* += 1;
}

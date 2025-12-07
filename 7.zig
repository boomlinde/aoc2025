const std = @import("std");

const input = @embedFile("inputs/7");

const cell_visited = std.math.maxInt(usize) - 3;
const cell_split = std.math.maxInt(usize) - 2;
const cell_empty = std.math.maxInt(usize) - 1;
const cell_linebreak = std.math.maxInt(usize);

const Iter = std.mem.SplitIterator(usize, .scalar);
const State = std.meta.Tuple(&.{ Iter, usize });

pub fn main() anyerror!void {
    var tmp: [input.len]usize = undefined;

    std.debug.print("{}\n{}\n", .{ p1(genMap(&tmp)), p2(genMap(&tmp)) });
}

fn genMap(out: *[input.len]usize) State {
    var start_x: usize = 0;
    for (input, 0..) |b, i| switch (b) {
        '\n' => out[i] = cell_linebreak,
        '.' => out[i] = cell_empty,
        '^' => out[i] = cell_split,
        'S' => {
            out[i] = cell_empty;
            start_x = i;
        },
        else => unreachable,
    };
    return .{ std.mem.splitScalar(usize, out, cell_linebreak), start_x };
}

fn p1(state: State) usize {
    var iter = state[0];
    const x = state[1];
    while (iter.next()) |line| {
        if (line.len == 0) return 0;
        if (line[x] == cell_visited) return 0;
        if (line[x] == cell_split) {
            @constCast(line)[x] = cell_visited;
            return 1 + p1(.{ iter, x - 1 }) + p1(.{ iter, x + 1 });
        }
    }
    unreachable;
}

fn p2(state: State) usize {
    var iter = state[0];
    const x = state[1];
    while (iter.next()) |line| {
        if (line.len == 0) return 1;
        if (line[x] == cell_split) {
            const count = p2(.{ iter, x + 1 }) + p2(.{ iter, x - 1 });
            @constCast(line)[x] = count;
            return count;
        }
        if (line[x] != cell_empty) return line[x];
    }
    unreachable;
}

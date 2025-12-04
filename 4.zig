const std = @import("std");

const input = @embedFile("inputs/4");

pub fn main() anyerror!void {
    var mut_input: [input.len]u8 = undefined;
    for (input, 0..) |b, i| mut_input[i] = b;

    const initial_accessible = removeAccessible(&mut_input);

    var total = initial_accessible;
    while (true) {
        const removed = removeAccessible(&mut_input);
        if (removed == 0) break;
        total += removed;
    }

    std.debug.print("{}\n{}\n", .{ initial_accessible, total });
}

fn removeAccessible(inp: []u8) usize {
    for (0..w) |ux| for (0..h) |uy| {
        const x: isize = @intCast(ux);
        const y: isize = @intCast(uy);
        const idx = index(x, y) orelse unreachable;
        if (accessibleRoll(inp, x, y)) inp[idx] = 'x';
    };

    return removeTombstones(inp);
}

fn removeTombstones(inp: []u8) usize {
    var out: usize = 0;
    for (0..w) |ux| for (0..h) |uy| {
        const idx = index(@intCast(ux), @intCast(uy)) orelse unreachable;
        if (inp[idx] == 'x') {
            inp[idx] = '.';
            out += 1;
        }
    };
    return out;
}

fn accessibleRoll(inp: []const u8, x: isize, y: isize) bool {
    var neighbors: usize = 0;

    if (!get(inp, x, y)) return false;
    if (get(inp, x - 1, y - 1)) neighbors += 1;
    if (get(inp, x, y - 1)) neighbors += 1;
    if (get(inp, x + 1, y - 1)) neighbors += 1;
    if (get(inp, x - 1, y)) neighbors += 1;
    if (get(inp, x + 1, y)) neighbors += 1;
    if (get(inp, x - 1, y + 1)) neighbors += 1;
    if (get(inp, x, y + 1)) neighbors += 1;
    if (get(inp, x + 1, y + 1)) neighbors += 1;

    return neighbors < 4;
}

const w = w_block: {
    var iter = std.mem.splitScalar(u8, input, '\n');
    const first = iter.next() orelse unreachable;
    break :w_block first.len;
};
const h = input.len / (w + 1);

fn get(inp: []const u8, x: isize, y: isize) bool {
    const idx = index(x, y) orelse return false;
    return inp[idx] == '@' or inp[idx] == 'x';
}

fn index(x: isize, y: isize) ?usize {
    if (x < 0 or x >= w) return null;
    if (y < 0 or y >= h) return null;
    return @intCast(y * (w + 1) + x);
}

const std = @import("std");

const input = @embedFile("inputs/7");

pub fn main() anyerror!void {
    std.debug.print("{}\n{}\n", .{ solution1(), solution2() });
}

fn solution1() usize {
    var mut_input: [input.len]u8 = undefined;
    std.mem.copyForwards(u8, &mut_input, input);

    var splits: usize = 0;

    var prev_line: ?[]const u8 = null;
    var line_iter = std.mem.splitScalar(u8, &mut_input, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) break;
        defer prev_line = line;
        const prev = prev_line orelse continue;

        for (0..line.len) |ux| {
            const x: isize = @intCast(ux);
            const left_split = get(line, x - 1) == '^' and get(prev, x - 1) == '|';
            const right_split = get(line, x + 1) == '^' and get(prev, x + 1) == '|';
            const continue_beam = get(line, x) == '.' and get(prev, x) == '|';
            const below_start = get(prev, x) == 'S';

            if (left_split or right_split or continue_beam or below_start) {
                @constCast(line)[ux] = '|';
            }

            if (get(line, x) == '^' and get(prev, x) == '|') splits += 1;
        }
    }
    return splits;
}

inline fn get(line: []const u8, x: isize) u8 {
    return if (x < 0 or x >= line.len) '.' else line[@intCast(x)];
}

const cell_split = std.math.maxInt(usize) - 2;
const cell_empty = std.math.maxInt(usize) - 1;
const cell_linebreak = std.math.maxInt(usize);

fn solution2() usize {
    var dynamic_input: [input.len]usize = undefined;

    var start_x: usize = 0;
    for (input, 0..) |b, i| {
        switch (b) {
            '\n' => dynamic_input[i] = cell_linebreak,
            '.' => dynamic_input[i] = cell_empty,
            '^' => dynamic_input[i] = cell_split,
            'S' => {
                dynamic_input[i] = cell_empty;
                start_x = i;
            },
            else => unreachable,
        }
    }

    const iter = std.mem.splitScalar(usize, &dynamic_input, cell_linebreak);
    return 1 + timelines(start_x, iter);
}

const DynamicIterator = std.mem.SplitIterator(usize, .scalar);

fn timelines(x: usize, iter_const: DynamicIterator) usize {
    var iter = iter_const;
    while (iter.next()) |line| {
        if (line.len == 0) return 0;
        if (line[x] == cell_split) {
            const count = 1 + timelines(x - 1, iter) + timelines(x + 1, iter);
            @constCast(line)[x] = count;
            return count;
        }
        if (line[x] != cell_empty) return line[x];
    }
    unreachable;
}

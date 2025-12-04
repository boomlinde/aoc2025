const std = @import("std");

const input = @embedFile("inputs/2");

pub fn main() anyerror!void {
    var input_iter = std.mem.splitScalar(u8, input, ',');

    var sum_invalid: usize = 0;
    var sum_invalid2: usize = 0;

    while (input_iter.next()) |range_str| {
        var range_iter = std.mem.splitScalar(u8, range_str, '-');

        const first = range_iter.next() orelse unreachable;
        const second = range_iter.next() orelse unreachable;

        const lo = try std.fmt.parseInt(usize, first, 10);
        const hi = try std.fmt.parseInt(usize, std.mem.trimRight(u8, second, "\n"), 10);

        for (lo..hi + 1) |id| {
            if (!valid(id)) sum_invalid += id;
            if (!valid2(id)) sum_invalid2 += id;
        }
    }

    std.debug.print("{}\n{}\n", .{ sum_invalid, sum_invalid2 });
}

fn valid(id: usize) bool {
    const ndigits = if (id == 0) 1 else std.math.log10_int(id) + 1;

    if (ndigits & 1 == 1) return true;

    const div = std.math.powi(usize, 10, ndigits / 2) catch unreachable;

    const a = id / div;
    const b = id % div;

    return a != b;
}

fn valid2(id: usize) bool {
    const ndigits = if (id == 0) 1 else std.math.log10_int(id) + 1;

    if (ndigits == 1) return true;

    div_loop: for (1..ndigits) |width| {
        if (ndigits % width != 0) continue;

        const divisor = std.math.powi(usize, 10, width) catch unreachable;
        const first = id % divisor;
        var running = id / divisor;

        while (running != 0) {
            if (running % divisor != first) continue :div_loop;
            running /= divisor;
        }

        return false;
    }
    return true;
}

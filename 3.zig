const std = @import("std");

const input = @embedFile("inputs/3");

pub fn main() anyerror!void {
    var bank_iter = std.mem.splitScalar(u8, input, '\n');

    var total_joltage: usize = 0;
    var total_joltage2: usize = 0;

    while (bank_iter.next()) |bank| {
        if (bank.len == 0) continue;
        total_joltage += maxJoltage(bank, 2);
        total_joltage2 += maxJoltage(bank, 12);
    }

    std.debug.print("{}\n{}\n", .{ total_joltage, total_joltage2 });
}

fn maxJoltage(bank: []const u8, n: usize) usize {
    var out: usize = 0;
    var idx: usize = 0;

    for (0..n) |i| {
        const current = highest(bank[idx .. bank.len - (n - 1 - i)]);
        idx += current.idx + 1;
        out = out * 10 + current.digit;
    }

    return out;
}

fn highest(slice: []const u8) struct { digit: usize, idx: usize } {
    var high: isize = -1;
    var idx: usize = undefined;

    for (slice, 0..) |b, i| {
        const digit = b - '0';
        if (digit > high) {
            high = digit;
            idx = i;
        }
    }

    return .{ .digit = @intCast(high), .idx = idx };
}

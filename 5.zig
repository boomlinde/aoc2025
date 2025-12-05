const std = @import("std");

const input = @embedFile("inputs/5");

pub fn main() anyerror!void {
    var range_store: [1000]Range = undefined;
    var range_idx: usize = 0;
    var n_fresh: usize = 0;
    var n_fresh_ids: usize = 0;

    var line_iter = std.mem.splitScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) break;
        var id_iter = std.mem.splitScalar(u8, line, '-');

        const lo_str = id_iter.next() orelse unreachable;
        const hi_str = id_iter.next() orelse unreachable;
        const lo = try std.fmt.parseInt(usize, lo_str, 10);
        const hi = try std.fmt.parseInt(usize, hi_str, 10);

        if (range_idx >= range_store.len)
            @panic("too small range store");

        range_store[range_idx] = Range{ .lo = lo, .hi = hi };
        range_idx += 1;
    }

    const ranges = range_store[0..range_idx];

    avail_loop: while (line_iter.next()) |id_str| {
        if (id_str.len == 0) break;
        const id = try std.fmt.parseInt(usize, id_str, 10);

        for (ranges) |range| if (range.contains(id)) {
            n_fresh += 1;
            continue :avail_loop;
        };
    }

    for (ranges) |*range| for (ranges) |*other| {
        range.constrain(other);
    };

    for (ranges) |range| n_fresh_ids += range.count();

    std.debug.print("{}\n{}\n", .{ n_fresh, n_fresh_ids });
}

const Range = struct {
    lo: usize,
    hi: usize,
    empty: bool = false,

    pub inline fn contains(self: Range, id: usize) bool {
        return id >= self.lo and id <= self.hi;
    }

    pub fn constrain(self: *Range, other: *const Range) void {
        if (self == other) return;
        if (other.empty) return;

        const lo_inside = self.lo >= other.lo and self.lo <= other.hi;
        const hi_inside = self.hi >= other.lo and self.hi <= other.hi;

        if (hi_inside and lo_inside) {
            self.empty = true;
            return;
        }

        if (lo_inside) self.lo = other.hi + 1 else if (hi_inside) self.hi = other.lo - 1;
        if (self.lo > self.hi) self.empty = true;
    }

    pub fn count(self: *const Range) usize {
        if (self.empty) return 0;
        return self.hi - self.lo + 1;
    }
};

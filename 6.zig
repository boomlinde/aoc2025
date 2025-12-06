const std = @import("std");

const input = @embedFile("inputs/6");

pub fn main() anyerror!void {
    var sum1: usize = 0;
    var sum2: usize = 0;

    for (0..dim.cols) |col| {
        sum1 += colSum1(col);
        sum2 += colSum2(col);
    }

    std.debug.print("{}\n{}\n", .{ sum1, sum2 });
}

fn colSum1(col: usize) usize {
    var acc: usize = if (dim.spans[col].op == '*') 1 else 0;
    for (0..dim.rows) |row| {
        const trimmed = std.mem.trim(u8, get(row, col), " ");
        const val = std.fmt.parseInt(usize, trimmed, 10) catch unreachable;
        switch (dim.spans[col].op) {
            '*' => acc *= val,
            '+' => acc += val,
            else => unreachable,
        }
    }
    return acc;
}

fn colSum2(col: usize) usize {
    const span = dim.spans[col];
    const rlen = if (col == dim.cols - 1)
        span.len()
    else
        span.len() - 1;

    var acc: usize = if (dim.spans[col].op == '*') 1 else 0;
    for (0..rlen) |x| {
        var val: usize = 0;
        for (0..dim.rows) |row| {
            const s = get(row, col);
            if (s[x] >= '0' and s[x] <= '9')
                val = val * 10 + (s[x] - '0');
        }
        switch (span.op) {
            '*' => acc *= val,
            '+' => acc += val,
            else => unreachable,
        }
    }
    return acc;
}

fn get(row: usize, col: usize) []const u8 {
    const row_start = (dim.op_row.len + 1) * row;
    const row_data = input[row_start .. row_start + dim.op_row.len];
    return dim.spans[col].resolve(row_data);
}

const Span = struct {
    start: usize = 0,
    end: usize = 0,
    op: u8 = undefined,

    pub inline fn resolve(self: Span, src: []const u8) []const u8 {
        return src[self.start..self.end];
    }

    pub inline fn len(self: Span) usize {
        return self.end - self.start;
    }
};

fn spans(comptime op_row: []const u8) []const Span {
    var out: []const Span = &.{};
    var span = Span{};
    for (op_row, 0..) |c, i| {
        if (c != ' ') {
            if (span.start != span.end)
                out = append(Span, out, span);
            span.start = i;
            span.end = i;
            span.op = c;
        }
        span.end += 1;
    }
    if (span.start != span.end)
        out = append(Span, out, span);
    return out;
}

fn append(
    comptime T: type,
    comptime s: []const T,
    comptime v: T,
) []const T {
    return s ++ &[1]T{v};
}

const dim: struct {
    rows: usize,
    cols: usize,
    op_row: []const u8,
    spans: []const Span,
} = calc_dim: {
    @setEvalBranchQuota(1_000_000);
    var rows: usize = 0;

    // Find operator row and # cols
    const op_row = get_op_row_blk: {
        var row_iter = std.mem.splitScalar(u8, input, '\n');
        while (row_iter.next()) |row| {
            if (row.len == 0) continue;
            if (row[0] == '*' or row[0] == '+')
                break :get_op_row_blk row;
            rows += 1;
        }
        unreachable;
    };
    const s = spans(op_row);

    break :calc_dim .{
        .rows = rows,
        .cols = s.len,
        .op_row = op_row,
        .spans = s,
    };
};

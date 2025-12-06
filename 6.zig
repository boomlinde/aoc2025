const std = @import("std");

const input = @embedFile("inputs/6");

var width: usize = 0;
var height: usize = 0;
var cols: usize = 0;

pub fn main() anyerror!void {
    var t = Tokenizer{};
    var a: [2000]ArithStack = [1]ArithStack{.{}} ** 2000;
    var col: usize = 0;

    var sum1: usize = 0;
    var sum2: usize = 0;

    for (input, 0..) |b, i| {
        if (t.in(b)) |token| {
            if (a[col].handle(token)) |val| sum1 += val;
            col += 1;
        }
        if (b == '\n') {
            if (width == 0) width = i;
            cols = col;
            height += 1;
            col = 0;
        }
    }

    for (0..width) |ix| for (0..height + 1) |y| {
        if (t.in(get(width - 1 - ix, y))) |token| if (a[0].handle(token)) |val| {
            sum2 += val;
        };
    };

    std.debug.print("{}\n{}\n", .{ sum1, sum2 });
}

fn get(x: usize, y: usize) u8 {
    if (x >= width or y >= height) return ' ';
    return input[x + (width + 1) * y];
}

const Tokenizer = struct {
    buf: std.BoundedArray(u8, 10) = .{},

    fn in(self: *Tokenizer, c: u8) ?[]const u8 {
        if (c == ' ' or c == '\n') {
            if (self.buf.len != 0) {
                defer self.buf.len = 0;
                return self.buf.constSlice();
            }
        } else self.buf.append(c) catch unreachable;
        return null;
    }
};

const ArithStack = struct {
    buf: [10]usize = undefined,
    idx: usize = 0,

    fn pop(self: *ArithStack) ?usize {
        if (self.idx == 0) return null;
        self.idx -= 1;
        return self.buf[self.idx];
    }

    fn handle(self: *ArithStack, token: []const u8) ?usize {
        if (std.mem.eql(u8, token, "*")) {
            var out: usize = 1;
            while (self.pop()) |val| out *= val;
            return out;
        } else if (std.mem.eql(u8, token, "+")) {
            var out: usize = 0;
            while (self.pop()) |val| out += val;
            return out;
        }

        if (std.mem.endsWith(u8, token, "*") or std.mem.endsWith(u8, token, "+")) {
            _ = self.handle(token[0 .. token.len - 1]);
            return self.handle(token[token.len - 1 .. token.len]);
        }
        self.buf[self.idx] =
            std.fmt.parseInt(usize, token, 10) catch unreachable;
        self.idx += 1;
        return null;
    }
};

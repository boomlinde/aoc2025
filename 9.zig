const std = @import("std");

const input = @embedFile("inputs/9");

const Point = struct { x: usize, y: usize };
const Rect = struct { a: Point, b: Point };

var point_buf: std.BoundedArray(Point, 1000) = .{};
var rect_buf: std.BoundedArray(Rect, 1000 * 1000) = .{};

pub fn main() anyerror!void {
    var line_iter = std.mem.splitScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) break;
        var axis_ter = std.mem.splitScalar(u8, line, ',');
        const x = try std.fmt.parseInt(usize, axis_ter.next() orelse unreachable, 0);
        const y = try std.fmt.parseInt(usize, axis_ter.next() orelse unreachable, 0);
        point_buf.append(.{ .x = x, .y = y }) catch unreachable;
    }

    const points = point_buf.constSlice();

    for (points) |a| for (points) |b| try rect_buf.append(.{ .a = a, .b = b });

    const rects = rect_buf.slice();
    std.mem.sort(Rect, rects, void{}, rectCompare);

    var greatest_contained_area: usize = 0;
    for (rects) |r| if (!intersects(r, points)) {
        greatest_contained_area = area(r.a, r.b);
        break;
    };

    std.debug.print("{}\n{}\n", .{
        area(rects[0].a, rects[0].b),
        greatest_contained_area,
    });
}

fn intersects(r: Rect, points: []const Point) bool {
    const rect_top = @min(r.a.y, r.b.y);
    const rect_bot = @max(r.a.y, r.b.y);
    const rect_l = @min(r.a.x, r.b.x);
    const rect_r = @max(r.a.x, r.b.x);

    for (points, 0..) |a, i| {
        const b = points[(i + 1) % points.len];

        const top = @min(a.y, b.y);
        const bottom = @max(a.y, b.y);
        const left = @min(a.x, b.x);
        const right = @max(a.x, b.x);

        if (a.x == b.x) { // vertical line
            if (bottom <= rect_top or top >= rect_bot) continue;
            if (left <= rect_l or left >= rect_r) continue;
            return true;
        }
        if (a.y == b.y) { // horizontal line
            if (right <= rect_l or left >= rect_r) continue;
            if (bottom <= rect_top or bottom >= rect_bot) continue;
            return true;
        }

        // a and b must form an axis-aligned line
        unreachable;
    }

    return false;
}

fn area(a: Point, b: Point) usize {
    const w = 1 + @max(a.x, b.x) - @min(a.x, b.x);
    const h = 1 + @max(a.y, b.y) - @min(a.y, b.y);
    return w * h;
}

fn rectCompare(_: void, lhs: Rect, rhs: Rect) bool {
    return area(lhs.a, lhs.b) > area(rhs.a, rhs.b);
}

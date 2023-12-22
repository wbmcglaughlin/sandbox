const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");

fn pointFromVec2(vec: r.Vector2) Point {
    return Point{ .x = @as(i32, @intFromFloat(vec.x)), .y = @as(i32, @intFromFloat(vec.y)) };
}

const Point = struct { x: i32, y: i32 };

fn plotLine(points: *Vector2List, start: Point, end: Point) !void {
    var x = start.x;
    var y = start.y;
    const dx: i32 = @as(i32, @intCast(@abs(end.x - start.x)));
    const sx: i32 = if (start.x < end.x) 1 else -1;
    const dy: i32 = -@as(i32, @intCast(@abs(end.y - start.y)));
    const sy: i32 = if (start.y < end.y) 1 else -1;
    var err = dx + dy;

    while (true) {
        // Plot the point at (x, y)
        try points.append(Point{ .x = x, .y = y });

        if (x == end.x and y == end.y) break;

        const e2 = 2 * err;
        if (e2 >= dy) {
            if (x == end.x) break;
            err = err + dy;
            x = x + sx;
        }
        if (e2 <= dx) {
            if (y == end.y) break;
            err = err + dx;
            y = y + sy;
        }
    }
}

const Vector2List = std.ArrayList(Point);

pub fn main() !void {
    r.InitWindow(960, 540, "My Window Name");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    var points = Vector2List.init(std.heap.page_allocator);
    defer points.deinit();

    var lastPosition = Point{ .x = 0, .y = 0 };
    while (!r.WindowShouldClose()) {
        if (r.IsMouseButtonDown(r.MOUSE_LEFT_BUTTON)) {
            const cursorPos = r.GetMousePosition();
            const cursorPosPoint = pointFromVec2(cursorPos);
            try plotLine(&points, lastPosition, cursorPosPoint);
            lastPosition = cursorPosPoint;
        } else {
            lastPosition = pointFromVec2(r.GetMousePosition());
        }

        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);

        for (points.items) |point| {
            r.DrawPixel(point.x, point.y, r.BLACK);
        }

        r.EndDrawing();
    }
}

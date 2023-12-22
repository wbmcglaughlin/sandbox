const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const Vector2List = std.ArrayList(Point);
const Point = struct { x: i32, y: i32 };
const Pixel = enum(u32) { empty, sand };
const window_width: i32 = 900;
const window_height: i32 = 600;
const capacity = window_width * window_height;
const SCEEN_RECTANGLE = r.Rectangle{ .x = 0, .y = 0, .width = window_width, .height = window_height };

fn pointFromVec2(vec: r.Vector2) Point {
    return Point{ .x = @as(i32, @intFromFloat(vec.x)), .y = @as(i32, @intFromFloat(vec.y)) };
}

fn plotLine(points: *[capacity]Pixel, start: Point, end: Point, pixel_type: Pixel) !void {
    var x = start.x;
    var y = start.y;
    const dx: i32 = @as(i32, @intCast(@abs(end.x - start.x)));
    const sx: i32 = if (start.x < end.x) 1 else -1;
    const dy: i32 = -@as(i32, @intCast(@abs(end.y - start.y)));
    const sy: i32 = if (start.y < end.y) 1 else -1;
    var err = dx + dy;

    while (true) {
        points[@as(usize, @intCast(y * window_width + x))] = pixel_type;

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

fn i_xy(x: usize, y: usize) usize {
    return y * window_width + x;
}

fn update(points: *[capacity]Pixel) !void {
    for (0..window_width) |x| {
        for (0..window_height) |y| {
            if (points[i_xy(x, y)] != Pixel.empty and y != window_height - 1) {
                if (points[i_xy(x, y + 1)] == Pixel.empty) {
                    points[i_xy(x, y + 1)] = Pixel.sand;
                    points[i_xy(x, y)] = Pixel.empty;
                }
            }
        }
    }
}

pub fn main() !void {
    r.InitWindow(window_width, window_height, "My Window Name");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    var points: [capacity]Pixel = [_]Pixel{Pixel.empty} ** capacity;

    var lastPosition = Point{ .x = 0, .y = 0 };
    while (!r.WindowShouldClose()) {
        if (r.IsMouseButtonDown(r.MOUSE_LEFT_BUTTON)) {
            const cursorPos = r.GetMousePosition();
            if (r.CheckCollisionPointRec(cursorPos, SCEEN_RECTANGLE)) {
                const cursorPosPoint = pointFromVec2(cursorPos);
                try plotLine(&points, lastPosition, cursorPosPoint, Pixel.sand);
                lastPosition = cursorPosPoint;
            }
        } else {
            lastPosition = pointFromVec2(r.GetMousePosition());
        }

        try update(&points);

        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);
        r.DrawFPS(window_width - 100, 10);
        r.DrawText("sandbox", 10, 10, 20, r.BLACK);
        for (&points, 0..) |item, i| {
            const i_c = @as(i32, @intCast(i));
            if (item == Pixel.sand) {
                r.DrawPixel(@rem(i_c, window_width), @divFloor(i_c, window_width), r.BLACK);
            }
        }

        r.EndDrawing();
    }
}

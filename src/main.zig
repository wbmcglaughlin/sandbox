const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const window = @import("window.zig");
const interact = @import("interact.zig");
const pixel = @import("pixel.zig");

const Vector2List = std.ArrayList(pixel.Point);

fn pointFromVec2(vec: r.Vector2) pixel.Point {
    return pixel.Point{
        .x = @as(i32, @intFromFloat(vec.x)),
        .y = @as(i32, @intFromFloat(vec.y)),
    };
}

fn xy_i(x: usize, y: usize) usize {
    return y * window.WINDOW_WIDTH + x;
}

fn update(points: *[window.CAPACITY]pixel.Pixel) !void {
    // TODO: should test that mass is conserved.
    // TODO: how often should the simulation update, this should be configurable.
    for (0..window.WINDOW_WIDTH) |x| {
        for (0..window.WINDOW_HEIGHT) |y| {
            // Check for non empty points.
            // TODO: current implementation will not conserve mass, depending on how the updates
            //   are going to occur, we should have some sort of buffer to not overwrite.
            if (points[xy_i(x, y)] != pixel.Pixel.empty and y != window.WINDOW_HEIGHT - 1) {
                if (points[xy_i(x, y + 1)] == pixel.Pixel.empty) {
                    points[xy_i(x, y + 1)] = pixel.Pixel.sand;
                    points[xy_i(x, y)] = pixel.Pixel.empty;
                }
            }
        }
    }
}

pub fn main() !void {
    r.InitWindow(window.WINDOW_WIDTH, window.WINDOW_HEIGHT, "My Window Name");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    var points: [window.CAPACITY]pixel.Pixel = [_]pixel.Pixel{pixel.Pixel.empty} ** window.CAPACITY;

    var lastPosition = pixel.Point{ .x = 0, .y = 0 };
    while (!r.WindowShouldClose()) {
        if (r.IsMouseButtonDown(r.MOUSE_LEFT_BUTTON)) {
            const cursorPos = r.GetMousePosition();
            if (r.CheckCollisionPointRec(cursorPos, window.SCEEN_RECTANGLE)) {
                const cursorPosPoint = pointFromVec2(cursorPos);
                try interact.plotLine(
                    &points,
                    lastPosition,
                    cursorPosPoint,
                    pixel.Pixel.sand,
                );
                lastPosition = cursorPosPoint;
            }
        } else {
            lastPosition = pointFromVec2(r.GetMousePosition());
        }

        try update(&points);

        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);
        r.DrawFPS(window.WINDOW_WIDTH - 100, 10);
        r.DrawText("sandbox", 10, 10, 20, r.BLACK);
        for (&points, 0..) |item, i| {
            const i_c = @as(i32, @intCast(i));
            if (item == pixel.Pixel.sand) {
                r.DrawPixel(
                    @rem(i_c, window.WINDOW_WIDTH),
                    @divFloor(i_c, window.WINDOW_WIDTH),
                    r.BLACK,
                );
            }
        }

        r.EndDrawing();
    }
}

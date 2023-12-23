const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const window = @import("window.zig");
const interact = @import("interact.zig");
const pixel = @import("pixel.zig");
const sim = @import("simulation.zig");

const Vector2List = std.ArrayList(pixel.Point);

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
                const cursorPosPoint = pixel.pointFromVec2(cursorPos);
                try interact.plotLine(
                    &points,
                    lastPosition,
                    cursorPosPoint,
                    pixel.Pixel.sand,
                );
                lastPosition = cursorPosPoint;
            }
        } else {
            lastPosition = pixel.pointFromVec2(r.GetMousePosition());
        }

        try sim.update(&points);

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

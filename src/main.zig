const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");
const window = @import("window.zig");
const interact = @import("interact.zig");
const particle = @import("particle.zig");
const sim = @import("simulation.zig");

const Vector2List = std.ArrayList(particle.Point);

pub fn main() !void {
    r.InitWindow(window.WINDOW_WIDTH, window.WINDOW_HEIGHT, "My Window Name");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    var points: [window.CAPACITY]particle.ParticleType = [_]particle.ParticleType{particle.ParticleType.empty} ** window.CAPACITY;
    var currentParticle = particle.ParticleType.sand;
    var lastPosition = particle.Point{ .x = 0, .y = 0 };
    while (!r.WindowShouldClose()) {
        if (r.IsMouseButtonDown(r.MOUSE_LEFT_BUTTON)) {
            const cursorPos = r.GetMousePosition();
            if (r.CheckCollisionPointRec(cursorPos, window.SCEEN_RECTANGLE)) {
                const cursorPosPoint = particle.pointFromVec2(cursorPos);
                try interact.plotLine(
                    &points,
                    lastPosition,
                    cursorPosPoint,
                    currentParticle,
                );
                lastPosition = cursorPosPoint;
            }
        } else {
            lastPosition = particle.pointFromVec2(r.GetMousePosition());
        }

        if (r.IsKeyPressed(r.KEY_RIGHT)) {
            currentParticle = particle.ParticleType.water;
        }

        if (r.IsKeyPressed(r.KEY_LEFT)) {
            currentParticle = particle.ParticleType.sand;
        }

        try sim.update(&points);

        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);
        r.DrawFPS(window.WINDOW_WIDTH - 100, 10);
        r.DrawText("current", 10, 10, 20, r.BLACK);

        for (&points, 0..) |item, i| {
            const i_c = @as(i32, @intCast(i));
            const x = @rem(i_c, window.WINDOW_WIDTH);
            const y = @divFloor(i_c, window.WINDOW_WIDTH);
            const color = switch (item) {
                particle.ParticleType.sand => r.Color{ .a = 255, .r = 230, .g = 184, .b = 78 },
                particle.ParticleType.water => r.Color{ .a = 255, .r = 43, .g = 125, .b = 240 },
                else => r.Color{ .a = 0 },
            };
            if (color.a != 0) {
                r.DrawPixel(x, y, color);
            }
        }

        r.EndDrawing();
    }
}

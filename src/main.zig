const r = @cImport(@cInclude("raylib.h"));
const r_math = @cImport(@cInclude("raymath.h"));
const std = @import("std");
const window = @import("window.zig");
const interact = @import("interact.zig");
const particle = @import("particle.zig");
const sim = @import("simulation.zig");

const Vector2List = std.ArrayList(particle.Point);

pub fn main() !void {
    r.InitWindow(window.WIDTH, window.HEIGHT, "sandbox");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    var points: [window.WIDTH][window.HEIGHT]particle.ParticleType = undefined;
    for (&points, 0..) |row, x| {
        for (row, 0..) |_, y| {
            points[x][y] = particle.ParticleType.empty;
        }
    }

    var cam = r.Camera2D{ .rotation = 0 };
    cam.zoom = 1;

    var currentParticle = particle.ParticleType.sand;
    var lastPosition = particle.Point{ .x = 0, .y = 0 };
    while (!r.WindowShouldClose()) {
        // translate based on right click
        if (r.IsMouseButtonDown(r.MOUSE_BUTTON_MIDDLE)) {
            const delta = r.GetMouseDelta();
            // delta = Vector2Scale(delta, -1.0f / cam.zoom);

            cam.target = r.Vector2{ .x = cam.target.x + delta.x, .y = cam.target.y + delta.y };
        }

        // zoom based on wheel
        const wheel = r.GetMouseWheelMove();
        std.debug.print("{}", .{wheel});
        if (wheel != 0) {
            // get the world point that is under the mouse
            const mouseWorldPos = r.GetScreenToWorld2D(r.GetMousePosition(), cam);

            // set the offset to where the mouse is
            cam.offset = r.GetMousePosition();

            // set the target to match, so that the camera maps the world space point under the cursor to the screen space point under the cursor at any zoom
            cam.target = mouseWorldPos;

            // zoom
            cam.zoom += wheel * 0.125;
            if (cam.zoom < 0.125)
                cam.zoom = 0.125;
        }

        if (r.IsMouseButtonDown(r.MOUSE_LEFT_BUTTON)) {
            const cursorPos = r.GetMousePosition();
            if (r.CheckCollisionPointRec(cursorPos, window.SCEEN_RECTANGLE)) {
                const cursorPosPoint = particle.vec2_to_point(cursorPos);
                try interact.plot_line(
                    &points,
                    lastPosition,
                    cursorPosPoint,
                    currentParticle,
                );
                lastPosition = cursorPosPoint;
            }
        } else {
            lastPosition = particle.vec2_to_point(r.GetMousePosition());
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
        r.DrawFPS(window.WIDTH - 100, 10);
        r.DrawText("current", 10, 10, 20, r.BLACK);

        r.BeginMode2D(cam);
        for (&points, 0..) |row, x| {
            for (row, 0..) |item, y| {
                const color = switch (item) {
                    particle.ParticleType.sand => r.Color{ .a = 255, .r = 230, .g = 184, .b = 78 },
                    particle.ParticleType.water => r.Color{ .a = 255, .r = 43, .g = 125, .b = 240 },
                    else => r.Color{ .a = 0 },
                };
                if (color.a != 0) {
                    r.DrawPixel(
                        @as(i32, @intCast(x)),
                        @as(i32, @intCast(y)),
                        color,
                    );
                }
            }
        }
        r.EndMode2D();
        r.EndDrawing();
    }
}

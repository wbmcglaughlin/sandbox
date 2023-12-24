const r = @cImport(@cInclude("raylib.h"));
const r_math = @cImport(@cInclude("raymath.h"));
const std = @import("std");
const window = @import("window.zig");
const interact = @import("interact.zig");
const particle = @import("particle.zig");
const sim = @import("simulation.zig");

const Vector2List = std.ArrayList(particle.Point);
const Particle = particle.Particle;
const ParticleState = particle.ParticleState;
const ParticleType = particle.ParticleType;

pub fn main() !void {
    r.InitWindow(window.WINDOW_WIDTH, window.WINDOW_HEIGHT, "sandbox");
    r.SetTargetFPS(60);
    defer r.CloseWindow();

    var app_mode = interact.AppMode.drawing;

    var points: sim.Points = undefined;
    for (&points, 0..) |row, x| {
        for (row, 0..) |_, y| {
            points[x][y] = Particle{ .state = ParticleState.empty, .color = r.Color{ .a = 0 } };
        }
    }

    var cam = r.Camera2D{ .rotation = 0 };
    cam.zoom = window.SCALE;

    const left_click_particle = try particle.get_particle(ParticleType.dirt);
    const right_click_particle = try particle.get_particle(ParticleType.water);

    var lastPosition = particle.Point{ .x = 0, .y = 0 };
    while (!r.WindowShouldClose()) {
        const mouseWorldPos = r.GetScreenToWorld2D(
            r.GetMousePosition(),
            cam,
        );
        const lmb_down = r.IsMouseButtonDown(r.MOUSE_LEFT_BUTTON);
        const rmb_down = r.IsMouseButtonDown(r.MOUSE_RIGHT_BUTTON);
        if (lmb_down or rmb_down) {
            if (r.CheckCollisionPointRec(mouseWorldPos, window.SCEEN_RECTANGLE)) {
                const cursorPosPoint = particle.vec2_to_point(mouseWorldPos);
                try interact.draw_line(
                    &points,
                    lastPosition,
                    cursorPosPoint,
                    if (lmb_down) left_click_particle else right_click_particle,
                );
                lastPosition = cursorPosPoint;
            }
        } else {
            lastPosition = particle.vec2_to_point(mouseWorldPos);
        }

        if (r.IsKeyDown(r.KEY_S)) {
            app_mode = interact.AppMode.select;
        } else {
            app_mode = interact.AppMode.drawing;
        }

        try sim.update(&points);

        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);
        r.DrawFPS(window.WINDOW_WIDTH - 100, 10);
        r.DrawText("sandbox", 10, 10, 20, r.BLACK);

        r.BeginMode2D(cam);
        // r.DrawRectangleLinesEx(window.SCEEN_RECTANGLE, 3, r.BLACK);
        for (&points, 0..) |row, x| {
            for (row, 0..) |item, y| {
                if (item.color.a != 0) {
                    r.DrawPixel(
                        @as(i32, @intCast(x)),
                        @as(i32, @intCast(y)),
                        item.color,
                    );
                }
            }
        }
        r.EndMode2D();
        if (app_mode == interact.AppMode.select) {
            var posx: f32 = 10;
            var posy: f32 = 10;
            const width: f32 = 50;
            inline for (@typeInfo(ParticleType).Enum.fields, 0..) |_, i| {
                const particle_type: ParticleType = @enumFromInt(i);
                const p = try particle.get_particle(particle_type);
                const rec = r.Rectangle{
                    .x = posx,
                    .y = posy,
                    .width = width,
                    .height = width,
                };
                r.DrawRectangleRec(rec, p.color);
                r.DrawRectangleLinesEx(rec, 3.0, r.BLACK);
                posx += 10 + width;
                posy += 0;
            }
        }
        r.EndDrawing();
    }
}

const r = @cImport(@cInclude("raylib.h"));
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
    var render_mode = interact.RenderMode.color;

    const grid = window.Grid{
        .x_corner = 0,
        .y_corner = 0,
        .width = window.WINDOW_WIDTH,
        .x_squares = 20,
        .border = 10,
    };
    var points: sim.Points = undefined;
    for (&points, 0..) |row, x| {
        for (row, 0..) |_, y| {
            points[x][y] = Particle{ .state = ParticleState.empty, .color = r.Color{ .a = 0 } };
        }
    }

    var cam = r.Camera2D{ .rotation = 0 };
    cam.zoom = window.SCALE;

    var left_click_particle = try particle.get_particle(ParticleType.dirt);
    var right_click_particle = try particle.get_particle(ParticleType.water);

    var lastPosition = particle.Point{ .x = 0, .y = 0 };
    while (!r.WindowShouldClose()) {
        const mouse_position = r.GetMousePosition();
        const mouseWorldPos = r.GetScreenToWorld2D(
            mouse_position,
            cam,
        );
        const lmb_down = r.IsMouseButtonDown(r.MOUSE_LEFT_BUTTON);
        const rmb_down = r.IsMouseButtonDown(r.MOUSE_RIGHT_BUTTON);

        if (lmb_down or rmb_down) {
            if (app_mode == interact.AppMode.drawing) {
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
            } else if (app_mode == interact.AppMode.select) {
                if (grid.get_index(mouse_position)) |ind| {
                    if (ind < @typeInfo(ParticleType).Enum.fields.len) {
                        const particle_type: ParticleType = @enumFromInt(ind);
                        const p = try particle.get_particle(particle_type);

                        if (lmb_down) {
                            left_click_particle = p;
                        } else {
                            right_click_particle = p;
                        }
                    }
                } else |err| switch (err) {
                    window.GridError.NoCollisionError => {},
                }
            }
        } else {
            lastPosition = particle.vec2_to_point(mouseWorldPos);
        }

        if (r.IsKeyDown(r.KEY_S)) {
            app_mode = interact.AppMode.select;
        } else {
            app_mode = interact.AppMode.drawing;
        }

        if (r.IsKeyDown(r.KEY_T)) {
            render_mode = interact.RenderMode.temperature;
        } else {
            render_mode = interact.RenderMode.color;
        }

        try sim.update(&points);

        r.BeginDrawing();
        r.ClearBackground(r.RAYWHITE);

        r.BeginMode2D(cam);
        // r.DrawRectangleLinesEx(window.SCEEN_RECTANGLE, 3, r.BLACK);
        for (&points, 0..) |row, x| {
            for (row, 0..) |item, y| {
                var pixel_col: r.Color = undefined;
                if (render_mode == interact.RenderMode.color) {
                    pixel_col = item.color;
                } else {
                    pixel_col = particle.hslToRgb(item.temperature / 300, 0.3, 0.3);
                }
                if (item.color.a != 0) {
                    r.DrawPixel(
                        @as(i32, @intCast(x)),
                        @as(i32, @intCast(y)),
                        pixel_col,
                    );
                }
            }
        }
        r.EndMode2D();
        if (app_mode == interact.AppMode.select) {
            inline for (@typeInfo(ParticleType).Enum.fields, 0..) |_, i| {
                const particle_type: ParticleType = @enumFromInt(i);
                const p = try particle.get_particle(particle_type);
                const rec = grid.get_rectangle(i);
                r.DrawRectangleRec(rec, p.color);
                r.DrawRectangleLinesEx(rec, 3.0, r.BLACK);
            }
        }
        r.EndDrawing();
    }
}

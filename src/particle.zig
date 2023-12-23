const r = @cImport(@cInclude("raylib.h"));
pub const ParticleType = enum(u32) { empty, sand, water };
pub const Point = struct { x: i32, y: i32 };

pub fn vec2_to_point(vec: r.Vector2) Point {
    return Point{
        .x = @as(i32, @intFromFloat(vec.x)),
        .y = @as(i32, @intFromFloat(vec.y)),
    };
}

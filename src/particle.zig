const r = @cImport(@cInclude("raylib.h"));
pub const Particle = enum(u32) { empty, sand };
pub const Point = struct { x: i32, y: i32 };

pub fn pointFromVec2(vec: r.Vector2) Point {
    return Point{
        .x = @as(i32, @intFromFloat(vec.x)),
        .y = @as(i32, @intFromFloat(vec.y)),
    };
}

const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");
pub const ParticleState = enum(u32) { empty, gas, liquid, grain, solid, immovable };
pub const Point = struct { x: i32, y: i32 };
pub const ParticleType = enum(u32) {
    water,
    dirt,
    sand,
    stone,
    wall,
};

pub fn vec2_to_point(vec: r.Vector2) Point {
    return Point{
        .x = @as(i32, @intFromFloat(vec.x)),
        .y = @as(i32, @intFromFloat(vec.y)),
    };
}

pub const Particle = struct {
    state: ParticleState,
    color: r.Color,
};

pub fn get_particle(particle_type: ParticleType) !Particle {
    return switch (particle_type) {
        ParticleType.water => Particle{
            .state = ParticleState.liquid,
            .color = r.Color{ .a = 255, .r = 43, .g = 125, .b = 240 },
        },
        ParticleType.dirt => Particle{
            .state = ParticleState.grain,
            .color = r.Color{ .a = 255, .r = 145, .g = 121, .b = 77 },
        },
        ParticleType.sand => Particle{
            .state = ParticleState.grain,
            .color = r.Color{ .a = 255, .r = 230, .g = 230, .b = 119 },
        },
        ParticleType.stone => Particle{
            .state = ParticleState.solid,
            .color = r.Color{ .a = 255, .r = 92, .g = 92, .b = 84 },
        },
        ParticleType.wall => Particle{
            .state = ParticleState.immovable,
            .color = r.Color{ .a = 255, .r = 200, .g = 200, .b = 200 },
        },
    };
}

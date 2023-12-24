const r = @cImport(@cInclude("raylib.h"));
pub const ParticleState = enum(u32) { empty, gas, liquid, grain, solid };
pub const Point = struct { x: i32, y: i32 };
pub const ParticleType = enum {
    water,
    dirt,
    sand,
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
            .color = r.Color{ .a = 255, .r = 43, .g = 125, .b = 240 },
        },
    };
}

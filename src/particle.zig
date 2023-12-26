const r = @cImport(@cInclude("raylib.h"));
const std = @import("std");

pub const ROOM_TEMPERATURE: f32 = 273.5;

pub const ParticleState = enum(u32) { empty, gas, liquid, grain, solid, immovable };
pub const Point = struct { x: i32, y: i32 };
pub const ParticleType = enum(u32) {
    water,
    dirt,
    sand,
    coal,
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
    temperature: f32 = ROOM_TEMPERATURE,
};

pub fn get_particle(particle_type: ParticleType) !Particle {
    return switch (particle_type) {
        ParticleType.water => Particle{
            .state = ParticleState.liquid,
            .color = r.Color{ .a = 255, .r = 43, .g = 125, .b = 240 },
            .temperature = 300,
        },
        ParticleType.dirt => Particle{
            .state = ParticleState.grain,
            .color = r.Color{ .a = 255, .r = 145, .g = 121, .b = 77 },
        },
        ParticleType.sand => Particle{
            .state = ParticleState.grain,
            .color = r.Color{ .a = 255, .r = 230, .g = 230, .b = 119 },
        },
        ParticleType.coal => Particle{
            .state = ParticleState.solid,
            .color = r.Color{ .a = 255, .r = 34, .g = 34, .b = 34 },
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

// Function to convert hue to RGB color
pub fn hslToRgb(hue: f32, saturation: f32, lightness: f32) r.Color {
    var red: f32 = 0.0;
    var green: f32 = 0.0;
    var blue: f32 = 0.0;

    if (saturation == 0.0) {
        red = lightness;
        green = lightness;
        blue = lightness;
    } else {
        const q: f32 = if (lightness < 0.5) lightness * (1.0 + saturation) else lightness + saturation - lightness * saturation;

        const p: f32 = 2.0 * lightness - q;

        red = hue_to_rgb(p, q, hue + 1.0 / 3.0);
        green = hue_to_rgb(p, q, hue);
        blue = hue_to_rgb(p, q, hue - 1.0 / 3.0);
    }

    return r.Color{
        .a = 255,
        .r = @intFromFloat(red * 255.0),
        .g = @intFromFloat(green * 255.0),
        .b = @intFromFloat(blue * 255.0),
    };
}

fn hue_to_rgb(p: f32, q: f32, t: f32) f32 {
    var t_temp = t;
    if (t_temp < 0.0) {
        t_temp += 1.0;
    }
    if (t_temp > 1.0) {
        t_temp -= 1.0;
    }
    if (t_temp < 1.0 / 6.0) {
        return p + (q - p) * 6.0 * t_temp;
    }
    if (t_temp < 1.0 / 2.0) {
        return q;
    }
    if (t_temp < 2.0 / 3.0) {
        return p + (q - p) * (2.0 / 3.0 - t_temp) * 6.0;
    }
    return p;
}

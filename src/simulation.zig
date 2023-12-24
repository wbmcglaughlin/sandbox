const std = @import("std");
const window = @import("window.zig");
const particle = @import("particle.zig");
const ParticleState = particle.ParticleState;
const Particle = particle.Particle;
pub const Points = [window.WIDTH][window.HEIGHT]Particle;

fn xy_i(x: usize, y: usize) usize {
    return y * window.WIDTH + x;
}

pub fn update(points: *Points) !void {
    // TODO: how often should the simulation update, this should be configurable.
    try up_pass(points);
}

pub fn swap(points: *Points, x1: usize, y1: usize, x2: usize, y2: usize) void {
    const temp = points[x1][y1];
    points[x1][y1] = points[x2][y2];
    points[x2][y2] = temp;
}

pub fn get_mass(points: *Points) u32 {
    var mass: u32 = 0;
    for (points, 0..) |row, x| {
        for (row, 0..) |_, y| {
            if (points[x][y].state != ParticleState.empty) {
                mass += 1;
            }
        }
    }
    return mass;
}

fn is_heavier(heavier: ParticleState, lighter: ParticleState) bool {
    return @intFromEnum(heavier) > @intFromEnum(lighter);
}

pub fn up_pass(points: *Points) !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    for (0..window.WIDTH) |x| {
        for (0..window.HEIGHT) |y_a| {
            // Invert coordinates for the up pass.
            const y = window.HEIGHT - y_a - 1;

            const particle_type = points[x][y].state;

            // Skip empty particles.
            if (particle_type == ParticleState.empty) {
                continue;
            }

            // Skip immovable particles.
            if (particle_type == ParticleState.immovable) {
                continue;
            }

            // Store constants to check border cases.
            const bottom = y == window.HEIGHT - 2;
            const left_side = x == 0;
            const right_side = x == window.WIDTH - 1;

            // The effect of gravity on a solid particle.
            if (!bottom) {
                if (is_heavier(particle_type, points[x][y + 1].state)) {
                    swap(points, x, y, x, y + 1);
                    continue;
                }

                // The particle below is solid, check if the particle is going to fall.
                // Need to check if there is a barrier stopping it from falling on the
                // adjacent tile.
                if (!left_side and points[x - 1][y + 1].state == ParticleState.empty and points[x - 1][y].state == ParticleState.empty) {
                    swap(points, x, y, x - 1, y + 1);
                    continue;
                }

                if (!right_side and points[x + 1][y + 1].state == ParticleState.empty and points[x + 1][y].state == ParticleState.empty) {
                    swap(points, x, y, x + 1, y + 1);
                    continue;
                }
            }

            if (points[x][y].state != ParticleState.liquid) {
                continue;
            }

            // At this point there is no space for the particle to fall down into.
            // Liquids should randomly move left or right if there is available space.
            const value = prng.random().intRangeAtMost(i64, 0, 1);
            if (value == 0) {
                if (!left_side and points[x - 1][y].state == ParticleState.empty) {
                    swap(points, x, y, x - 1, y);
                    continue;
                }
            } else {
                if (!right_side and points[x + 1][y].state == ParticleState.empty) {
                    swap(points, x, y, x + 1, y);
                    continue;
                }
            }
        }
    }
}

const std = @import("std");
const window = @import("window.zig");
const particle = @import("particle.zig");
const ParticleType = particle.ParticleType;
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
            if (points[x][y].type != ParticleType.empty) {
                mass += 1;
            }
        }
    }
    return mass;
}
pub fn up_pass(points: *Points) !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    for (0..window.WIDTH) |x| {
        for (0..window.HEIGHT) |y_a| {
            const y = window.HEIGHT - y_a - 1;
            if (points[x][y].type == ParticleType.empty) {
                continue;
            }

            const bottom = y == window.HEIGHT - 2;
            const left_side = x == 0;
            const right_side = x == window.WIDTH - 1;
            // TODO: should handle solid liquid interaction.
            // The effect of gravity on a solid particle.
            if (points[x][y + 1].type == ParticleType.empty and !bottom) {
                swap(points, x, y, x, y + 1);
            } else {
                // The particle below is solid, check if the particle is going to fall.
                if (!bottom and !left_side and points[x - 1][y + 1].type == ParticleType.empty) {
                    swap(points, x, y, x - 1, y + 1);
                } else if (!bottom and !right_side and points[x + 1][y + 1].type == ParticleType.empty) {
                    swap(points, x, y, x + 1, y + 1);
                } else {
                    if (points[x][y].type != ParticleType.liquid) {
                        continue;
                    }
                    // At this point there is no space for the particle to fall down into.
                    // Liquids should randomly move left or right if there is available space.
                    const value = prng.random().intRangeAtMost(i64, 0, 1);
                    if (value == 0) {
                        if (!left_side and points[x - 1][y].type == ParticleType.empty) {
                            swap(points, x, y, x - 1, y);
                        }
                    } else {
                        if (!right_side and points[x + 1][y].type == ParticleType.empty) {
                            swap(points, x, y, x + 1, y);
                        }
                    }
                }
            }
        }
    }
}

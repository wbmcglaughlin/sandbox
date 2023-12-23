const std = @import("std");
const window = @import("window.zig");
const particle = @import("particle.zig");
const ParticleType = particle.ParticleType;
const Points = [window.WIDTH][window.HEIGHT]particle.ParticleType;

fn xy_i(x: usize, y: usize) usize {
    return y * window.WIDTH + x;
}

pub fn update(points: *Points) !void {
    // TODO: should test that mass is conserved.
    // TODO: how often should the simulation update, this should be configurable.
    try up_pass(points);
}

pub fn swap(points: *Points, x1: usize, y1: usize, x2: usize, y2: usize) void {
    const temp = points[x1][y1];
    points[x1][y1] = points[x2][y2];
    points[x2][y2] = temp;
}

pub fn up_pass(points: *Points) !void {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    var non_empty: u32 = 0;
    for (0..window.WIDTH) |x| {
        for (1..(window.HEIGHT - 1)) |y_a| {
            const y = window.HEIGHT - y_a - 1;
            if (points[x][y] == ParticleType.empty) {
                continue;
            }

            non_empty += 1;
            // The effect of gravity on a solid particle.
            if (points[x][y + 1] == ParticleType.empty) {
                swap(points, x, y, x, y + 1);
            } else {
                // The particle below is solid, check if the particle is going to fall.
                if (points[x - 1][y + 1] == ParticleType.empty and x != 0) {
                    swap(points, x, y, x - 1, y + 1);
                } else if (points[x + 1][y + 1] == ParticleType.empty and x != window.WIDTH - 1) {
                    swap(points, x, y, x + 1, y + 1);
                } else {
                    // At this point there is no space for the particle to fall down into.
                    // Liquids should randomly move left or right if there is available space.
                    const value = prng.random().intRangeAtMost(i64, 0, 1);
                    if (value == 0) {
                        if (points[x - 1][y] == ParticleType.empty and x != 0) {
                            swap(points, x, y, x - 1, y);
                        }
                    } else {
                        if (points[x + 1][y] == ParticleType.empty and x != window.WIDTH - 1) {
                            swap(points, x, y, x + 1, y);
                        }
                    }
                }
            }
        }
    }

    std.debug.print("{}\n", .{non_empty});
}

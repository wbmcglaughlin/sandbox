const std = @import("std");
const window = @import("window.zig");
const particle = @import("particle.zig");

fn xy_i(x: usize, y: usize) usize {
    return y * window.WIDTH + x;
}

pub fn update(points: *[window.WIDTH][window.HEIGHT]particle.ParticleType) !void {
    // TODO: should test that mass is conserved.
    // TODO: how often should the simulation update, this should be configurable.
    for (0..window.WIDTH) |x| {
        for (0..window.HEIGHT) |y| {
            // Check for non empty points.
            // TODO: current implementation will not conserve mass, depending on how the updates
            //   are going to occur, we should have some sort of buffer to not overwrite.
            if (points[x][y] != particle.ParticleType.empty and y != window.HEIGHT - 1) {
                if (points[x][y + 1] == particle.ParticleType.empty) {
                    points[x][y + 1] = points[x][y];
                    points[x][y] = particle.ParticleType.empty;
                }
            }
        }
    }
}

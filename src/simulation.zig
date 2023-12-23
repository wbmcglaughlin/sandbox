const window = @import("window.zig");
const pixel = @import("pixel.zig");

fn xy_i(x: usize, y: usize) usize {
    return y * window.WINDOW_WIDTH + x;
}

pub fn update(points: *[window.CAPACITY]pixel.Pixel) !void {
    // TODO: should test that mass is conserved.
    // TODO: how often should the simulation update, this should be configurable.
    for (0..window.WINDOW_WIDTH) |x| {
        for (0..window.WINDOW_HEIGHT) |y| {
            // Check for non empty points.
            // TODO: current implementation will not conserve mass, depending on how the updates
            //   are going to occur, we should have some sort of buffer to not overwrite.
            if (points[xy_i(x, y)] != pixel.Pixel.empty and y != window.WINDOW_HEIGHT - 1) {
                if (points[xy_i(x, y + 1)] == pixel.Pixel.empty) {
                    points[xy_i(x, y + 1)] = pixel.Pixel.sand;
                    points[xy_i(x, y)] = pixel.Pixel.empty;
                }
            }
        }
    }
}

const window = @import("window.zig");
const particle = @import("particle.zig");

pub fn plot_line(
    points: *[window.WIDTH][window.HEIGHT]particle.ParticleType,
    start: particle.Point,
    end: particle.Point,
    pixel_type: particle.ParticleType,
) !void {
    var x = start.x;
    var y = start.y;
    const dx: i32 = @as(i32, @intCast(@abs(end.x - start.x)));
    const sx: i32 = if (start.x < end.x) 1 else -1;
    const dy: i32 = -@as(i32, @intCast(@abs(end.y - start.y)));
    const sy: i32 = if (start.y < end.y) 1 else -1;
    var err = dx + dy;

    while (true) {
        points[@as(usize, @intCast(x))][@as(usize, @intCast(y))] = pixel_type;

        if (x == end.x and y == end.y) break;

        const e2 = 2 * err;
        if (e2 >= dy) {
            if (x == end.x) break;
            err = err + dy;
            x = x + sx;
        }
        if (e2 <= dx) {
            if (y == end.y) break;
            err = err + dx;
            y = y + sy;
        }
    }
}

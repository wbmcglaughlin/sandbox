const window = @import("window.zig");
const particle = @import("particle.zig");

pub fn plotLine(
    points: *[window.CAPACITY]particle.Particle,
    start: particle.Point,
    end: particle.Point,
    pixel_type: particle.Particle,
) !void {
    var x = start.x;
    var y = start.y;
    const dx: i32 = @as(i32, @intCast(@abs(end.x - start.x)));
    const sx: i32 = if (start.x < end.x) 1 else -1;
    const dy: i32 = -@as(i32, @intCast(@abs(end.y - start.y)));
    const sy: i32 = if (start.y < end.y) 1 else -1;
    var err = dx + dy;

    while (true) {
        points[@as(usize, @intCast(y * window.WINDOW_WIDTH + x))] = pixel_type;

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

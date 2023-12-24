const r = @cImport(@cInclude("raylib.h"));

pub const WIDTH: i32 = 480;
pub const HEIGHT: i32 = 300;
pub const CAPACITY = WIDTH * HEIGHT;

pub const SCALE: i32 = 3;
pub const WINDOW_WIDTH = SCALE * WIDTH;
pub const WINDOW_HEIGHT = SCALE * HEIGHT;
pub const SCEEN_RECTANGLE = r.Rectangle{
    .x = 0,
    .y = 0,
    .width = WIDTH,
    .height = HEIGHT,
};

pub const GridError = error{
    NoCollisionError,
};

pub const Grid = struct {
    x_corner: u32,
    y_corner: u32,
    x_squares: u32,
    width: u32,
    border: u32 = 0,

    pub fn get_rectangle(self: *const Grid, ind: u32) r.Rectangle {
        const x = @mod(ind, self.x_squares);
        const y = @divFloor(ind, self.x_squares);
        // TODO: validate that y is within y_squares.

        const square_width = @divFloor(self.width, self.x_squares);

        return r.Rectangle{
            .x = @floatFromInt(self.x_corner + x * square_width + self.border),
            .y = @floatFromInt(self.y_corner + y * square_width + self.border),
            .height = @floatFromInt(square_width - 2 * self.border),
            .width = @floatFromInt(square_width - 2 * self.border),
        };
    }

    pub fn get_index(self: *const Grid, position: r.Vector2) !u32 {
        var i: u32 = 0;
        while (i < 100) {
            if (r.CheckCollisionPointRec(position, self.get_rectangle(i))) {
                return i;
            }
            i += 1;
        }
        return GridError.NoCollisionError;
    }
};

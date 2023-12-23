const r = @cImport(@cInclude("raylib.h"));

pub const WIDTH: i32 = 300;
pub const HEIGHT: i32 = 180;
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

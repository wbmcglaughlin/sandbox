const r = @cImport(@cInclude("raylib.h"));

pub const WIDTH: i32 = 900;
pub const HEIGHT: i32 = 600;
pub const CAPACITY = WIDTH * HEIGHT;
pub const SCEEN_RECTANGLE = r.Rectangle{
    .x = 0,
    .y = 0,
    .width = WIDTH,
    .height = HEIGHT,
};

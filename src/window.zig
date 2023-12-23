const r = @cImport(@cInclude("raylib.h"));

pub const WINDOW_WIDTH: i32 = 900;
pub const WINDOW_HEIGHT: i32 = 600;
pub const CAPACITY = WINDOW_WIDTH * WINDOW_HEIGHT;
pub const SCEEN_RECTANGLE = r.Rectangle{
    .x = 0,
    .y = 0,
    .width = WINDOW_WIDTH,
    .height = WINDOW_HEIGHT,
};

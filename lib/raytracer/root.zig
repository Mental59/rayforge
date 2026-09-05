const math = @import("math");
pub const vector = math.vector;
pub const Interval = math.Interval;

pub const Canvas = @import("canvas.zig").Canvas;
pub const Ray = @import("ray.zig").Ray;
pub const World = @import("world.zig").World;

const primitives = @import("primitives.zig");
pub const Sphere = primitives.Sphere;

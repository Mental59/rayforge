const std = @import("std");

pub fn hello() void {
    std.log.info("Hello from raytracer lib", .{});
}

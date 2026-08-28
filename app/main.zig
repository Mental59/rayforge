const std = @import("std");
const raytracer = @import("raytracer");

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();

    var threaded: std.Io.Threaded = .init(debug_allocator.allocator(), .{});
    defer threaded.deinit();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), threaded.io(), &stdout_buffer);

    var canvas: raytracer.Canvas(f32) = try .init(512, 512, debug_allocator.allocator());
    defer canvas.deinit();

    for (0..canvas.height) |i| {
        std.debug.print("\rScanlines remaining: {d}", .{canvas.height - i});

        for (0..canvas.width) |j| {
            canvas.setAt(
                i,
                j,
                .{
                    .r = @as(f32, @floatFromInt(j)) / @as(f32, @floatFromInt(canvas.width - 1)),
                    .g = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(canvas.height - 1)),
                    .b = 0.0,
                },
            );
        }
    }

    std.debug.print("\rWriting ppm output...            ", .{});

    try canvas.writePPM(&stdout_file_writer);
    try stdout_file_writer.flush();

    std.debug.print("\rDone.                       \n", .{});
}

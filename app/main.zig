const std = @import("std");
const raytracer = @import("raytracer");
const Canvas = raytracer.Canvas(f32);
const World = raytracer.World;
const Camera = raytracer.Camera;

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();

    var threaded: std.Io.Threaded = .init(debug_allocator.allocator(), .{});
    defer threaded.deinit();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), threaded.io(), &stdout_buffer);

    const camera_options: Camera.Options = .{
        .image_width = 1920,
        .image_height = 1080,
        .viewport_height = 2.0,
        .focal_length = 1.0,
        .camera_center = .{ 0.0, 0.0, 0.0, 0.0 },
        .samples_per_pixel = 100,
    };
    var camera: Camera = .init(threaded.io(), camera_options);
    std.debug.print("Camera: {any}\n", .{camera});

    var canvas: Canvas = try .init(camera.image_width, camera.image_height, debug_allocator.allocator());
    defer canvas.deinit();

    var world: World = try .init(debug_allocator.allocator(), 1024);
    defer world.deinit();

    try world.addSphere(
        .init(.{ 0.0, 0.0, -1.0, 0.0 }, 0.5),
    );
    try world.addSphere(
        .init(.{ 0.0, -100.5, -1.0, 0.0 }, 100),
    );

    for (0..canvas.height) |i| {
        for (0..canvas.width) |j| {
            const pixel = camera.renderPixel(i, j, world);
            canvas.setAt(
                i,
                j,
                .{
                    .r = pixel[0],
                    .g = pixel[1],
                    .b = pixel[2],
                },
            );
        }

        const progress: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(canvas.height - 1));
        std.debug.print("\rProgress: {d:.2}%", .{progress * 100.0});
    }

    std.debug.print("\rWriting ppm output...            ", .{});

    try canvas.writePPM(&stdout_file_writer);
    try stdout_file_writer.flush();

    std.debug.print("\rDone.                          \n", .{});
}

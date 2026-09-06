const std = @import("std");
const raytracer = @import("raytracer");
const Canvas = raytracer.Canvas(f32);
const World = raytracer.World;
const Camera = raytracer.Camera;

pub fn main() !void {
    const camera_options: Camera.Options = .{
        .image_width = 1920,
        .image_height = 1080,
        .viewport_height = 2.0,
        .focal_length = 1.0,
        .camera_center = .{ 0.0, 0.0, 0.0, 0.0 },
    };
    const camera: Camera = .init(camera_options);

    std.debug.print(
        "Image resolution: {d} X {d}\nViewport resolution: {d:.2} X {d:.2}\n",
        .{ camera.image_width, camera.image_height, camera.viewport_width, camera.viewport_height },
    );
    std.debug.print(
        "Camera info: center={any}, focal_length={d}\n",
        .{ camera.center, camera.focal_length },
    );
    std.debug.print(
        ("Viewport info: u={any}, v={any}, du={any}, dv={any}, upper_left_corner={any}, pixel00={any}\n"),
        .{ camera.viewport_u, camera.viewport_v, camera.pixel_delta_u, camera.pixel_delta_v, camera.viewport_upper_left_corner, camera.pixel00_loc },
    );

    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();

    var threaded: std.Io.Threaded = .init(debug_allocator.allocator(), .{});
    defer threaded.deinit();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), threaded.io(), &stdout_buffer);

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
        std.debug.print("\rScanlines remaining: {d}", .{canvas.height - i});

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
    }

    std.debug.print("\rWriting ppm output...            ", .{});

    try canvas.writePPM(&stdout_file_writer);
    try stdout_file_writer.flush();

    std.debug.print("\rDone.                          \n", .{});
}

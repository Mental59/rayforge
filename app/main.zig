const std = @import("std");
const raytracer = @import("raytracer");
const material = raytracer.material;
const Canvas = raytracer.Canvas(f32);
const World = raytracer.World;
const Camera = raytracer.Camera;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;

    var threaded: std.Io.Threaded = .init(allocator, .{});
    const io = threaded.io();
    defer threaded.deinit();

    var stdout_buffer: [4096]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(
        .stdout(),
        io,
        &stdout_buffer,
    );
    const stdout_writer = &stdout_file_writer.interface;

    const result_file = try std.Io.Dir.cwd().createFile(
        io,
        "image.ppm",
        .{},
    );
    defer result_file.close(io);

    var result_file_buffer: [4096]u8 = undefined;
    var result_file_writer: std.Io.File.Writer = .init(
        result_file,
        io,
        &result_file_buffer,
    );
    const result_writer = &result_file_writer.interface;

    const camera_options: Camera.Options = .{
        .image_width = 1920,
        .image_height = 1080,
        .viewport_height = 2.0,
        .focal_length = 1.0,
        .camera_center = .{ 0.0, 0.0, 0.0, 0.0 },
        .samples_per_pixel = 100,
        .max_ray_bounces = 50,
    };
    const camera: Camera = .init(camera_options);
    try stdout_writer.print("Camera: {any}\n", .{camera});

    var canvas: Canvas = try .init(
        camera.image_width,
        camera.image_height,
        allocator,
    );
    defer canvas.deinit();

    var world: World = try .init(allocator, 1024);
    defer world.deinit();

    try buildWorld(&world);

    var seed: u64 = undefined;
    io.random(std.mem.asBytes(&seed));
    var prng: std.Random.DefaultPrng = .init(seed);
    const rng = prng.random();

    for (0..canvas.height) |i| {
        for (0..canvas.width) |j| {
            const pixel = camera.renderPixel(
                i,
                j,
                world,
                rng,
            );

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
        try stdout_writer.print("\rProgress: {d:.2}%", .{progress * 100.0});
        try stdout_writer.flush();
    }

    try stdout_writer.print("\rWriting ppm output...            ", .{});
    try stdout_writer.flush();

    try canvas.writePPM(result_writer);
    try result_writer.flush();

    try stdout_writer.print("\rDone.                          \n", .{});
    try stdout_writer.flush();
}

pub fn buildWorld(world: *World) !void {
    const material_ground: material.Material = .initLambertian(.{ 0.8, 0.8, 0.0, 1.0 });
    const material_center: material.Material = .initLambertian(.{ 1.0, 1.0, 1.0, 1.0 });
    const material_left: material.Material = .initMetal(.{ 0.8, 0.8, 0.8, 1.0 }, 0.3);
    const material_right: material.Material = .initMetal(.{ 0.8, 0.6, 0.2, 1.0 }, 0.6);

    try world.addSphere(.init(
        .{ 0.0, -100.5, -1.0, 0.0 },
        100.0,
        material_ground,
    ));
    try world.addSphere(.init(
        .{ 0.0, 0.0, -1.2, 0.0 },
        0.5,
        material_center,
    ));
    try world.addSphere(.init(
        .{ -1.0, 0.0, -1.0, 0.0 },
        0.5,
        material_left,
    ));
    try world.addSphere(.init(
        .{ 1.0, 0.0, -1.0, 0.0 },
        0.5,
        material_right,
    ));
}

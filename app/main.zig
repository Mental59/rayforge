const std = @import("std");
const raytracer = @import("raytracer");
const vector = raytracer.vector;
const Vec4 = vector.Vec4;
const Canvas = raytracer.Canvas(f32);

const image_height = 1080;
const image_width = 1920;

const viewport_height = 2.0;
const viewport_width = viewport_height * (@as(comptime_float, @floatFromInt(image_width)) / @as(comptime_float, @floatFromInt(image_height)));

const focal_length = 1.0;

const camera_center: Vec4 = vector.initVec4(0.0, 0.0, 0.0, 0.0);

// Calculate the vectors across the horizontal and down the verical viewport edges
const viewport_u: Vec4 = vector.initVec4(viewport_width, 0.0, 0.0, 0.0);
const viewport_v: Vec4 = vector.initVec4(0, -viewport_height, 0.0, 0.0);

// Calculate the horizontal and vertical delta vectors from to pixel to pixel in the viewport
const pixel_delta_u: Vec4 = viewport_u / vector.splat(image_width);
const pixel_delta_v: Vec4 = viewport_v / vector.splat(image_height);

// Calculate the location of the upper left pixel in the viewport
const viewport_upper_left_corner: Vec4 = camera_center - vector.initVec4(0.0, 0.0, focal_length, 0.0) - viewport_u / vector.splat(2.0) - viewport_v / vector.splat(2.0);
const pixel00_loc: Vec4 = viewport_upper_left_corner + vector.splat(0.5) * (pixel_delta_u + pixel_delta_v);

pub fn main() !void {
    std.debug.print(
        "Image resolution: {d} X {d}\nViewport resolution: {d:.2} X {d:.2}\n",
        .{ image_width, image_height, viewport_width, viewport_height },
    );
    std.debug.print(
        "Camera info: center={any}, focal_length={d}\n",
        .{ camera_center, focal_length },
    );
    std.debug.print(
        ("Viewport info: u={any}, v={any}, du={any}, dv={any}, upper_left_corner={any}, pixel00={any}\n"),
        .{ viewport_u, viewport_v, pixel_delta_u, pixel_delta_v, viewport_upper_left_corner, pixel00_loc },
    );

    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();

    var threaded: std.Io.Threaded = .init(debug_allocator.allocator(), .{});
    defer threaded.deinit();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), threaded.io(), &stdout_buffer);

    var canvas: Canvas = try .init(image_width, image_height, debug_allocator.allocator());
    defer canvas.deinit();

    var world: raytracer.World = try .init(debug_allocator.allocator(), 1024);
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
            const pixel_center: Vec4 = pixel00_loc + (vector.splat(@floatFromInt(i)) * pixel_delta_v) + (vector.splat(@floatFromInt(j)) * pixel_delta_u);

            const ray_direction: Vec4 = pixel_center - camera_center;
            const ray: raytracer.Ray = .init(camera_center, ray_direction);

            const pixel_color = getRayColor(ray, world);
            canvas.setAt(i, j, pixel_color);
        }
    }

    std.debug.print("\rWriting ppm output...            ", .{});

    try canvas.writePPM(&stdout_file_writer);
    try stdout_file_writer.flush();

    std.debug.print("\rDone.                          \n", .{});
}

fn getRayColor(ray: raytracer.Ray, world: raytracer.World) Canvas.Color {
    const hit_res = world.hit(ray);
    if (hit_res) |hit| {
        const color = vector.splat(0.5) * (hit.normal + vector.splat(1));
        return .{ .r = color[0], .g = color[1], .b = color[2] };
    }

    const unit_direction: Vec4 = vector.normalized(ray.direction);
    const a = 0.5 * (unit_direction[1] + 1.0);
    const color = vector.splat(1.0 - a) * vector.initVec4(1.0, 1.0, 1.0, 1.0) + vector.splat(a) * vector.initVec4(0.5, 0.7, 1.0, 1.0);
    return .{ .r = color[0], .g = color[1], .b = color[2] };
}

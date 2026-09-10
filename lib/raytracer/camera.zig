const std = @import("std");
const root_module = @import("root.zig");
const Ray = @import("ray.zig").Ray;
const World = @import("world.zig").World;
const rand = root_module.random;
const vector = root_module.vector;
const Vec4 = vector.Vec4;

pub const Camera = struct {
    image_width: u32 = 1920,
    image_height: u32 = 1080,

    viewport_height: f32 = 2.0,
    viewport_width: f32 = 0.0,

    focal_length: f32 = 1.0,

    center: Vec4 = .{ 0.0, 0.0, 0.0, 0.0 },

    viewport_u: Vec4 = .{ 0.0, 0.0, 0.0, 0.0 },
    viewport_v: Vec4 = .{ 0.0, 0.0, 0.0, 0.0 },

    pixel_delta_u: Vec4 = .{ 0.0, 0.0, 0.0, 0.0 },
    pixel_delta_v: Vec4 = .{ 0.0, 0.0, 0.0, 0.0 },

    viewport_upper_left_corner: Vec4 = .{ 0.0, 0.0, 0.0, 0.0 },
    pixel00_loc: Vec4 = .{ 0.0, 0.0, 0.0, 0.0 },

    samples_per_pixel: u32 = 10,
    pixel_samples_scale: f32 = 0.0,

    max_ray_bounces: u32 = 10,

    pub const Options = struct {
        image_width: ?u32,
        image_height: ?u32,
        viewport_height: ?f32,
        focal_length: ?f32,
        camera_center: ?Vec4,
        samples_per_pixel: ?u32,
        max_ray_bounces: ?u32,
    };

    pub fn init(options: Options) Camera {
        var camera: Camera = .{};

        camera.image_width = options.image_width orelse camera.image_width;
        camera.image_height = options.image_height orelse camera.image_height;
        camera.viewport_height = options.viewport_height orelse camera.viewport_height;
        camera.focal_length = options.focal_length orelse camera.focal_length;
        camera.center = options.camera_center orelse camera.center;
        camera.samples_per_pixel = options.samples_per_pixel orelse camera.samples_per_pixel;
        camera.max_ray_bounces = options.max_ray_bounces orelse camera.max_ray_bounces;

        const float_image_width: f32 = @floatFromInt(camera.image_width);
        const float_image_height: f32 = @floatFromInt(camera.image_height);
        const aspect_ratio: f32 = float_image_width / float_image_height;

        camera.viewport_width = camera.viewport_height * aspect_ratio;

        // Calculate the vectors across the horizontal and down the verical viewport edges
        camera.viewport_u = .{ camera.viewport_width, 0.0, 0.0, 0.0 };
        camera.viewport_v = .{ 0, -camera.viewport_height, 0.0, 0.0 };

        // Calculate the horizontal and vertical delta vectors from to pixel to pixel in the viewport
        camera.pixel_delta_u = camera.viewport_u / vector.splat(float_image_width);
        camera.pixel_delta_v = camera.viewport_v / vector.splat(float_image_height);

        // Calculate the location of the upper left pixel in the viewport
        camera.viewport_upper_left_corner = camera.center - vector.initVec4(0.0, 0.0, camera.focal_length, 0.0) - camera.viewport_u / vector.splat(2.0) - camera.viewport_v / vector.splat(2.0);
        camera.pixel00_loc = camera.viewport_upper_left_corner + vector.splat(0.5) * (camera.pixel_delta_u + camera.pixel_delta_v);

        camera.pixel_samples_scale = 1.0 / @as(f32, @floatFromInt(camera.samples_per_pixel));

        return camera;
    }

    pub fn renderPixel(self: Camera, row: usize, column: usize, world: World, rng: std.Random) Vec4 {
        var pixel_color: Vec4 = vector.zero();
        for (0..self.samples_per_pixel) |_| {
            const ray = self.getRay(row, column, rng);
            pixel_color += self.getRayColor(
                ray,
                world,
                rng,
                self.max_ray_bounces,
            );
        }
        pixel_color *= vector.splat(self.pixel_samples_scale);
        return pixel_color;
    }

    fn getRay(self: Camera, row: usize, column: usize, rng: std.Random) Ray {
        const float_row: f32 = @floatFromInt(row);
        const float_column: f32 = @floatFromInt(column);

        const offset = sample_square(rng);
        const pixel_sample: Vec4 = self.pixel00_loc +
            (vector.splat(float_row + offset[0]) * self.pixel_delta_v) +
            (vector.splat(float_column + offset[1]) * self.pixel_delta_u);

        const ray_origin: Vec4 = self.center;
        const ray_direction: Vec4 = pixel_sample - ray_origin;

        return .init(ray_origin, ray_direction);
    }

    fn sample_square(rng: std.Random) Vec4 {
        return .{ rand.randomFloat(rng) - 0.5, rand.randomFloat(rng) - 0.5, 0, 0 };
    }

    fn getRayColor(self: Camera, ray: Ray, world: World, rng: std.Random, depth: u32) Vec4 {
        if (depth <= 0) {
            return vector.zero();
        }

        const hit_res = world.hit(
            ray,
            0.001,
        );
        if (hit_res) |hit| {
            // Randomly generating a vector according to Lambertian distribution
            // S - random point on the unit sphere
            // P - hit point
            // n - hit normal
            // P + n - center of the unit sphere
            // r - random vector on the unit sphere
            // S = P + n + r => S - P = n + r
            const direction = hit.normal + vector.randomOnUnitSphere(rng);
            const next_ray: Ray = .init(hit.point, direction);
            return vector.splat(0.5) * self.getRayColor(
                next_ray,
                world,
                rng,
                depth - 1,
            );
        }

        const unit_direction: Vec4 = vector.normalized(ray.direction);
        const a = 0.5 * (unit_direction[1] + 1.0);
        return vector.splat(1.0 - a) * vector.initVec4(1.0, 1.0, 1.0, 1.0) + vector.splat(a) * vector.initVec4(1.0, 0.1725, 0.1725, 1.0);
    }
};

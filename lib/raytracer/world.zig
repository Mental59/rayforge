const std = @import("std");
const primitives = @import("primitives.zig");
const Ray = @import("ray.zig").Ray;
const Sphere = primitives.Sphere;
const IHittable = primitives.IHittable;
const HitResult = primitives.HitResult;
const HitOptions = primitives.HitOptions;

pub const World = struct {
    allocator: std.mem.Allocator,
    spheres: std.ArrayList(Sphere),

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !World {
        const spheres: std.ArrayList(Sphere) = try .initCapacity(allocator, capacity);
        return .{
            .allocator = allocator,
            .spheres = spheres,
        };
    }

    pub fn deinit(self: *World) void {
        self.spheres.deinit(self.allocator);
    }

    pub fn addSphere(self: *World, sphere: Sphere) !void {
        try self.spheres.append(self.allocator, sphere);
    }

    pub fn hit(self: World, ray: Ray, min_ray_t: f32) ?HitResult {
        var final_hit_result: ?HitResult = null;
        var closest_hit_t = std.math.inf(f32);

        for (self.spheres.items) |sphere| {
            if (sphere.hittable().hit(
                ray,
                .{ .ray_t = .init(min_ray_t, closest_hit_t) },
            )) |hit_res| {
                final_hit_result = hit_res;
                closest_hit_t = hit_res.t;
            }
        }

        return final_hit_result;
    }
};

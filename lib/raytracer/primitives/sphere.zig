const root_module = @import("../root.zig");
const Ray = @import("../ray.zig").Ray;
const hittable_module = @import("../hittable.zig");
const Material = @import("../materials/material.zig").Material;
const vector = root_module.vector;
const Interval = root_module.Interval;
const Vec4 = vector.Vec4;

pub const Sphere = struct {
    center: Vec4,
    radius: f32,
    material: Material,

    const vtable: hittable_module.IHittable.VTable = .{
        .hit = hit,
    };

    pub fn init(center: Vec4, radius: f32, material: Material) Sphere {
        return .{
            .center = center,
            .radius = radius,
            .material = material,
        };
    }

    pub fn hittable(self: *const Sphere) hittable_module.IHittable {
        return .{
            .ptr = self,
            .vtable = &vtable,
        };
    }

    fn hit(
        ptr: *const anyopaque,
        ray: Ray,
        options: hittable_module.HitOptions,
    ) ?hittable_module.HitResult {
        const self: *const Sphere = @ptrCast(@alignCast(ptr));

        const oc: Vec4 = self.center - ray.origin;

        const a: f32 = vector.dot(ray.direction, ray.direction);
        const h: f32 = vector.dot(ray.direction, oc);
        const c: f32 = vector.dot(oc, oc) - self.radius * self.radius;

        const discriminant: f32 = h * h - a * c;
        if (discriminant < 0) {
            return null;
        }

        // Find the nearest root that lies in the acceptable range
        var root = (h - @sqrt(discriminant)) / a;
        if (!options.ray_t.surrounds(root)) {
            root = (h + @sqrt(discriminant)) / a;
            if (!options.ray_t.surrounds(root)) {
                return null;
            }
        }

        const point: Vec4 = ray.at(root);
        const normal: Vec4 = (point - self.center) / vector.splat(self.radius);

        const hit_result: hittable_module.HitResult = .init(
            ray,
            point,
            normal,
            root,
            self.material,
        );
        return hit_result;
    }

    fn isRootInRange(root: f32, tmin: f32, tmax: f32) bool {
        return root > tmin and root < tmax;
    }
};

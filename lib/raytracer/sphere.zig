const Ray = @import("ray.zig").Ray;
const vector = @import("root.zig").vector;
const Vec4 = vector.Vec4;

pub const Sphere = struct {
    center: Vec4,
    radius: f32,

    pub fn init(center: Vec4, radius: f32) Sphere {
        return .{ .center = center, .radius = radius };
    }

    pub fn hitSphereByRay(self: Sphere, ray: Ray) bool {
        const oc: Vec4 = self.center - ray.origin;

        const a: f32 = vector.dot(ray.direction, ray.direction);
        const b: f32 = -2.0 * vector.dot(ray.direction, oc);
        const c: f32 = vector.dot(oc, oc) - self.radius * self.radius;

        const discriminant: f32 = b * b - 4 * a * c;
        return discriminant >= 0;
    }
};

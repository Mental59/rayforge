const Ray = @import("ray.zig").Ray;
const vector = @import("root.zig").vector;
const Vec4 = vector.Vec4;

pub const HitResult = struct {
    point: Vec4,
    normal: Vec4,
};

pub const Sphere = struct {
    center: Vec4,
    radius: f32,

    pub fn init(center: Vec4, radius: f32) Sphere {
        return .{ .center = center, .radius = radius };
    }

    pub fn hitSphereByRay(self: Sphere, ray: Ray) ?HitResult {
        const oc: Vec4 = self.center - ray.origin;

        const a: f32 = vector.dot(ray.direction, ray.direction);
        const h: f32 = vector.dot(ray.direction, oc);
        const c: f32 = vector.dot(oc, oc) - self.radius * self.radius;

        const discriminant: f32 = h * h - a * c;
        if (discriminant < 0) {
            return null;
        }

        const t_closest = (h - @sqrt(discriminant)) / a;
        const point = ray.at(t_closest);
        const normal = vector.normalized(point - self.center);
        return .{ .point = point, .normal = normal };
    }
};

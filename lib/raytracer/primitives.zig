const Ray = @import("ray.zig").Ray;
const vector = @import("root.zig").vector;
const Vec4 = vector.Vec4;

pub const Sphere = struct {
    center: Vec4,
    radius: f32,

    const vtable: IHittable.VTable = .{
        .hit = hit,
    };

    pub fn init(center: Vec4, radius: f32) Sphere {
        return .{ .center = center, .radius = radius };
    }

    pub fn hittable(self: *Sphere) IHittable {
        return .{
            .ptr = self,
            .vtable = &vtable,
        };
    }

    fn hit(ptr: *anyopaque, ray: Ray, options: HitOptions) ?HitResult {
        const self: *Sphere = @ptrCast(@alignCast(ptr));

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
        if (!isRootInRange(root, options.tmin, options.tmax)) {
            root = (h + @sqrt(discriminant)) / a;
            if (!isRootInRange(root, options.tmin, options.tmax)) {
                return null;
            }
        }

        const point: Vec4 = ray.at(root);
        const normal: Vec4 = (point - self.center) / vector.splat(self.radius);

        return .{
            .point = point,
            .normal = normal,
            .t = root,
        };
    }

    fn isRootInRange(root: f32, tmin: f32, tmax: f32) bool {
        return root > tmin and root < tmax;
    }
};

pub const HitResult = struct {
    point: Vec4,
    normal: Vec4,
    t: f32,
};

pub const HitOptions = struct { tmin: f32, tmax: f32 };

pub const IHittable = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        hit: *const fn (
            *anyopaque,
            ray: Ray,
            options: HitOptions,
        ) ?HitResult,
    };

    pub fn hit(self: IHittable, ray: Ray, options: HitOptions) ?HitResult {
        return self.vtable.hit(self.ptr, ray, options);
    }
};

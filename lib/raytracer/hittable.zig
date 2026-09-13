const root_module = @import("root.zig");
const Ray = @import("ray.zig").Ray;
const Material = @import("materials/material.zig").Material;
const vector = root_module.vector;
const Interval = root_module.Interval;
const Vec4 = vector.Vec4;

pub const IHittable = struct {
    ptr: *const anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        hit: *const fn (
            *const anyopaque,
            ray: Ray,
            options: HitOptions,
        ) ?HitResult,
    };

    pub fn hit(self: IHittable, ray: Ray, options: HitOptions) ?HitResult {
        return self.vtable.hit(self.ptr, ray, options);
    }
};

pub const HitResult = struct {
    point: Vec4,
    normal: Vec4,
    t: f32,
    is_front_face: bool,
    material: Material,

    pub fn init(
        ray: Ray,
        point: Vec4,
        normal: Vec4,
        t: f32,
        material: Material,
    ) HitResult {
        const is_front_face = vector.dot(ray.direction, normal) < 0.0;
        return .{
            .point = point,
            .normal = if (is_front_face) normal else -normal,
            .t = t,
            .is_front_face = is_front_face,
            .material = material,
        };
    }
};

pub const HitOptions = struct {
    ray_t: Interval,
};

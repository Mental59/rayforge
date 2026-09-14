const std = @import("std");
const root = @import("../root.zig");
const material = @import("material.zig");
const ScatterFn = material.ScatterFn;
const ScatterResult = material.ScatterResult;
const Material = material.Material;
const hittable = @import("../hittable.zig");
const Ray = @import("../ray.zig").Ray;
const vector = root.vector;

pub const scatter: ScatterFn = scatterImpl;

fn scatterImpl(self: Material, ray_in: Ray, hit: hittable.HitResult, rng: std.Random) ?ScatterResult {
    _ = rng;

    const ri: f32 = if (hit.is_front_face) 1.0 / self.props.refraction_index else self.props.refraction_index;

    const unit_direction = vector.normalized(ray_in.direction);
    const refracted = vector.refract(unit_direction, hit.normal, ri);

    const scattered: Ray = .init(hit.point, refracted);
    const res: ScatterResult = .{
        .attenuation = self.props.albedo,
        .scattered = scattered,
    };

    return res;
}

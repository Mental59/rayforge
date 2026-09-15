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
    const eta: f32 = if (hit.is_front_face) 1.0 / self.props.refraction_index else self.props.refraction_index;

    const unit_direction = vector.normalized(ray_in.direction);
    const cos_theta = @min(vector.dot(-unit_direction, hit.normal), 1.0);
    const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

    const can_refract = eta * sin_theta <= 1.0;
    const direction = if (can_refract and reflectance(cos_theta, eta) <= rng.float(f32))
        vector.refract(unit_direction, hit.normal, eta)
    else
        vector.reflect(unit_direction, hit.normal);

    const scattered: Ray = .init(hit.point, direction);
    const res: ScatterResult = .{
        .attenuation = self.props.albedo,
        .scattered = scattered,
    };

    return res;
}

fn reflectance(cos_theta: f32, eta: f32) f32 {
    // Use Schlick's approximation for reflectance
    var r0 = (1.0 - eta) / (1.0 + eta);
    r0 *= r0;
    return r0 + (1.0 - r0) * std.math.pow(f32, 1.0 - cos_theta, 5.0);
}

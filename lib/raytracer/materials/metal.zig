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
    var reflected = vector.reflect(ray_in.direction, hit.normal);
    reflected = vector.normalized(reflected) +
        (vector.splat(self.props.fuzz) * vector.randomOnUnitSphere(rng));

    const scattered_ray: Ray = .init(hit.point, reflected);
    const scatter_res: ScatterResult = .{
        .scattered = scattered_ray,
        .attenuation = self.props.albedo,
    };

    if (vector.dot(scattered_ray.direction, hit.normal) <= 0.0) {
        return null;
    }

    return scatter_res;
}

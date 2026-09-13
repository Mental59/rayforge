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
    _ = ray_in;

    // Randomly generating a vector according to Lambertian distribution
    // S - random point on the unit sphere
    // P - hit point
    // n - hit normal
    // P + n - center of the unit sphere
    // r - random vector on the unit sphere
    // S = P + n + r => S - P = n + r
    var scatter_dir = hit.normal + vector.randomOnUnitSphere(rng);
    if (vector.isNearZero(scatter_dir)) {
        scatter_dir = hit.normal;
    }

    const scattered_ray: Ray = .init(hit.point, scatter_dir);

    const scatter_res: ScatterResult = .{
        .scattered = scattered_ray,
        .attenuation = self.props.albedo,
    };
    return scatter_res;
}

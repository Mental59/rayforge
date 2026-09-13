const std = @import("std");
const hittable = @import("../hittable.zig");
const Ray = @import("../ray.zig").Ray;
const root = @import("../root.zig");
const lambertianScatter = @import("lambertian.zig").scatter;
const metalScatter = @import("metal.zig").scatter;
const vector = root.vector;
const Vec4 = vector.Vec4;

pub const Material = struct {
    props: MaterialProps,
    scatter: ScatterFn,

    pub fn init(props: MaterialProps) Material {
        const scatter: ScatterFn = switch (props.type) {
            .Lambertian => lambertianScatter,
            .Metal => metalScatter,
        };

        var material_props = props;
        material_props.fuzz = if (material_props.fuzz < 1.0) material_props.fuzz else 1.0;

        return .{
            .props = material_props,
            .scatter = scatter,
        };
    }
};

pub const MaterialProps = struct {
    type: MaterialType,
    albedo: Vec4,
    fuzz: f32,
};

pub const MaterialType = enum {
    Lambertian,
    Metal,
};

pub const ScatterFn = *const fn (
    self: Material,
    ray_in: Ray,
    hit: hittable.HitResult,
    rng: std.Random,
) ?ScatterResult;

pub const ScatterResult = struct {
    attenuation: Vec4,
    scattered: Ray,
};

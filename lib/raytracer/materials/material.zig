const std = @import("std");
const hittable = @import("../hittable.zig");
const Ray = @import("../ray.zig").Ray;
const root = @import("../root.zig");
const lambertianScatter = @import("lambertian.zig").scatter;
const metalScatter = @import("metal.zig").scatter;
const dielectricScatter = @import("dielectric.zig").scatter;
const vector = root.vector;
const Vec4 = vector.Vec4;

pub const Material = struct {
    props: MaterialProps,
    scatter: ScatterFn,

    pub fn initLambertian(albedo: Vec4) Material {
        return .{
            .props = .{
                .type = .Lambertian,
                .albedo = albedo,
                .fuzz = 0.0,
                .refraction_index = 0.0,
            },
            .scatter = lambertianScatter,
        };
    }

    pub fn initMetal(albedo: Vec4, fuzz: f32) Material {
        return .{
            .props = .{
                .type = .Metal,
                .albedo = albedo,
                .fuzz = if (fuzz < 1.0) fuzz else 1.0,
                .refraction_index = 0.0,
            },
            .scatter = metalScatter,
        };
    }

    pub fn initDielectric(albedo: Vec4, refraction_index: f32) Material {
        return .{
            .props = .{
                .type = .Dielectric,
                .albedo = albedo,
                .fuzz = 0.0,
                .refraction_index = refraction_index,
            },
            .scatter = dielectricScatter,
        };
    }
};

pub const MaterialProps = struct {
    type: MaterialType,
    albedo: Vec4,
    fuzz: f32,
    refraction_index: f32,
};

pub const MaterialType = enum {
    Lambertian,
    Metal,
    Dielectric,
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

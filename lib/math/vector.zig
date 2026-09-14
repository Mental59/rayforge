const std = @import("std");
const rand = @import("random.zig");

pub const Vec4 = @Vector(4, f32);

pub fn initVec4(v1: f32, v2: f32, v3: f32, v4: f32) Vec4 {
    return .{ v1, v2, v3, v4 };
}

pub fn zero() Vec4 {
    return .{ 0.0, 0.0, 0.0, 0.0 };
}

pub fn splat(v: f32) Vec4 {
    return @splat(v);
}

pub fn dot(a: Vec4, b: Vec4) f32 {
    return @reduce(.Add, a * b);
}

pub fn length(vec: Vec4) f32 {
    return @sqrt(dot(vec, vec));
}

pub fn lengthSquared(vec: Vec4) f32 {
    return dot(vec, vec);
}

pub fn normalized(vec: Vec4) Vec4 {
    const lenVec: Vec4 = @splat(length(vec));
    return vec / lenVec;
}

pub fn isNearZero(vec: Vec4) bool {
    const tolerance = 1e-5;
    return std.math.approxEqAbs(f32, vec[0], 0.0, tolerance) and
        std.math.approxEqAbs(f32, vec[1], 0.0, tolerance) and
        std.math.approxEqAbs(f32, vec[2], 0.0, tolerance) and
        std.math.approxEqAbs(f32, vec[3], 0.0, tolerance);
}

pub fn reflect(v: Vec4, n: Vec4) Vec4 {
    return v - splat(2.0 * dot(v, n)) * n;
}

pub fn refract(v: Vec4, n: Vec4, eta: f32) Vec4 {
    const k = 1.0 - eta * eta * (1.0 - dot(n, v) * dot(n, v));
    if (k < 0.0) {
        return zero();
    }
    return splat(eta) * v - splat(eta * dot(n, v) + @sqrt(k)) * n;
}

/// Cross product of the XYZ components.
/// The resulting W component is always 0.
pub fn cross(a: Vec4, b: Vec4) Vec4 {
    const t0 = @shuffle(
        f32,
        a,
        undefined,
        @Vector(4, i32){ 1, 2, 0, 3 },
    );
    const t1 = @shuffle(
        f32,
        b,
        undefined,
        @Vector(4, i32){ 2, 0, 1, 3 },
    );
    const t2 = @shuffle(
        f32,
        a,
        undefined,
        @Vector(4, i32){ 2, 0, 1, 3 },
    );
    const t3 = @shuffle(
        f32,
        b,
        undefined,
        @Vector(4, i32){ 1, 2, 0, 3 },
    );
    return t0 * t1 - t2 * t3;
}

/// Generate a vector with random x, y and z components in the range [0, 1),
/// leaving the w component equal to 0.
pub fn random3(rng: std.Random) Vec4 {
    return .{
        rand.randomFloat(rng),
        rand.randomFloat(rng),
        rand.randomFloat(rng),
        0.0,
    };
}

/// Generate a vector with random x, y and z components in the range [min, max),
/// leaving the w component equal to 0.
pub fn random3Range(rng: std.Random, min: f32, max: f32) Vec4 {
    return .{
        rand.randomFloatMinMax(rng, min, max),
        rand.randomFloatMinMax(rng, min, max),
        rand.randomFloatMinMax(rng, min, max),
        0.0,
    };
}

pub fn randomOnUnitSphere(rng: std.Random) Vec4 {
    return normalized(.{
        rng.floatNorm(f32),
        rng.floatNorm(f32),
        rng.floatNorm(f32),
        0.0,
    });
}

pub fn randomOnHemisphere(rng: std.Random, normal: Vec4) Vec4 {
    const on_unit_sphere = randomOnUnitSphere(rng);
    if (dot(on_unit_sphere, normal) > 0.0) {
        return on_unit_sphere;
    } else {
        return -on_unit_sphere;
    }
}

const std = @import("std");

pub fn randomFloat(rng: std.Random) f32 {
    return rng.float(f32);
}

pub fn randomFloatMinMax(rng: std.Random, min: f32, max: f32) f32 {
    return rng.float(f32) * (max - min) + min;
}

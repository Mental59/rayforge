pub const Vector4 = struct {
    const T = @Vector(4, f32);

    pub fn init(v1: f32, v2: f32, v3: f32, v4: f32) T {
        return .{ v1, v2, v3, v4 };
    }

    pub fn dot(a: T, b: T) f32 {
        return @reduce(.Add, a * b);
    }

    pub fn length(vec: T) f32 {
        return @sqrt(dot(vec, vec));
    }

    pub fn lengthSquared(vec: T) f32 {
        return dot(vec, vec);
    }

    pub fn normalized(vec: T) T {
        const lenVec: T = @splat(length(vec));
        return vec / lenVec;
    }

    /// Cross product of the XYZ components.
    /// The resulting W component is always 0.
    pub fn cross(a: T, b: T) T {
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
};

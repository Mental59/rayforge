const vector = @import("root.zig").vector;

pub const Ray = struct {
    origin: vector.Vec4,
    direction: vector.Vec4,

    pub const zero = init(vector.zero(), vector.zero());

    pub fn init(origin: vector.Vec4, direction: vector.Vec4) Ray {
        return .{ .origin = origin, .direction = direction };
    }

    pub fn at(self: Ray, t: f32) vector.Vec4 {
        return self.origin + vector.splat(t) * self.direction;
    }
};

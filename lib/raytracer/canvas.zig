const std = @import("std");

pub fn Canvas(comptime T: type) type {
    if (T != f16 and T != f32 and T != f64 and T != f128) {
        @compileError("Only floats allowed");
    }

    return struct {
        const Self = @This();

        pub const Color = struct {
            r: T,
            g: T,
            b: T,
        };

        width: usize,
        height: usize,
        data: []Color,
        allocator: std.mem.Allocator,

        pub fn init(width: usize, height: usize, allocator: std.mem.Allocator) !Self {
            const data = try allocator.alloc(Color, width * height);
            @memset(data, Color{ .r = 0.0, .g = 0.0, .b = 0.0 });

            return .{
                .width = width,
                .height = height,
                .data = data,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.data);
        }

        pub fn getAt(self: Self, row: usize, col: usize) Color {
            std.debug.assert(row < self.height and col < self.width);

            const index = self.getIndex(row, col);
            return self.data[index];
        }

        pub fn setAt(self: *Self, row: usize, col: usize, value: Color) void {
            std.debug.assert(row < self.height and col < self.width);

            const index = self.getIndex(row, col);
            self.data[index] = value;
        }

        pub fn writePPM(self: Self, writer: *std.Io.File.Writer) !void {
            try writer.interface.print(
                "P3\n{d} {d}\n255\n",
                .{ self.width, self.height },
            );

            for (0..self.height) |i| {
                for (0..self.width) |j| {
                    const index = self.getIndex(i, j);
                    const color = self.data[index];

                    const r: u8 = @intFromFloat(color.r * 255.0);
                    const g: u8 = @intFromFloat(color.g * 255.0);
                    const b: u8 = @intFromFloat(color.b * 255.0);

                    try writer.interface.print("{d} {d} {d}\n", .{ r, g, b });
                }
            }
        }

        fn getIndex(self: Self, row: usize, col: usize) usize {
            return row * self.width + col;
        }
    };
}

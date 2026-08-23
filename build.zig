const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const app = b.addExecutable(.{
        .name = "rayforge",
        .root_module = b.createModule(.{
            .root_source_file = b.path("app/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const math = b.addModule("math", .{
        .root_source_file = b.path("lib/math/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const raytracer = b.addModule("raytracer", .{
        .root_source_file = b.path("lib/raytracer/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    raytracer.addImport("math", math);

    app.root_module.addImport("raytracer", raytracer);

    b.installArtifact(app);

    const run_exe = b.addRunArtifact(app);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}

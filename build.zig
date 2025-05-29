const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options (e.g., native or cross-compilation).
    const target = b.standardTargetOptions(.{});

    // Standard optimization options (Debug, ReleaseSafe, etc.).
    const optimize = b.standardOptimizeOption(.{});

    // Create a module for the lock-free queue library.
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/lockFreeQueue.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create a static library.
    const lib = b.addLibrary(.{
        .name = "LockFreeQueue",
        .root_module = lib_mod,
        .linkage = .static,
    });

    // Install the library artifact (e.g., to zig-out/lib when running `zig build install`).
    b.installArtifact(lib);

    // Create a test step explicitly for the test file.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("test/lockFreeQueue_test.zig"),
        .target = target,
        .optimize = optimize,
        .name = "lockfree-queue-tests",
    });

    // Add the library module as a dependency for the tests.
    lib_unit_tests.root_module.addImport("lockfree_queue", lib_mod);

    // Create a run step for the tests.
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    // Add verbosity to see test output
    run_lib_unit_tests.has_side_effects = true;

    // Create a "test" step for running unit tests via `zig build test`.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

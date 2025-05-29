const std = @import("std");
const LockFreeQueue = @import("lockfree_queue").LockFreeQueue;
const testing = std.testing;

test "enqueue and dequeue basic functionality" {
    const gpa = testing.allocator;
    var queue = try LockFreeQueue(i32).init(gpa);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);

    const val1 = try queue.dequeue();
    try testing.expectEqual(1, val1);

    const val2 = try queue.dequeue();
    try testing.expectEqual(2, val2);

    try testing.expectError(error.QueueEmpty, queue.dequeue());
}

test "enqueue and dequeue multiple types" {
    const gpa = testing.allocator;

    // Test with i32
    {
        var queue = try LockFreeQueue(i32).init(gpa);
        defer queue.deinit();

        try queue.enqueue(42);
        try queue.enqueue(-10);
        try testing.expectEqual(42, try queue.dequeue());
        try testing.expectEqual(-10, try queue.dequeue());
        try testing.expectError(error.QueueEmpty, queue.dequeue());
    }

    // Test with f32
    {
        var queue = try LockFreeQueue(f32).init(gpa);
        defer queue.deinit();

        try queue.enqueue(3.14);
        try queue.enqueue(2.718);
        try testing.expectEqual(3.14, try queue.dequeue());
        try testing.expectEqual(2.718, try queue.dequeue());
        try testing.expectError(error.QueueEmpty, queue.dequeue());
    }

    // Test with a struct
    const TestStruct = struct { x: i32, y: i32 };
    {
        var queue = try LockFreeQueue(TestStruct).init(gpa);
        defer queue.deinit();

        try queue.enqueue(.{ .x = 1, .y = 2 });
        try queue.enqueue(.{ .x = 3, .y = 4 });
        try testing.expectEqual(TestStruct{ .x = 1, .y = 2 }, try queue.dequeue());
        try testing.expectEqual(TestStruct{ .x = 3, .y = 4 }, try queue.dequeue());
        try testing.expectError(error.QueueEmpty, queue.dequeue());
    }
}

test "enqueue many elements" {
    const gpa = testing.allocator;
    var queue = try LockFreeQueue(i32).init(gpa);
    defer queue.deinit();

    const count = 1000;
    for (0..count) |i| {
        try queue.enqueue(@intCast(i));
    }

    for (0..count) |i| {
        try testing.expectEqual(@as(i32, @intCast(i)), try queue.dequeue());
    }

    try testing.expectError(error.QueueEmpty, queue.dequeue());
}

test "interleaved enqueue and dequeue" {
    const gpa = testing.allocator;
    var queue = try LockFreeQueue(i32).init(gpa);
    defer queue.deinit();

    try queue.enqueue(1);
    try testing.expectEqual(1, try queue.dequeue());
    try queue.enqueue(2);
    try queue.enqueue(3);
    try testing.expectEqual(2, try queue.dequeue());
    try queue.enqueue(4);
    try testing.expectEqual(3, try queue.dequeue());
    try testing.expectEqual(4, try queue.dequeue());
    try testing.expectError(error.QueueEmpty, queue.dequeue());
}

test "memory management" {
    const gpa = testing.allocator;
    var queue = try LockFreeQueue(i32).init(gpa);
    defer queue.deinit();

    // Enqueue and dequeue repeatedly to ensure no memory leaks
    for (0..100) |i| {
        try queue.enqueue(@intCast(i));
        try testing.expectEqual(@as(i32, @intCast(i)), try queue.dequeue());
    }

    // Ensure queue is empty after operations
    try testing.expectError(error.QueueEmpty, queue.dequeue());
}

test "empty queue behavior" {
    const gpa = testing.allocator;
    var queue = try LockFreeQueue(i32).init(gpa);
    defer queue.deinit();

    // Dequeue on empty queue
    try testing.expectError(error.QueueEmpty, queue.dequeue());

    // Enqueue after empty dequeue
    try queue.enqueue(42);
    try testing.expectEqual(42, try queue.dequeue());
    try testing.expectError(error.QueueEmpty, queue.dequeue());
}

test "concurrent enqueue and dequeue" {
    const gpa = testing.allocator;
    var queue = try LockFreeQueue(i32).init(gpa);
    defer queue.deinit();

    const ThreadCount = 4;
    const OpsPerThread = 1000;

    var handles: [ThreadCount]std.Thread = undefined;

    // Spawn threads to enqueue values concurrently
    for (0..ThreadCount) |t| {
        handles[t] = try std.Thread.spawn(.{}, struct {
            fn run(q: *LockFreeQueue(i32), tid: usize) void {
                const base = @as(i32, @intCast(tid * OpsPerThread));
                for (0..OpsPerThread) |i| {
                    _ = q.enqueue(base + @as(i32, @intCast(i))) catch unreachable;
                }
            }
        }.run, .{ queue, t }); // Fixed: Pass queue directly
    }

    // Wait for all threads to finish enqueuing
    for (handles) |h| h.join();

    // Dequeue everything in the main thread
    var count: usize = 0;
    while (count < ThreadCount * OpsPerThread) {
        if (queue.dequeue()) |_| {
            count += 1;
        } else |err| {
            try testing.expect(err != error.QueueCorrupted);
        }
    }

    try testing.expectError(error.QueueEmpty, queue.dequeue());
}

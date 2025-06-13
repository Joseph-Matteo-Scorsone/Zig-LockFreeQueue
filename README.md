# LockFreeQueue

A high-performance, lock-free queue implementation in Zig, based on the Michael-Scott algorithm. Designed for concurrent applications requiring efficient, thread-safe FIFO (First-In-First-Out) data structures.

# Features
- Lock-Free Design: Utilizes atomic operations to enable multiple threads to enqueue and dequeue without traditional locking mechanisms.

- Michael-Scott Algorithm: Implements the well-known non-blocking queue algorithm for safe concurrent access.

- Generic Implementation: Supports queues of any data type through Zig's generics.

- Allocator Agnostic: Compatible with any allocator conforming to Zig's Allocator interface.

- Minimal Dependencies: Built solely with Zig's standard library, ensuring ease of integration.

# Installation

## To include Zig-LockFreeQueue in your project:

### Clone the Repository:
```git clone https://github.com/Joseph-Matteo-Scorsone/Zig-LockFreeQueue.git```

### Integrate into Your build.zig:
```
const lockfree_queue = b.createModule(.{
        .root_source_file = b.path("Zig-LockFreeQueue/src/lockFreeQueue.zig"),
});

exe_mod.addImport("lockfree_queue", lockfree_queue);
```
### Make sure "Zig-LockFreeQueue/src" is the actual path to the cloned repository.

# Usage
Here's a basic example of how to use Zig-LockFreeQueue:
```
const std = @import("std");
const LockFreeQueue = @import("lockfree_queue").LockFreeQueue;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var queue = try LockFreeQueue(i32).init(allocator);
    defer queue.deinit();

    try queue.enqueue(42);
<<<<<<< HEAD

    std.debug.print("Value: {any}\n", .{queue.peek()});

=======
>>>>>>> 503650b9c05047df1fce1fc4a679d212f1bfb5f2
    std.debug.print("Dequeued value: {any}\n", .{queue.dequeue()});

    std.debug.print("Queue is empty.\n", .{});
}
```

# API
```init(allocator: *Allocator) !LockFreeQueue(T)```
Initializes a new lock-free queue for type T using the provided allocator.

```deinit(self: *LockFreeQueue(T)) void```
Deinitializes the queue, releasing any allocated resources.

```enqueue(self: *LockFreeQueue(T), value: T) !void```
Adds a value to the end of the queue.

<<<<<<< HEAD
```peek(self: *LockFreeQueue(T)) ?void```
Returns the value at the front of the queue without removing it, or null if the queue is empty.

=======
>>>>>>> 503650b9c05047df1fce1fc4a679d212f1bfb5f2
```dequeue(self: *LockFreeQueue(T)) ?T```
Removes and returns a value from the front of the queue. Returns null if the queue is empty.

# Testing
## To run the test suite:

```zig build test```
Ensure that all tests pass to verify the correctness of the implementation.

# Contributing
Contributions are welcome! If you have suggestions, bug reports, or enhancements, please open an issue or submit a pull request.

# License
This project is licensed under the MIT License. See the LICENSE file for details.

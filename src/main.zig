const std = @import("std");
const fmt = std.fmt;
const Zigsaw = @import("zigsaw.zig").Zigsaw;
const FrameBuffer = @import("zigsaw.zig").FrameBuffer;
const MemoryMap = @import("zigsaw.zig").MemoryMap;
const serial = @import("serial.zig");
const builtin = std.builtin;
const x86 = @import("x86.zig");
const CpuInfo = @import("cpu.zig").CpuInfo;
const pmm = @import("pmm.zig");

var buf: [1024]u8 = undefined;
var fixed_allocator_buffer: [1024 * 1024]u8 = undefined;
var fixed_allocator: std.heap.FixedBufferAllocator = std.heap.FixedBufferAllocator.init(fixed_allocator_buffer[0..]);

pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);
    serial.writeString("PANIC: ");
    serial.writeString(msg);
    serial.writeString("\n");
    if (error_return_trace) |trc| {
        var last_addr: usize = 0;
        for (trc.instruction_addresses) |ret_addr| {
            if (ret_addr != last_addr) serial.printf(buf[0..], "{x}\n", .{ret_addr});
            last_addr = ret_addr;
        }
    } else {
        const first_ret_addr = @returnAddress();
        var last_addr: usize = 0;
        var it = std.debug.StackIterator.init(first_ret_addr, null);
        while (it.next()) |ret_addr| {
            if (ret_addr != last_addr) serial.printf(buf[0..], "{x}\n", .{ret_addr});
            last_addr = ret_addr;
        }
    }
    serial.writeString("Goodbye!\n");
    while (true) {}
}

export fn _start(zigsaw: *Zigsaw) noreturn {
    var fb: [*]u8 = @intToPtr([*]u8, zigsaw.frame_buffer.base);
    var i: u32 = 0;
    var cpu_id: CpuInfo = undefined;

    serial.init();
    serial.writeString("hello\n");
    cpu_id = CpuInfo.init();
    cpu_id.printVendorId();

    pmm.init(zigsaw.memory_map.map[0..zigsaw.memory_map.num], &fixed_allocator.allocator) catch unreachable;
    //    pmm.print();

    serial.printf(buf[0..], "memorymap: {}", .{zigsaw.memory_map.map[2]});
    while (i < zigsaw.frame_buffer.hr * zigsaw.frame_buffer.vr * 4) : (i += 4) {
        fb[i] = 0;
        fb[i + 1] = 255;
        fb[i + 2] = 0;
    }
    while (true) {}
}

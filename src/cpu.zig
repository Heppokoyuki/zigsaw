const x86 = @import("x86.zig");
const serial = @import("serial.zig");

var buf: [100]u8 = undefined;

pub const Cpuid = struct {
    eax: u32,
    ebx: u32,
    ecx: u32,
    edx: u32,
};

pub fn init() void {
    var data: Cpuid = undefined;

    data = x86.cpuid(0);
    serial.printf(buf[0..], "vendor: {} {} {}\n", .{ data.ebx, data.ecx, data.edx });
}

const x86 = @import("x86.zig");
const serial = @import("serial.zig");

pub const Cpuid = struct {
    eax: u32,
    ebx: u32,
    ecx: u32,
    edx: u32,
};

pub const CpuInfo = struct {
    vendor_id: [12]u8,

    pub fn init() CpuInfo {
        var vendor_id: [12]u8 = undefined;
        var data: Cpuid = undefined;

        data = x86.cpuid(0);
        vendor_id = parseVendorId(data);

        return .{
            .vendor_id = vendor_id,
        };
    }

    fn parseVendorId(data: Cpuid) [12]u8 {
        var string = [3]u32{ data.ebx, data.edx, data.ecx };
        return @bitCast([12]u8, string);
    }

    pub fn printVendorId(self: CpuInfo) void {
        var buf: [50]u8 = undefined;
        serial.printf(buf[0..], "Vendor: {s}\n", .{self.vendor_id});
    }
};

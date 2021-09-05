const std = @import("std");
const uefi = std.os.uefi;
const MemoryDescriptor = uefi.tables.MemoryDescriptor;
const MemoryType = uefi.tables.MemoryType;
const LinkedList = @import("linked_list.zig").LinkedList;
const Allocator = std.mem.Allocator;

const PmmList = LinkedList(PMM_block);

var list: PmmList = undefined;

pub const PMM_block = struct {
    base: u64,
    count: u64,
};

pub fn init(map: []MemoryDescriptor, allocator: *Allocator) !void {
    list = PmmList.init(allocator);
    for (map) |desc| {
        if (desc.type != MemoryType.BootServicesCode and
            desc.type != MemoryType.BootServicesData and
            desc.type != MemoryType.ConventionalMemory)
            continue;

        try add_region(desc.physical_start, desc.number_of_pages);
    }
}

pub fn print() void {
    list.print();
}

fn add_region(start: u64, page_count: u64) !void {
    const region = PMM_block{
        .base = start,
        .count = page_count,
    };
    try list.append(region);
}

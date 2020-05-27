const std = @import("std");
const Builder = std.build.Builder;
const Target = std.build.Target;
const builtin = @import("builtin");

pub fn build(b: *Builder) !void {
    const mode = b.standardReleaseOptions();

    const bootloader = b.addExecutable("BOOTX64", "bootloader/src/main.zig");
    bootloader.setTarget(.{
        .cpu_arch = .x86_64,
        .os_tag = .uefi,
        .abi = .msvc,
    });
    bootloader.setOutputDir("fs/EFI/BOOT");
    bootloader.setBuildMode(mode);

    const zigsaw = b.addExecutable("zigsaw", "src/main.zig");
    zigsaw.setTarget(.{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
        .abi = .gnu,
    });
    zigsaw.setOutputDir("fs");
    zigsaw.setLinkerScriptPath("src/linker.ld");
    zigsaw.setBuildMode(mode);
    zigsaw.step.dependOn(&bootloader.step);
    b.default_step.dependOn(&zigsaw.step);

    const run = b.step("run", "Run the system on QEMU");
    var qemu_args = std.ArrayList([]const u8).init(b.allocator);
    try qemu_args.appendSlice(&[_][]const u8{
        "qemu-system-x86_64",
        "-nographic",
        "-bios",
        "ovmf/OVMF.fd",
        "-drive",
        "format=raw,file=fat:rw:fs",
    });
    const run_qemu = b.addSystemCommand(qemu_args.items);
    run_qemu.step.dependOn(&zigsaw.step);
    run.dependOn(&run_qemu.step);
}

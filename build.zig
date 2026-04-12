// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zlua = b.dependency("zlua", .{
        .target = target,
        .optimize = optimize,
        .lang = .lua52,
        .shared = false,
    });

    const ziglua_mod = zlua.module("zlua");

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");

    raylib_artifact.root_module.addCMacro(
        "SUPPORT_FILEFORMAT_JPG",
        "0",
    );

    raylib_artifact.root_module.addCMacro(
        "SUPPORT_FILEFORMAT_GIF",
        "0",
    );

    const mod = b.addModule("MokaByte", .{
        .root_source_file = b.path("src/core/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{
            .name = "ziglua",
            .module = ziglua_mod,
        }},
    });

    const exe = b.addExecutable(.{
        .name = "MokaByte",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/system/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{
                    .name = "MokaByte",
                    .module = mod,
                },
                .{
                    .name = "ziglua",
                    .module = ziglua_mod,
                },
                .{
                    .name = "raylib",
                    .module = raylib,
                },
                .{
                    .name = "raygui",
                    .module = raygui,
                },
            },
        }),
    });

    exe.root_module.linkLibrary(raylib_artifact);

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);

    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const test_step = b.step(
        "test",
        "Run tests",
    );

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);
    test_step.dependOn(&run_mod_tests.step);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    exe_tests.root_module.linkLibrary(raylib_artifact);
    const run_exe_tests = b.addRunArtifact(exe_tests);
    test_step.dependOn(&run_exe_tests.step);
}

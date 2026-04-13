// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const std = @import("std");
const rl = @import("raylib");
const video = @import("video.zig");
const input = @import("input.zig");
const audio = @import("audio.zig");

const core = @import("MokaByte");

const demos = [_][:0]const u8{
    "demos/hello.lua",
};

pub fn main() !void {
    var machine: core.machine.Memory = undefined;
    @memset(machine.raw[0..], 0);
    machine.map.palette = core.machine.palette;

    var vm = try core.vm.VM.init(&machine);
    defer vm.deinit();

    try vm.loadCartridge("demos/pixel_move.lua");

    var display = try video.Renderer.init("MokaByte");
    defer display.deinit();

    var speaker = try audio.Driver.init();
    defer speaker.deinit();

    vm.ready();

    while (!rl.windowShouldClose()) {
        input.update(&machine);
        vm.go();
        speaker.update(&machine);
        display.drawFrame(&machine);
    }
}

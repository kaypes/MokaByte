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

const core = @import("MOKA_128");

pub fn main() !void {
    var machine: core.machine.Memory = undefined;
    @memset(machine.raw[0..], 0);
    machine.map.palette = core.machine.palette;

    var vm = try core.vm.VM.init(&machine);
    defer vm.deinit();

    var display = try video.Renderer.init("MOKA-128");
    defer display.deinit();

    while (!rl.windowShouldClose()) {
        vm.tick();
        display.drawFrame(&machine);
    }
}

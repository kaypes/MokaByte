// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const rl = @import("raylib");
const video = @import("video.zig");
const core = @import("MOKA_128");

pub fn main() !void {
    var machine: core.machine.Memory = undefined;
    @memset(machine.raw[0..], 0);

    machine.map.palette = core.machine.palette;

    machine.map.vram[0] = 0x12;
    machine.map.vram[1] = 0x34;

    var display = try video.Renderer.init("Moka Console");
    defer display.deinit();

    while (!rl.windowShouldClose()) {
        display.drawFrame(&machine);
    }
}

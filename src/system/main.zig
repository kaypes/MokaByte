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

    core.draw.cls(&machine, 0);

    var x: i32 = 0;
    while (x < 256) : (x += 1) {
        core.draw.pix(&machine, x, 96, 1);
    }

    core.draw.pix(&machine, 127, 90, 2);
    core.draw.pix(&machine, 128, 91, 3);
    core.draw.pix(&machine, 129, 92, 4);

    var display = try video.Renderer.init("Moka Fantasy Console");
    defer display.deinit();

    while (!rl.windowShouldClose()) {
        display.drawFrame(&machine);
    }
}

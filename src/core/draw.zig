// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const machine = @import("machine.zig");

pub fn cls(mem: *machine.Memory, color_index: u4) void {
    const byte_color = (@as(u8, color_index) << 4) | @as(u8, color_index);
    @memset(mem.map.vram[0..], byte_color);
}

pub fn pix(mem: *machine.Memory, x: i32, y: i32, color_index: u4) void {
    if (x < 0 or x >= machine.width or y < 0 or y >= machine.height) {
        return;
    }

    const pixel_index = y * machine.width + x;
    const byte_index = @as(usize, @intCast(@divTrunc(pixel_index, 2)));

    const is_left_pixel: bool = @rem(x, 2) == 0;

    if (is_left_pixel) {
        mem.map.vram[byte_index] = (mem.map.vram[byte_index] & 0x0F) | (@as(u8, color_index) << 4);
    } else {
        mem.map.vram[byte_index] = (mem.map.vram[byte_index] & 0xF0) | @as(u8, color_index);
    }
}

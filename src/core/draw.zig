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

fn hline(mem: *machine.Memory, x1: i32, x2: i32, y: i32, color: u8) void {
    if (y < 0 or y >= machine.height) {
        return;
    }

    const start_x = @max(0, @min(x1, x2));
    const end_x = @min(@as(i32, machine.width - 1), @max(x1, x2));

    var cx = start_x;
    while (cx <= end_x) : (cx += 1) {
        pix(mem, cx, y, color);
    }
}

pub fn circ(mem: *machine.Memory, xc: i32, yc: i32, r: i32, color: u4) void {
    var x: i32 = 0;
    var y: i32 = 0;
    var d: i32 = 1 - r;

    while (y >= x) {
        pix(mem, xc + x, yc + y, color);
        pix(mem, xc - x, yc - y, color);
        pix(mem, xc + x, yc - y, color);
        pix(mem, xc - x, yc + y, color);
        pix(mem, xc + x, yc + y, color);
        pix(mem, xc + y, yc + x, color);
        pix(mem, xc - y, yc - x, color);
        pix(mem, xc + y, yc - x, color);
        pix(mem, xc - y, yc + x, color);

        x += 1;
        if (d > 0) {
            y -= 1;
            d += 2 * x + 1;
        } else {
            d += 2 * (x - y) + 1;
        }
    }
}

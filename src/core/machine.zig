// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

pub const width = 256;
pub const height = 192;
pub const vram_size = 24 * 1024;
pub const ram_size = vram_size + 104 * 1024;

pub const Rgb = extern struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const palette = [_]Rgb{
    .{ .r = 33, .g = 43, .b = 94 },
    .{ .r = 99, .g = 111, .b = 178 },
    .{ .r = 173, .g = 196, .b = 255 },
    .{ .r = 255, .g = 255, .b = 255 },
    .{ .r = 255, .g = 204, .b = 215 },
    .{ .r = 255, .g = 127, .b = 189 },
    .{ .r = 135, .g = 36, .b = 80 },
    .{ .r = 255, .g = 45, .b = 64 },
    .{ .r = 239, .g = 96, .b = 74 },
    .{ .r = 255, .g = 216, .b = 119 },
    .{ .r = 0, .g = 204, .b = 139 },
    .{ .r = 0, .g = 90, .b = 117 },
    .{ .r = 81, .g = 58, .b = 232 },
    .{ .r = 25, .g = 186, .b = 255 },
    .{ .r = 119, .g = 49, .b = 165 },
    .{ .r = 185, .g = 124, .b = 255 },
};

pub const Button = struct {
    pub const up = 0;
    pub const down = 1;
    pub const left = 2;
    pub const right = 3;
    pub const a = 4;
    pub const b = 5;
    pub const select = 6;
    pub const start = 7;
};

pub const Memory = extern union {
    raw: [ram_size]u8,

    map: extern struct {
        vram: [vram_size]u8,
        palette: [16]Rgb,

        gamepad: u8,
        previous_gamepad: u8,

        sound_freq: u16,
        sound_vol: u8,
        sound_wave: u8,

        padding: [ram_size - vram_size - 48 - 6]u8,
    },
};

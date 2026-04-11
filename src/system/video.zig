// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const rl = @import("raylib");
const core = @import("MOKA_128");

pub const Renderer = struct {
    const width = 256;
    const height = 192;

    const border_color = rl.Color{ 33, 43, 94, 255 };

    scale: f32,
    screen_width: i32,
    screen_height: i32,

    image: rl.Image,
    texture: rl.Texture2D,

    const Self = @This();

    pub fn init(title: [:0]const u8) !Self {
        rl.initWindow(width, height, title);

        const monitor = rl.getCurrentMonitor();
        const sw = rl.getMonitorWidth(monitor);
        const sh = rl.getMonitorHeight(monitor);

        rl.setWindowSize(sw, sh);
        rl.toggleFullscreen();
        rl.setTargetFPS(60);

        const img = rl.genImageColor(width, height, border_color);
        const tex = rl.loadTextureFromImage(img);

        rl.setTextureFilter(tex, .point);

        const scale_w = @as(f32, @floatFromInt(sw)) / @as(f32, @floatFromInt(width));
        const scale_h = @as(f32, @floatFromInt(sh)) / @as(f32, @floatFromInt(height));

        return Self{
            .screen_width = sw,
            .screen_height = sh,
            .scale = @min(scale_w, scale_h),
            .image = img,
            .texture = tex,
        };
    }

    pub fn deinit(self: *Self) void {
        rl.unloadImage(self.image);
        rl.unloadTexture(self.texture);
        rl.closeWindow();
    }
};

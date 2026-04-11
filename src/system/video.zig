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

    const black_color = rl.Color{
        .r = 4,
        .g = 13,
        .b = 20,
        .a = 255,
    };

    const white_color = rl.Color{
        .r = 255,
        .g = 255,
        .b = 255,
        .a = 255,
    };

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

        const img = rl.genImageColor(width, height, black_color);
        const tex = try rl.loadTextureFromImage(img);

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

    pub fn drawFrame(self: *Self, machine: *core.machine.Memory) void {
        for (machine.map.vram, 0..) |byte, i| {
            const pixel_a_idx = (byte >> 4) & 0x0F;
            const pixel_b_idx = byte & 0x0F;

            const rgb_a = machine.map.palette[pixel_a_idx];
            const rgb_b = machine.map.palette[pixel_b_idx];

            const color_a = rl.Color{
                .r = rgb_a.r,
                .g = rgb_a.g,
                .b = rgb_a.b,
                .a = 255,
            };

            const color_b = rl.Color{
                .r = rgb_b.r,
                .g = rgb_b.g,
                .b = rgb_b.b,
                .a = 255,
            };

            const x1 = @as(i32, @intCast((i * 2) % width));
            const y1 = @as(i32, @intCast((i * 2) / width));
            const x2 = @as(i32, @intCast((i * 2 + 1) % width));
            const y2 = @as(i32, @intCast((i * 2 + 1) / width));

            rl.imageDrawPixel(&self.image, x1, y1, color_a);
            rl.imageDrawPixel(&self.image, x2, y2, color_b);
        }

        rl.updateTexture(self.texture, self.image.data);
        rl.beginDrawing();
        rl.clearBackground(black_color);

        const sw_f32 = @as(f32, @floatFromInt(self.screen_width));
        const sh_f32 = @as(f32, @floatFromInt(self.screen_height));
        const int_w_f32 = @as(f32, @floatFromInt(width));
        const int_h_f32 = @as(f32, @floatFromInt(height));

        const dest = rl.Rectangle{
            .x = (sw_f32 - (int_w_f32 * self.scale)) * 0.5,
            .y = (sh_f32 - (int_h_f32 * self.scale)) * 0.5,
            .width = int_w_f32 * self.scale,
            .height = int_h_f32 * self.scale,
        };

        const source = rl.Rectangle{
            .x = 0.0,
            .y = 0.0,
            .width = @as(f32, @floatFromInt(self.texture.width)),
            .height = @as(f32, @floatFromInt(self.texture.height)),
        };

        rl.drawTexturePro(
            self.texture,
            source,
            dest,
            rl.Vector2{
                .x = 0,
                .y = 0,
            },
            0.0,
            white_color,
        );

        rl.endDrawing();
    }

    pub fn deinit(self: *Self) void {
        rl.unloadImage(self.image);
        rl.unloadTexture(self.texture);
        rl.closeWindow();
    }
};

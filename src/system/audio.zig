// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const std = @import("std");
const rl = @import("raylib");
const core = @import("MokaByte");

pub const WaveType = enum(u8) {
    sine = 0,
    square = 1,
    sawtooth = 2,
    noise = 3,
    _,
};

pub const Driver = struct {
    stream: rl.AudioStream,
    phases: [6]f32 = .{ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 },
    noise_seed: u32 = 12345,

    const target_fps = 60;
    const channels = 1;
    const sample_rate = 44100;
    const sample_size_bits = 16;
    const samples_per_frame = sample_rate / target_fps;

    const max_amplitude: f32 = 32000.0;
    const max_lua_volume: f32 = 255.0;

    const Self = @This();

    pub fn init() !Self {
        rl.setAudioStreamBufferSizeDefault(samples_per_frame);
        rl.initAudioDevice();
        const stream = try rl.loadAudioStream(
            sample_rate,
            sample_size_bits,
            channels,
        );
        rl.playAudioStream(stream);

        return Self{
            .stream = stream,
        };
    }

    pub fn update(self: *Self, machine: *core.machine.Memory) void {
        if (!rl.isAudioStreamProcessed(self.stream)) {
            return;
        }

        var buffer: [samples_per_frame]i16 = undefined;
        
        for (&buffer) |*sample| {
            var mix_val: f32 = 0.0;

            for (&machine.map.sound_channels, 0..) |*ch, i| {
                if (ch.vol == 0 or ch.freq == 0) {
                    continue;
                }

                const wave: WaveType = @enumFromInt(ch.wave);
                const phase_increment = @as(f32, @floatFromInt(ch.freq)) / @as(f32, @floatFromInt(sample_rate));
                const volume_f32 = @as(f32, @floatFromInt(ch.vol)) / max_lua_volume;

                self.phases[i] += phase_increment;
                if (self.phases[i] >= 1.0) {
                    self.phases[i] -= 1.0;
                }

                var val: f32 = 0.0;
                switch (wave) {
                    .sine => val = std.math.sin(self.phases[i] * 2.0 * std.math.pi),
                    .square => val = if (self.phases[i] < 0.5) 1.0 else -1.0,
                    .sawtooth => val = (self.phases[i] * 2.0) - 1.0,
                    .noise => {
                        self.noise_seed = self.noise_seed *% 1664525 +% 1013904223;
                        val = (@as(f32, @floatFromInt(self.noise_seed % 200)) - 100.0) / 100.0;
                    },
                    _ => val = 0.0,
                }

                mix_val += val * volume_f32;
            }

            mix_val /= 6.0;
            sample.* = @as(i16, @intFromFloat(mix_val * max_amplitude));
        }

        rl.updateAudioStream(self.stream, &buffer, samples_per_frame);

        for (&machine.map.sound_channels) |*ch| {
            if (ch.duration > 0) {
                ch.duration -= 1;

                if (ch.duration == 0) {
                    ch.vol = 0;
                }
            }
        }
    }

    pub fn deinit(self: *Self) void {
        rl.stopAudioStream(self.stream);
        rl.unloadAudioStream(self.stream);
        rl.closeAudioDevice();
    }
};

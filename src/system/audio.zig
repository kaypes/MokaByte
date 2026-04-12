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
    phase: f32 = 0.0,
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

        const freq: u16 = machine.map.sound_freq;
        const vol: u8 = machine.map.sound_vol;
        const wave: WaveType = @enumFromInt(machine.map.sound_wave);

        if (vol == 0 or freq == 0) {
            @memset(&buffer, 0);

            rl.updateAudioStream(
                self.stream,
                &buffer,
                samples_per_frame,
            );

            return;
        }

        const phase_increment = @as(f32, @floatFromInt(freq)) / @as(f32, @floatFromInt(sample_rate));
        const volume_f32 = @as(f32, @floatFromInt(vol)) / max_lua_volume;

        for (&buffer) |*sample| {
            self.phase += phase_increment;

            if (self.phase >= 1.0) {
                self.phase -= 1.0;
            }

            var val: f32 = 0.0;
            switch (wave) {
                .sine => val = std.math.sin(self.phase * 2.0 * std.math.pi),
                .square => val = if (self.phase < 0.5) 1.0 else -1.0,
                .sawtooth => val = (self.phase * 2.0) - 1.0,
                .noise => {
                    self.noise_seed = self.noise_seed *% 1664525 +% 1013904223;
                    val = (@as(f32, @floatFromInt(self.noise_seed % 200)) - 100.0) / 100.0;
                },
                _ => val = 0.0,
            }

            sample.* = @as(i16, @intFromFloat(val * volume_f32 * max_amplitude));
        }

        rl.updateAudioStream(self.stream, &buffer, samples_per_frame);
    }

    pub fn deinit(self: *Self) void {
        rl.stopAudioStream(self.stream);
        rl.unloadAudioStream(self.stream);
        rl.closeAudioDevice();
    }
};

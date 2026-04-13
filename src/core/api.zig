// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const ziglua = @import("ziglua");
const machine = @import("machine.zig");
const draw = @import("draw.zig");

const mem_index = ziglua.Lua.upvalueIndex(1);

fn safeColor(c: i64) u8 {
    return @as(u8, @intCast(@mod(c, 16)));
}

pub fn cls(lua: *ziglua.Lua) i32 {
    const mem_ptr = lua.toUserdata(machine.Memory, mem_index) catch return 0;

    const color = lua.toInteger(1) catch 0;

    draw.cls(mem_ptr, safeColor(color));

    return 0;
}

pub fn pix(lua: *ziglua.Lua) i32 {
    const mem_ptr = lua.toUserdata(machine.Memory, mem_index) catch return 0;

    const x = lua.toInteger(1) catch 0;
    const y = lua.toInteger(2) catch 0;

    const color = lua.toInteger(3) catch 0;

    draw.pix(mem_ptr, @intCast(x), @intCast(y), safeColor(color));

    return 0;
}

pub fn btn(lua: *ziglua.Lua) i32 {
    const mem_ptr = lua.toUserdata(machine.Memory, mem_index) catch return 0;
    const button_id = lua.toInteger(1) catch 0;

    if (button_id < 0 or button_id > 7) {
        lua.pushBoolean(false);
        return 1;
    }

    const mask = @as(u8, 1) << @intCast(button_id);
    const is_pressed = (mem_ptr.map.gamepad & mask) != 0;

    lua.pushBoolean(is_pressed);

    return 1;
}

pub fn btnp(lua: *ziglua.Lua) i32 {
    const mem_ptr = lua.toUserdata(machine.Memory, mem_index) catch return 0;
    const button_id = lua.toInteger(1) catch 0;

    if (button_id < 0 or button_id > 7) {
        lua.pushBoolean(false);
        return 1;
    }

    const mask = @as(u8, 1) << @intCast(button_id);
    const is_pressed_now = (mem_ptr.map.gamepad & mask) != 0;
    const was_pressed_before = (mem_ptr.map.previous_gamepad & mask) != 0;

    lua.pushBoolean(is_pressed_now and !was_pressed_before);

    return 1;
}

pub fn sfx(lua: *ziglua.Lua) i32 {
    const mem_ptr = lua.toUserdata(machine.Memory, mem_index) catch return 0;

    const freq = lua.toInteger(1) catch 0;
    const vol = lua.toInteger(2) catch 255;
    const wave = lua.toInteger(3) catch 1;
    const duration = lua.toInteger(4) catch 0;

    const channel = lua.toInteger(5) catch -1;
    var ch_idx: usize = 0;

    if (channel == -1) {
        for (&mem_ptr.map.sound_channels, 0..) |ch, i| {
            if (ch.duration == 0) {
                ch_idx = i;
                break;
            }
        }
    } else {
        ch_idx = @as(usize, @intCast(@max(0, @min(channel, 5))));
    }

    mem_ptr.map.sound_channels[ch_idx].freq = @intCast(@max(0, @min(freq, 65535)));
    mem_ptr.map.sound_channels[ch_idx].vol = @intCast(@max(0, @min(vol, 255)));
    mem_ptr.map.sound_channels[ch_idx].wave = @intCast(@mod(wave, 4));
    mem_ptr.map.sound_channels[ch_idx].duration = @intCast(@max(0, @min(duration, 65535)));

    return 0;
}

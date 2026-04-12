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

pub fn cls(lua: *ziglua.Lua) i32 {
    const mem_ptr = lua.toUserdata(machine.Memory, mem_index) catch return 0;

    const color = lua.toInteger(1) catch 0;

    draw.cls(mem_ptr, @intCast(color));

    return 0;
}

pub fn pix(lua: *ziglua.Lua) i32 {
    const mem_ptr = lua.toUserdata(machine.Memory, mem_index) catch return 0;

    const x = lua.toInteger(1) catch 0;
    const y = lua.toInteger(2) catch 0;

    const color = lua.toInteger(3) catch 0;

    draw.pix(mem_ptr, @intCast(x), @intCast(y), @intCast(color));

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

    var channel = lua.toInteger(5) catch 0;

    if (channel < 0) {
        channel = 0;
    }

    if (channel > 5) {
        channel = 5;
    }

    const ch_idx = @as(usize, @intCast(channel));
    mem_ptr.map.sound_channels[ch_idx].freq = @intCast(freq);
    mem_ptr.map.sound_channels[ch_idx].vol = @intCast(vol);
    mem_ptr.map.sound_channels[ch_idx].wave = @intCast(wave);
    mem_ptr.map.sound_channels[ch_idx].duration = @intCast(duration);

    return 0;
}

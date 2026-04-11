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

// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const std = @import("std");
const ziglua = @import("ziglua");
const machine = @import("machine.zig");
const api = @import("api.zig");

pub const VM = struct {
    lua: *ziglua.Lua,
    machine_ptr: *machine.Memory,

    const Self = @This();

    pub fn init(mem: *machine.Memory) !Self {
        const lua = try ziglua.Lua.init(std.heap.page_allocator);

        lua.openLibs();

        lua.pushLightUserdata(mem);
        lua.pushClosure(ziglua.wrap(api.cls), 1);
        lua.setGlobal("cls");

        lua.pushLightUserdata(mem);
        lua.pushClosure(ziglua.wrap(api.pix), 1);
        lua.setGlobal("pix");

        lua.pushLightUserdata(mem);
        lua.pushClosure(ziglua.wrap(api.btn), 1);
        lua.setGlobal("btn");

        const script_cartucho =
            \\ x = 128
            \\ y = 96
            \\
            \\ function TIC()
            \\    cls(0)
            \\    
            \\    if btn(0) then y = y - 1 end
            \\    if btn(1) then y = y + 1 end
            \\    if btn(2) then x = x - 1 end
            \\    if btn(3) then x = x + 1 end
            \\
            \\    if x > 256 then x = 0 end
            \\    if x < 0 then x = 256 end
            \\
            \\    if y > 192 then y = 0 end
            \\    if y < 0 then y = 192 end
            \\
            \\    pix(x, y, 4) 
            \\ end
        ;

        try lua.doString(script_cartucho);

        return Self{
            .lua = lua,
            .machine_ptr = mem,
        };
    }

    pub fn tick(self: *Self) void {
        _ = self.lua.getGlobal("TIC") catch return;

        self.lua.protectedCall(.{ .args = 0, .results = 0 }) catch |err| {
            std.debug.print("Lua error: {}\n", .{err});
        };
    }

    pub fn deinit(self: *Self) void {
        self.lua.deinit();
    }
};

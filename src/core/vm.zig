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

        lua.openBase();
        lua.openMath();
        lua.openString();
        lua.openTable();

        lua.pushLightUserdata(mem);
        lua.pushClosure(ziglua.wrap(api.cls), 1);
        lua.setGlobal("cls");

        lua.pushLightUserdata(mem);
        lua.pushClosure(ziglua.wrap(api.pix), 1);
        lua.setGlobal("pix");

        lua.pushLightUserdata(mem);
        lua.pushClosure(ziglua.wrap(api.btn), 1);
        lua.setGlobal("btn");

        lua.pushLightUserdata(mem);
        lua.pushClosure(ziglua.wrap(api.btnp), 1);
        lua.setGlobal("btnp");

        lua.pushLightUserdata(mem);
        lua.pushClosure(ziglua.wrap(api.sfx), 1);
        lua.setGlobal("sfx");

        return Self{
            .lua = lua,
            .machine_ptr = mem,
        };
    }

    pub fn loadCartridge(self: *Self, filepath: [:0]const u8) !void {
        self.lua.doFile(filepath) catch |err| {
            std.debug.print("\nCould not load cartridge: {s}\n", .{filepath});
            std.debug.print("Error: {}\n\n", .{err});
            return err;
        };
    }

    pub fn ready(self: *Self) void {
        _ = self.lua.getGlobal("READY") catch return;

        self.lua.protectedCall(.{ .args = 0, .results = 0 }) catch |err| {
            std.debug.print("Lua error: {}\n", .{err});
        };
    }

    pub fn go(self: *Self) void {
        _ = self.lua.getGlobal("GO") catch return;

        self.lua.protectedCall(.{ .args = 0, .results = 0 }) catch |err| {
            std.debug.print("Lua error: {}\n", .{err});
        };
    }

    pub fn deinit(self: *Self) void {
        self.lua.deinit();
    }
};

// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const rl = @import("raylib");
const core = @import("MokaByte");

fn isPressed(keys: []const rl.KeyboardKey, btn: rl.GamepadButton) bool {
    for (keys) |k| {
        if (rl.isKeyDown(k)) {
            return true;
        }
    }

    if (rl.isGamepadButtonDown(0, btn)) {
        return true;
    }

    return false;
}

pub fn update(machine: *core.machine.Memory) void {
    var state: u8 = 0;

    const btn = core.machine.Button;

    if (isPressed(&.{ .up, .w }, .left_face_up)) {
        state |= (1 << btn.up);
    }
    if (isPressed(&.{ .down, .s }, .left_face_down)) {
        state |= (1 << btn.down);
    }
    if (isPressed(&.{ .left, .a }, .left_face_left)) {
        state |= (1 << btn.left);
    }
    if (isPressed(&.{ .right, .d }, .left_face_right)) {
        state |= (1 << btn.right);
    }

    if (isPressed(&.{ .z, .k }, .right_face_down)) {
        state |= (1 << btn.a);
    }
    if (isPressed(&.{ .x, .l }, .right_face_right)) {
        state |= (1 << btn.b);
    }

    if (isPressed(&.{ .right_shift, .v }, .middle_left)) {
        state |= (1 << btn.select);
    }
    if (isPressed(&.{ .enter, .b }, .middle_right)) {
        state |= (1 << btn.start);
    }

    machine.map.gamepad = state;
}

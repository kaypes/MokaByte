// Copyright 2026 Kayque Pereira
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0

const std = @import("std");

const width = 256;
const height = 192;
pub const vram_size = 24 * 1024;
pub const ram_size = vram_size + 104 * 1024;

pub const Memory = extern union {
    raw: [ram_size]u8,

    map: extern struct {
        vram: [vram_size]u8,

        remaining: [104 * 1024]u8,
    },
};

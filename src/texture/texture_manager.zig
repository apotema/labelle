//! Texture Manager - handles loading and caching of textures and atlases

const std = @import("std");
const rl = @import("raylib");
const SpriteAtlas = @import("sprite_atlas.zig").SpriteAtlas;

/// Manages multiple texture atlases
pub const TextureManager = struct {
    atlases: std.StringHashMap(SpriteAtlas),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) TextureManager {
        return .{
            .atlases = std.StringHashMap(SpriteAtlas).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *TextureManager) void {
        var iter = self.atlases.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.deinit();
            self.allocator.free(entry.key_ptr.*);
        }
        self.atlases.deinit();
    }

    /// Load an atlas from JSON and texture files
    pub fn loadAtlas(
        self: *TextureManager,
        name: []const u8,
        json_path: []const u8,
        texture_path: []const u8,
    ) !void {
        var atlas = SpriteAtlas.init(self.allocator);
        errdefer atlas.deinit();

        try atlas.loadFromFile(json_path, texture_path);

        const name_owned = try self.allocator.dupe(u8, name);
        try self.atlases.put(name_owned, atlas);
    }

    /// Get an atlas by name
    pub fn getAtlas(self: *TextureManager, name: []const u8) ?*SpriteAtlas {
        return self.atlases.getPtr(name);
    }

    /// Get sprite rectangle from any loaded atlas
    /// Searches all atlases for the sprite name
    pub fn findSprite(self: *TextureManager, sprite_name: []const u8) ?struct {
        atlas: *SpriteAtlas,
        rect: rl.Rectangle,
    } {
        var iter = self.atlases.iterator();
        while (iter.next()) |entry| {
            if (entry.value_ptr.getSpriteRect(sprite_name)) |rect| {
                return .{
                    .atlas = entry.value_ptr,
                    .rect = rect,
                };
            }
        }
        return null;
    }

    /// Unload a specific atlas
    pub fn unloadAtlas(self: *TextureManager, name: []const u8) void {
        if (self.atlases.fetchRemove(name)) |entry| {
            var atlas = entry.value;
            atlas.deinit();
            self.allocator.free(entry.key);
        }
    }
};

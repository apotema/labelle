//! Sprite Atlas - TexturePacker JSON format support

const std = @import("std");
const rl = @import("raylib");

/// A single sprite's location in an atlas
pub const SpriteData = struct {
    x: u32,
    y: u32,
    width: u32,
    height: u32,
    /// Original name from the atlas
    name: []const u8,
};

/// Sprite atlas loaded from TexturePacker JSON format
pub const SpriteAtlas = struct {
    texture: rl.Texture2D,
    sprites: std.StringHashMap(SpriteData),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) SpriteAtlas {
        return .{
            .texture = undefined,
            .sprites = std.StringHashMap(SpriteData).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *SpriteAtlas) void {
        rl.unloadTexture(self.texture);

        // Free allocated sprite names
        var iter = self.sprites.iterator();
        while (iter.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
        }
        self.sprites.deinit();
    }

    /// Load atlas from TexturePacker JSON file
    pub fn loadFromFile(self: *SpriteAtlas, json_path: []const u8, texture_path: []const u8) !void {
        // Load texture
        self.texture = rl.loadTexture(@ptrCast(texture_path));
        if (self.texture.id == 0) {
            return error.TextureLoadFailed;
        }

        // Load and parse JSON
        const json_path_z: [*:0]const u8 = @ptrCast(json_path);
        const file_data = rl.loadFileText(json_path_z);
        if (file_data == null) {
            return error.JsonLoadFailed;
        }
        defer rl.unloadFileText(file_data);

        const json_slice = std.mem.span(file_data);
        try self.parseJson(json_slice);
    }

    /// Parse TexturePacker JSON format
    fn parseJson(self: *SpriteAtlas, json_data: []const u8) !void {
        const parsed = try std.json.parseFromSlice(std.json.Value, self.allocator, json_data, .{});
        defer parsed.deinit();

        const root = parsed.value;
        const frames = root.object.get("frames") orelse return error.InvalidJsonFormat;

        switch (frames) {
            .array => |arr| {
                // Array format: [{"filename": "...", "frame": {...}}, ...]
                for (arr.items) |item| {
                    try self.parseFrameObject(item);
                }
            },
            .object => |obj| {
                // Object format: {"sprite_name": {"frame": {...}}, ...}
                var iter = obj.iterator();
                while (iter.next()) |entry| {
                    const name = try self.allocator.dupe(u8, entry.key_ptr.*);
                    const frame_data = entry.value_ptr.*.object.get("frame") orelse continue;

                    const sprite = SpriteData{
                        .x = @intCast(frame_data.object.get("x").?.integer),
                        .y = @intCast(frame_data.object.get("y").?.integer),
                        .width = @intCast(frame_data.object.get("w").?.integer),
                        .height = @intCast(frame_data.object.get("h").?.integer),
                        .name = name,
                    };
                    try self.sprites.put(name, sprite);
                }
            },
            else => return error.InvalidJsonFormat,
        }
    }

    fn parseFrameObject(self: *SpriteAtlas, item: std.json.Value) !void {
        const obj = item.object;
        const filename = obj.get("filename") orelse return;
        const frame = obj.get("frame") orelse return;

        const name = try self.allocator.dupe(u8, filename.string);
        const sprite = SpriteData{
            .x = @intCast(frame.object.get("x").?.integer),
            .y = @intCast(frame.object.get("y").?.integer),
            .width = @intCast(frame.object.get("w").?.integer),
            .height = @intCast(frame.object.get("h").?.integer),
            .name = name,
        };
        try self.sprites.put(name, sprite);
    }

    /// Get sprite data by name
    pub fn getSprite(self: *SpriteAtlas, name: []const u8) ?SpriteData {
        return self.sprites.get(name);
    }

    /// Get source rectangle for a sprite (for raylib drawing)
    pub fn getSpriteRect(self: *SpriteAtlas, name: []const u8) ?rl.Rectangle {
        const sprite = self.getSprite(name) orelse return null;
        return rl.Rectangle{
            .x = @floatFromInt(sprite.x),
            .y = @floatFromInt(sprite.y),
            .width = @floatFromInt(sprite.width),
            .height = @floatFromInt(sprite.height),
        };
    }
};

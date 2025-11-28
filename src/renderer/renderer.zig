//! Main renderer for sprite and animation rendering

const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs");

const components = @import("../components/components.zig");
const Render = components.Render;
const Animation = components.Animation;
const SpriteLocation = components.SpriteLocation;

const TextureManager = @import("../texture/texture_manager.zig").TextureManager;
const SpriteAtlas = @import("../texture/sprite_atlas.zig").SpriteAtlas;
const Camera = @import("../camera/camera.zig").Camera;

/// Predefined Z-index layers
pub const ZIndex = struct {
    pub const background: u8 = 0;
    pub const floor: u8 = 10;
    pub const shadows: u8 = 20;
    pub const items: u8 = 30;
    pub const characters: u8 = 40;
    pub const effects: u8 = 50;
    pub const ui_background: u8 = 60;
    pub const ui: u8 = 70;
    pub const ui_foreground: u8 = 80;
    pub const overlay: u8 = 90;
    pub const debug: u8 = 100;
};

/// Main renderer
pub const Renderer = struct {
    texture_manager: TextureManager,
    camera: Camera,
    allocator: std.mem.Allocator,

    /// Temporary buffer for sprite name generation
    sprite_name_buffer: [256]u8 = undefined,

    pub fn init(allocator: std.mem.Allocator) Renderer {
        return .{
            .texture_manager = TextureManager.init(allocator),
            .camera = Camera.init(),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Renderer) void {
        self.texture_manager.deinit();
    }

    /// Load a sprite atlas
    pub fn loadAtlas(
        self: *Renderer,
        name: []const u8,
        json_path: []const u8,
        texture_path: []const u8,
    ) !void {
        try self.texture_manager.loadAtlas(name, json_path, texture_path);
    }

    /// Draw a sprite by name at a position
    pub fn drawSprite(
        self: *Renderer,
        sprite_name: []const u8,
        x: f32,
        y: f32,
        options: DrawOptions,
    ) void {
        const found = self.texture_manager.findSprite(sprite_name) orelse return;

        var src_rect = found.rect;
        if (options.flip_x) {
            src_rect.width = -src_rect.width;
        }
        if (options.flip_y) {
            src_rect.height = -src_rect.height;
        }

        const dest_rect = rl.Rectangle{
            .x = x + options.offset_x,
            .y = y + options.offset_y,
            .width = found.rect.width * options.scale,
            .height = found.rect.height * options.scale,
        };

        const origin = rl.Vector2{
            .x = dest_rect.width / 2,
            .y = dest_rect.height / 2,
        };

        rl.drawTexturePro(
            found.atlas.texture,
            src_rect,
            dest_rect,
            origin,
            options.rotation,
            options.tint,
        );
    }

    /// Draw options for sprites
    pub const DrawOptions = struct {
        offset_x: f32 = 0,
        offset_y: f32 = 0,
        scale: f32 = 1.0,
        rotation: f32 = 0,
        tint: rl.Color = rl.Color.white,
        flip_x: bool = false,
        flip_y: bool = false,
    };

    /// Begin camera mode for world rendering
    pub fn beginCameraMode(self: *Renderer) void {
        rl.beginMode2D(self.camera.toRaylib());
    }

    /// End camera mode
    pub fn endCameraMode(_: *Renderer) void {
        rl.endMode2D();
    }

    /// Get the texture manager for advanced operations
    pub fn getTextureManager(self: *Renderer) *TextureManager {
        return &self.texture_manager;
    }

    /// Get the camera for manipulation
    pub fn getCamera(self: *Renderer) *Camera {
        return &self.camera;
    }
};

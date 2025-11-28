//! Camera abstraction for 2D games

const rl = @import("raylib");

/// 2D Camera with pan, zoom, and bounds
pub const Camera = struct {
    /// Camera position (center of view)
    x: f32 = 0,
    y: f32 = 0,
    /// Zoom level (1.0 = normal)
    zoom: f32 = 1.0,
    /// Rotation in degrees
    rotation: f32 = 0,
    /// Minimum zoom level
    min_zoom: f32 = 0.1,
    /// Maximum zoom level
    max_zoom: f32 = 3.0,
    /// World bounds (optional - set all to 0 to disable)
    bounds: Bounds = .{},

    pub const Bounds = struct {
        min_x: f32 = 0,
        min_y: f32 = 0,
        max_x: f32 = 0,
        max_y: f32 = 0,

        pub fn isEnabled(self: Bounds) bool {
            return self.max_x > self.min_x or self.max_y > self.min_y;
        }
    };

    pub fn init() Camera {
        return .{};
    }

    /// Convert to raylib Camera2D
    pub fn toRaylib(self: *const Camera) rl.Camera2D {
        return .{
            .offset = .{
                .x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2.0,
                .y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2.0,
            },
            .target = .{ .x = self.x, .y = self.y },
            .rotation = self.rotation,
            .zoom = self.zoom,
        };
    }

    /// Move camera by delta
    pub fn pan(self: *Camera, dx: f32, dy: f32) void {
        self.x += dx / self.zoom;
        self.y += dy / self.zoom;
        self.clampToBounds();
    }

    /// Set camera position
    pub fn setPosition(self: *Camera, x: f32, y: f32) void {
        self.x = x;
        self.y = y;
        self.clampToBounds();
    }

    /// Zoom by delta (positive = zoom in, negative = zoom out)
    pub fn zoomBy(self: *Camera, delta: f32) void {
        self.zoom += delta;
        self.zoom = @max(self.min_zoom, @min(self.max_zoom, self.zoom));
    }

    /// Set zoom level
    pub fn setZoom(self: *Camera, zoom_level: f32) void {
        self.zoom = @max(self.min_zoom, @min(self.max_zoom, zoom_level));
    }

    /// Set world bounds for camera
    pub fn setBounds(self: *Camera, min_x: f32, min_y: f32, max_x: f32, max_y: f32) void {
        self.bounds = .{
            .min_x = min_x,
            .min_y = min_y,
            .max_x = max_x,
            .max_y = max_y,
        };
        self.clampToBounds();
    }

    /// Clear bounds restriction
    pub fn clearBounds(self: *Camera) void {
        self.bounds = .{};
    }

    fn clampToBounds(self: *Camera) void {
        if (!self.bounds.isEnabled()) return;

        // Calculate visible area based on zoom
        const screen_width: f32 = @floatFromInt(rl.getScreenWidth());
        const screen_height: f32 = @floatFromInt(rl.getScreenHeight());
        const half_width = (screen_width / 2.0) / self.zoom;
        const half_height = (screen_height / 2.0) / self.zoom;

        // Clamp position
        self.x = @max(self.bounds.min_x + half_width, @min(self.bounds.max_x - half_width, self.x));
        self.y = @max(self.bounds.min_y + half_height, @min(self.bounds.max_y - half_height, self.y));
    }

    /// Convert screen coordinates to world coordinates
    pub fn screenToWorld(self: *const Camera, screen_x: f32, screen_y: f32) struct { x: f32, y: f32 } {
        const rl_camera = self.toRaylib();
        const world_pos = rl.getScreenToWorld2D(.{ .x = screen_x, .y = screen_y }, rl_camera);
        return .{ .x = world_pos.x, .y = world_pos.y };
    }

    /// Convert world coordinates to screen coordinates
    pub fn worldToScreen(self: *const Camera, world_x: f32, world_y: f32) struct { x: f32, y: f32 } {
        const rl_camera = self.toRaylib();
        const screen_pos = rl.getWorldToScreen2D(.{ .x = world_x, .y = world_y }, rl_camera);
        return .{ .x = screen_pos.x, .y = screen_pos.y };
    }
};

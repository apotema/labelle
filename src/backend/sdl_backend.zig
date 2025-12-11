//! SDL2 Backend Implementation (SKETCH - Not yet functional)
//!
//! Implements the backend interface using SDL.zig bindings.
//! Requires: SDL2, SDL2_image (for PNG/JPG loading), SDL2_gfx (for shapes)
//!
//! Dependencies to add to build.zig:
//!   const sdl_dep = b.dependency("sdl", .{...});
//!   const sdl_image_dep = b.dependency("sdl_image", .{...});  // Optional but recommended
//!
//! Reference: https://github.com/ikskuh/SDL.zig

const std = @import("std");
const backend = @import("backend.zig");

// TODO: Import actual SDL bindings when dependency is added
// const sdl = @import("sdl");

/// SDL2 backend implementation
pub const SdlBackend = struct {
    // =========================================================================
    // STATE (SDL requires explicit state management unlike raylib)
    // =========================================================================

    var window: ?*Window = null;
    var renderer: ?*Renderer = null;
    var screen_width: i32 = 800;
    var screen_height: i32 = 600;
    var last_frame_time: u64 = 0;
    var frame_time: f32 = 1.0 / 60.0;

    // Placeholder types until SDL bindings are added
    const Window = opaque {};
    const Renderer = opaque {};
    const SdlTexture = opaque {};

    // =========================================================================
    // REQUIRED TYPES
    // =========================================================================

    /// SDL texture handle with cached dimensions
    pub const Texture = struct {
        handle: ?*SdlTexture,
        width: i32,
        height: i32,
    };

    /// RGBA color (0-255 per channel)
    pub const Color = struct {
        r: u8,
        g: u8,
        b: u8,
        a: u8 = 255,

        pub fn eql(self: Color, other: Color) bool {
            return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a;
        }
    };

    /// Rectangle with float coordinates
    pub const Rectangle = struct {
        x: f32,
        y: f32,
        width: f32,
        height: f32,
    };

    /// 2D vector
    pub const Vector2 = struct {
        x: f32,
        y: f32,
    };

    /// 2D camera (manually implemented - SDL has no built-in camera)
    pub const Camera2D = struct {
        offset: Vector2, // Camera offset from target (screen center)
        target: Vector2, // Camera target (world position to look at)
        rotation: f32, // Camera rotation in degrees
        zoom: f32, // Camera zoom (scaling)
    };

    // =========================================================================
    // REQUIRED COLOR CONSTANTS
    // =========================================================================

    pub const white = Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
    pub const black = Color{ .r = 0, .g = 0, .b = 0, .a = 255 };
    pub const red = Color{ .r = 255, .g = 0, .b = 0, .a = 255 };
    pub const green = Color{ .r = 0, .g = 255, .b = 0, .a = 255 };
    pub const blue = Color{ .r = 0, .g = 0, .b = 255, .a = 255 };
    pub const transparent = Color{ .r = 0, .g = 0, .b = 0, .a = 0 };

    // Additional colors for convenience
    pub const gray = Color{ .r = 128, .g = 128, .b = 128, .a = 255 };
    pub const dark_gray = Color{ .r = 64, .g = 64, .b = 64, .a = 255 };
    pub const light_gray = Color{ .r = 192, .g = 192, .b = 192, .a = 255 };
    pub const yellow = Color{ .r = 255, .g = 255, .b = 0, .a = 255 };
    pub const orange = Color{ .r = 255, .g = 165, .b = 0, .a = 255 };

    // =========================================================================
    // HELPER FUNCTIONS
    // =========================================================================

    pub fn color(r: u8, g: u8, b: u8, a: u8) Color {
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    pub fn rectangle(x: f32, y: f32, width: f32, height: f32) Rectangle {
        return .{ .x = x, .y = y, .width = width, .height = height };
    }

    pub fn vector2(x: f32, y: f32) Vector2 {
        return .{ .x = x, .y = y };
    }

    // =========================================================================
    // REQUIRED: TEXTURE MANAGEMENT
    // =========================================================================

    /// Load texture from file path
    /// Requires SDL2_image for PNG/JPG support (SDL2 core only loads BMP)
    pub fn loadTexture(path: [:0]const u8) !Texture {
        _ = path;
        // TODO: Implement with SDL2_image
        // const surface = sdl.image.load(path) orelse return error.TextureLoadFailed;
        // defer sdl.freeSurface(surface);
        // const tex = sdl.createTextureFromSurface(renderer, surface) orelse return error.TextureLoadFailed;
        // var w: c_int = 0;
        // var h: c_int = 0;
        // _ = sdl.queryTexture(tex, null, null, &w, &h);
        // return Texture{ .handle = tex, .width = w, .height = h };

        return error.TextureLoadFailed;
    }

    /// Unload texture and free resources
    pub fn unloadTexture(texture: Texture) void {
        _ = texture;
        // TODO: Implement
        // if (texture.handle) |tex| {
        //     sdl.destroyTexture(tex);
        // }
    }

    // =========================================================================
    // REQUIRED: CORE DRAWING
    // =========================================================================

    /// Draw texture with full transform control
    /// This is the core sprite rendering function
    pub fn drawTexturePro(
        texture: Texture,
        source: Rectangle,
        dest: Rectangle,
        origin: Vector2,
        rotation: f32,
        tint: Color,
    ) void {
        _ = texture;
        _ = source;
        _ = dest;
        _ = origin;
        _ = rotation;
        _ = tint;

        // TODO: Implement with SDL_RenderCopyEx
        // This requires:
        // 1. Convert source Rectangle to SDL_Rect
        // 2. Convert dest Rectangle to SDL_Rect (adjusted for camera)
        // 3. Apply camera transform to destination
        // 4. Set texture color mod for tint: SDL_SetTextureColorMod
        // 5. Set texture alpha mod: SDL_SetTextureAlphaMod
        // 6. Call SDL_RenderCopyEx with rotation and flip flags
        //
        // const src_rect = SDL_Rect{
        //     .x = @intFromFloat(source.x),
        //     .y = @intFromFloat(source.y),
        //     .w = @intFromFloat(source.width),
        //     .h = @intFromFloat(source.height),
        // };
        //
        // // Apply camera transform
        // const transformed = applyCameraTransform(dest);
        //
        // const dst_rect = SDL_Rect{
        //     .x = @intFromFloat(transformed.x),
        //     .y = @intFromFloat(transformed.y),
        //     .w = @intFromFloat(transformed.width),
        //     .h = @intFromFloat(transformed.height),
        // };
        //
        // const center = SDL_Point{
        //     .x = @intFromFloat(origin.x),
        //     .y = @intFromFloat(origin.y),
        // };
        //
        // // Apply tint
        // sdl.setTextureColorMod(texture.handle, tint.r, tint.g, tint.b);
        // sdl.setTextureAlphaMod(texture.handle, tint.a);
        //
        // sdl.renderCopyEx(renderer, texture.handle, &src_rect, &dst_rect, rotation, &center, .none);
    }

    // =========================================================================
    // REQUIRED: CAMERA SYSTEM (Manual implementation)
    // =========================================================================

    var current_camera: ?Camera2D = null;

    /// Begin 2D camera mode
    /// SDL doesn't have built-in camera - we track it and apply transforms manually
    pub fn beginMode2D(camera: Camera2D) void {
        current_camera = camera;
    }

    /// End 2D camera mode
    pub fn endMode2D() void {
        current_camera = null;
    }

    /// Apply camera transform to a rectangle (internal helper)
    fn applyCameraTransform(rect: Rectangle) Rectangle {
        const cam = current_camera orelse return rect;

        // Transform: world coords -> screen coords
        // 1. Translate by -target (center camera on target)
        // 2. Scale by zoom
        // 3. Rotate by rotation (TODO: rotation support)
        // 4. Translate by offset (typically screen center)

        const cos_r = @cos(cam.rotation * std.math.pi / 180.0);
        const sin_r = @sin(cam.rotation * std.math.pi / 180.0);

        // Translate to camera target
        var x = rect.x - cam.target.x;
        var y = rect.y - cam.target.y;

        // Apply rotation around origin
        const rotated_x = x * cos_r - y * sin_r;
        const rotated_y = x * sin_r + y * cos_r;

        // Apply zoom
        x = rotated_x * cam.zoom;
        y = rotated_y * cam.zoom;

        // Translate to screen offset
        x += cam.offset.x;
        y += cam.offset.y;

        return Rectangle{
            .x = x,
            .y = y,
            .width = rect.width * cam.zoom,
            .height = rect.height * cam.zoom,
        };
    }

    /// Convert screen coordinates to world coordinates
    pub fn screenToWorld(pos: Vector2, camera: Camera2D) Vector2 {
        // Inverse of camera transform
        var x = pos.x - camera.offset.x;
        var y = pos.y - camera.offset.y;

        // Inverse zoom
        x /= camera.zoom;
        y /= camera.zoom;

        // Inverse rotation
        const cos_r = @cos(-camera.rotation * std.math.pi / 180.0);
        const sin_r = @sin(-camera.rotation * std.math.pi / 180.0);
        const rotated_x = x * cos_r - y * sin_r;
        const rotated_y = x * sin_r + y * cos_r;

        // Translate back
        return Vector2{
            .x = rotated_x + camera.target.x,
            .y = rotated_y + camera.target.y,
        };
    }

    /// Convert world coordinates to screen coordinates
    pub fn worldToScreen(pos: Vector2, camera: Camera2D) Vector2 {
        var x = pos.x - camera.target.x;
        var y = pos.y - camera.target.y;

        const cos_r = @cos(camera.rotation * std.math.pi / 180.0);
        const sin_r = @sin(camera.rotation * std.math.pi / 180.0);
        const rotated_x = x * cos_r - y * sin_r;
        const rotated_y = x * sin_r + y * cos_r;

        x = rotated_x * camera.zoom;
        y = rotated_y * camera.zoom;

        return Vector2{
            .x = x + camera.offset.x,
            .y = y + camera.offset.y,
        };
    }

    // =========================================================================
    // REQUIRED: SCREEN DIMENSIONS
    // =========================================================================

    pub fn getScreenWidth() i32 {
        return screen_width;
    }

    pub fn getScreenHeight() i32 {
        return screen_height;
    }

    // =========================================================================
    // OPTIONAL: WINDOW MANAGEMENT
    // =========================================================================

    pub fn initWindow(width: i32, height: i32, title: [*:0]const u8) void {
        _ = title;
        screen_width = width;
        screen_height = height;

        // TODO: Implement
        // _ = sdl.init(.{ .video = true, .events = true });
        // window = sdl.createWindow(title, .centered, .centered, width, height, .{});
        // renderer = sdl.createRenderer(window, -1, .{ .accelerated = true, .present_vsync = true });
        // last_frame_time = sdl.getPerformanceCounter();
    }

    pub fn closeWindow() void {
        // TODO: Implement
        // if (renderer) |r| sdl.destroyRenderer(r);
        // if (window) |w| sdl.destroyWindow(w);
        // sdl.quit();
        window = null;
        renderer = null;
    }

    pub fn isWindowReady() bool {
        return window != null and renderer != null;
    }

    pub fn windowShouldClose() bool {
        // TODO: Implement - poll events and check for quit
        // while (sdl.pollEvent()) |event| {
        //     if (event.type == .quit) return true;
        // }
        return false;
    }

    pub fn setTargetFPS(fps: i32) void {
        _ = fps;
        // SDL uses vsync by default if enabled in renderer creation
        // For manual FPS limiting, track frame time and delay
    }

    pub fn setConfigFlags(flags: backend.ConfigFlags) void {
        _ = flags;
        // TODO: Map to SDL window flags
        // vsync_hint -> SDL_RENDERER_PRESENTVSYNC
        // fullscreen_mode -> SDL_WINDOW_FULLSCREEN
        // window_resizable -> SDL_WINDOW_RESIZABLE
        // etc.
    }

    pub fn takeScreenshot(filename: [*:0]const u8) void {
        _ = filename;
        // TODO: Implement using SDL_RenderReadPixels + IMG_SavePNG
    }

    // =========================================================================
    // OPTIONAL: FRAME MANAGEMENT
    // =========================================================================

    pub fn beginDrawing() void {
        // Calculate delta time
        // const now = sdl.getPerformanceCounter();
        // const freq = sdl.getPerformanceFrequency();
        // frame_time = @as(f32, @floatFromInt(now - last_frame_time)) / @as(f32, @floatFromInt(freq));
        // last_frame_time = now;
    }

    pub fn endDrawing() void {
        // TODO: Implement
        // sdl.renderPresent(renderer);
    }

    pub fn clearBackground(col: Color) void {
        _ = col;
        // TODO: Implement
        // sdl.setRenderDrawColor(renderer, col.r, col.g, col.b, col.a);
        // sdl.renderClear(renderer);
    }

    pub fn getFrameTime() f32 {
        return frame_time;
    }

    // =========================================================================
    // OPTIONAL: INPUT HANDLING
    // =========================================================================

    // SDL uses scancode-based input, need to map from backend.KeyboardKey
    fn mapKey(key: backend.KeyboardKey) u32 {
        // Map labelle key codes to SDL scancodes
        // This is a subset - extend as needed
        return switch (key) {
            .space => 44, // SDL_SCANCODE_SPACE
            .escape => 41, // SDL_SCANCODE_ESCAPE
            .enter => 40, // SDL_SCANCODE_RETURN
            .up => 82, // SDL_SCANCODE_UP
            .down => 81, // SDL_SCANCODE_DOWN
            .left => 80, // SDL_SCANCODE_LEFT
            .right => 79, // SDL_SCANCODE_RIGHT
            .a => 4,
            .b => 5,
            .c => 6,
            .d => 7,
            .e => 8,
            .f => 9,
            .g => 10,
            .h => 11,
            .i => 12,
            .j => 13,
            .k => 14,
            .l => 15,
            .m => 16,
            .n => 17,
            .o => 18,
            .p => 19,
            .q => 20,
            .r => 21,
            .s => 22,
            .t => 23,
            .u => 24,
            .v => 25,
            .w => 26,
            .x => 27,
            .y => 28,
            .z => 29,
            else => 0,
        };
    }

    pub fn isKeyDown(key: backend.KeyboardKey) bool {
        _ = mapKey(key);
        // TODO: Implement
        // const state = sdl.getKeyboardState();
        // return state[mapKey(key)] != 0;
        return false;
    }

    pub fn isKeyPressed(key: backend.KeyboardKey) bool {
        _ = key;
        // SDL doesn't have built-in "pressed this frame" - need to track state
        return false;
    }

    pub fn isKeyReleased(key: backend.KeyboardKey) bool {
        _ = key;
        // SDL doesn't have built-in "released this frame" - need to track state
        return false;
    }

    pub fn isMouseButtonDown(button: backend.MouseButton) bool {
        _ = button;
        // TODO: Implement
        // const state = sdl.getMouseState(null, null);
        // return (state & sdl.button(button)) != 0;
        return false;
    }

    pub fn isMouseButtonPressed(button: backend.MouseButton) bool {
        _ = button;
        return false;
    }

    pub fn getMousePosition() Vector2 {
        // TODO: Implement
        // var x: c_int = 0;
        // var y: c_int = 0;
        // _ = sdl.getMouseState(&x, &y);
        // return Vector2{ .x = @floatFromInt(x), .y = @floatFromInt(y) };
        return Vector2{ .x = 0, .y = 0 };
    }

    pub fn getMouseWheelMove() f32 {
        // SDL wheel is event-based, need to track in event loop
        return 0;
    }

    // =========================================================================
    // OPTIONAL: SHAPE DRAWING
    // Note: SDL2 core only has rectangles and lines
    // Circles, triangles, polygons require SDL2_gfx or manual implementation
    // =========================================================================

    pub fn drawText(text: [*:0]const u8, x: i32, y: i32, font_size: i32, col: Color) void {
        _ = text;
        _ = x;
        _ = y;
        _ = font_size;
        _ = col;
        // SDL2 has no built-in text rendering!
        // Options:
        // 1. SDL2_ttf for TrueType fonts
        // 2. Bitmap font atlas (recommended for games)
        // 3. Render text to texture at startup
    }

    pub fn drawRectangle(x: i32, y: i32, width: i32, height: i32, col: Color) void {
        _ = x;
        _ = y;
        _ = width;
        _ = height;
        _ = col;
        // TODO: Implement
        // const rect = SDL_Rect{ .x = x, .y = y, .w = width, .h = height };
        // sdl.setRenderDrawColor(renderer, col.r, col.g, col.b, col.a);
        // sdl.renderFillRect(renderer, &rect);
    }

    pub fn drawRectangleLines(x: i32, y: i32, width: i32, height: i32, col: Color) void {
        _ = x;
        _ = y;
        _ = width;
        _ = height;
        _ = col;
        // TODO: Implement
        // const rect = SDL_Rect{ .x = x, .y = y, .w = width, .h = height };
        // sdl.setRenderDrawColor(renderer, col.r, col.g, col.b, col.a);
        // sdl.renderDrawRect(renderer, &rect);
    }

    pub fn drawRectangleRec(rec: Rectangle, col: Color) void {
        drawRectangle(
            @intFromFloat(rec.x),
            @intFromFloat(rec.y),
            @intFromFloat(rec.width),
            @intFromFloat(rec.height),
            col,
        );
    }

    pub fn drawRectangleV(x: f32, y: f32, width: f32, height: f32, col: Color) void {
        drawRectangle(@intFromFloat(x), @intFromFloat(y), @intFromFloat(width), @intFromFloat(height), col);
    }

    pub fn drawRectangleLinesV(x: f32, y: f32, width: f32, height: f32, col: Color) void {
        drawRectangleLines(@intFromFloat(x), @intFromFloat(y), @intFromFloat(width), @intFromFloat(height), col);
    }

    pub fn drawLine(start_x: f32, start_y: f32, end_x: f32, end_y: f32, col: Color) void {
        _ = start_x;
        _ = start_y;
        _ = end_x;
        _ = end_y;
        _ = col;
        // TODO: Implement
        // sdl.setRenderDrawColor(renderer, col.r, col.g, col.b, col.a);
        // sdl.renderDrawLine(renderer, @intFromFloat(start_x), @intFromFloat(start_y),
        //                    @intFromFloat(end_x), @intFromFloat(end_y));
    }

    pub fn drawLineEx(start_x: f32, start_y: f32, end_x: f32, end_y: f32, thickness: f32, col: Color) void {
        _ = thickness;
        // SDL2 core doesn't support thick lines
        // Would need SDL2_gfx thickLineRGBA or manual quad rendering
        drawLine(start_x, start_y, end_x, end_y, col);
    }

    pub fn drawCircle(center_x: f32, center_y: f32, radius: f32, col: Color) void {
        _ = center_x;
        _ = center_y;
        _ = radius;
        _ = col;
        // SDL2 core has NO circle drawing!
        // Options:
        // 1. SDL2_gfx: filledCircleRGBA()
        // 2. Manual midpoint circle algorithm
        // 3. Pre-rendered circle texture
    }

    pub fn drawCircleLines(center_x: f32, center_y: f32, radius: f32, col: Color) void {
        _ = center_x;
        _ = center_y;
        _ = radius;
        _ = col;
        // SDL2 core has NO circle drawing!
        // Use SDL2_gfx: circleRGBA() or manual implementation
    }

    pub fn drawTriangle(x1: f32, y1: f32, x2: f32, y2: f32, x3: f32, y3: f32, col: Color) void {
        _ = x1;
        _ = y1;
        _ = x2;
        _ = y2;
        _ = x3;
        _ = y3;
        _ = col;
        // SDL2 core has NO triangle drawing!
        // Use SDL2_gfx: filledTrigonRGBA() or SDL_RenderGeometry (SDL 2.0.18+)
    }

    pub fn drawTriangleLines(x1: f32, y1: f32, x2: f32, y2: f32, x3: f32, y3: f32, col: Color) void {
        // Draw 3 lines
        drawLine(x1, y1, x2, y2, col);
        drawLine(x2, y2, x3, y3, col);
        drawLine(x3, y3, x1, y1, col);
    }

    pub fn drawPoly(center_x: f32, center_y: f32, sides: i32, radius: f32, rotation: f32, col: Color) void {
        _ = center_x;
        _ = center_y;
        _ = sides;
        _ = radius;
        _ = rotation;
        _ = col;
        // SDL2 core has NO polygon drawing!
        // Use SDL2_gfx: filledPolygonRGBA() or manual triangle fan
    }

    pub fn drawPolyLines(center_x: f32, center_y: f32, sides: i32, radius: f32, rotation: f32, col: Color) void {
        // Manual implementation using lines
        const sides_f: f32 = @floatFromInt(sides);
        const angle_step = 2.0 * std.math.pi / sides_f;
        const rot_rad = rotation * std.math.pi / 180.0;

        var i: i32 = 0;
        while (i < sides) : (i += 1) {
            const angle1 = @as(f32, @floatFromInt(i)) * angle_step + rot_rad;
            const angle2 = @as(f32, @floatFromInt(i + 1)) * angle_step + rot_rad;

            const x1 = center_x + @cos(angle1) * radius;
            const y1 = center_y + @sin(angle1) * radius;
            const x2 = center_x + @cos(angle2) * radius;
            const y2 = center_y + @sin(angle2) * radius;

            drawLine(x1, y1, x2, y2, col);
        }
    }

    // =========================================================================
    // TEXTURE VALIDITY CHECK
    // =========================================================================

    pub fn isTextureValid(texture: Texture) bool {
        return texture.handle != null;
    }
};

//! ECS Components for rendering
//!
//! These components can be added to entities to enable rendering.

const rl = @import("raylib");

/// Render component - marks an entity for rendering
pub const Render = struct {
    /// Z-index for draw order (higher = rendered on top)
    z_index: u8 = 0,
    /// Name/key to look up sprite in atlas
    sprite_name: []const u8 = "",
    /// Offset from entity position for rendering
    offset_x: f32 = 0,
    offset_y: f32 = 0,
    /// Tint color (default white = no tint)
    tint: rl.Color = rl.Color.white,
    /// Scale factor
    scale: f32 = 1.0,
    /// Rotation in degrees
    rotation: f32 = 0,
    /// Flip horizontally
    flip_x: bool = false,
    /// Flip vertically
    flip_y: bool = false,
};

/// Sprite location in a texture atlas
pub const SpriteLocation = struct {
    /// X position in atlas texture
    x: u32,
    /// Y position in atlas texture
    y: u32,
    /// Width of sprite
    width: u32,
    /// Height of sprite
    height: u32,
    /// Index of texture atlas (if multiple atlases)
    texture_index: u8 = 0,
};

/// Animation types - extend this enum for game-specific animations
pub const AnimationType = enum {
    idle,
    walk,
    run,
    jump,
    fall,
    attack,
    hurt,
    die,
    // Work-related (for simulation games)
    work,
    carry,
    // Rest-related
    sleep,
    sit,
    eat,
    drink,
    // Social
    talk,
    wave,
    dance,
    // Custom slots for game-specific animations
    custom_1,
    custom_2,
    custom_3,
    custom_4,
    custom_5,

    /// Get the base name for sprite lookup
    pub fn toSpriteName(self: AnimationType) []const u8 {
        return switch (self) {
            .idle => "idle",
            .walk => "walk",
            .run => "run",
            .jump => "jump",
            .fall => "fall",
            .attack => "attack",
            .hurt => "hurt",
            .die => "die",
            .work => "work",
            .carry => "carry",
            .sleep => "sleep",
            .sit => "sit",
            .eat => "eat",
            .drink => "drink",
            .talk => "talk",
            .wave => "wave",
            .dance => "dance",
            .custom_1 => "custom_1",
            .custom_2 => "custom_2",
            .custom_3 => "custom_3",
            .custom_4 => "custom_4",
            .custom_5 => "custom_5",
        };
    }
};

/// Animation component for animated sprites
pub const Animation = struct {
    /// Current frame index
    frame: u32 = 0,
    /// Total number of frames
    total_frames: u32 = 1,
    /// Duration of each frame in seconds
    frame_duration: f32 = 0.1,
    /// Time elapsed on current frame
    elapsed_time: f32 = 0,
    /// Current animation type
    anim_type: AnimationType = .idle,
    /// Whether animation should loop
    looping: bool = true,
    /// Whether animation is playing
    playing: bool = true,
    /// Callback when animation completes (for non-looping)
    on_complete: ?*const fn () void = null,

    /// Advance the animation by delta time
    pub fn update(self: *Animation, dt: f32) void {
        if (!self.playing) return;

        self.elapsed_time += dt;

        while (self.elapsed_time >= self.frame_duration) {
            self.elapsed_time -= self.frame_duration;
            self.frame += 1;

            if (self.frame >= self.total_frames) {
                if (self.looping) {
                    self.frame = 0;
                } else {
                    self.frame = self.total_frames - 1;
                    self.playing = false;
                    if (self.on_complete) |callback| {
                        callback();
                    }
                }
            }
        }
    }

    /// Reset animation to first frame
    pub fn reset(self: *Animation) void {
        self.frame = 0;
        self.elapsed_time = 0;
        self.playing = true;
    }

    /// Set a new animation type
    pub fn setAnimation(self: *Animation, anim_type: AnimationType, total_frames: u32) void {
        if (self.anim_type != anim_type) {
            self.anim_type = anim_type;
            self.total_frames = total_frames;
            self.reset();
        }
    }
};

/// Container for multiple animations on an entity
pub const AnimationsArray = struct {
    animations: [8]?Animation = [_]?Animation{null} ** 8,
    active_index: u8 = 0,

    pub fn getActive(self: *AnimationsArray) ?*Animation {
        return if (self.animations[self.active_index]) |*anim| anim else null;
    }

    pub fn setActive(self: *AnimationsArray, index: u8) void {
        if (index < self.animations.len) {
            self.active_index = index;
        }
    }
};

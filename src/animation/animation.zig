//! Animation player and utilities

const std = @import("std");
const components = @import("../components/components.zig");
const Animation = components.Animation;
const AnimationType = components.AnimationType;

/// Animation player for managing entity animations
pub const AnimationPlayer = struct {
    /// Animation definitions: maps animation type to frame count
    frame_counts: std.AutoHashMap(AnimationType, u32),
    /// Default frame duration
    default_frame_duration: f32,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) AnimationPlayer {
        return .{
            .frame_counts = std.AutoHashMap(AnimationType, u32).init(allocator),
            .default_frame_duration = 0.1,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *AnimationPlayer) void {
        self.frame_counts.deinit();
    }

    /// Register an animation type with its frame count
    pub fn registerAnimation(self: *AnimationPlayer, anim_type: AnimationType, frame_count: u32) !void {
        try self.frame_counts.put(anim_type, frame_count);
    }

    /// Get frame count for an animation type
    pub fn getFrameCount(self: *AnimationPlayer, anim_type: AnimationType) u32 {
        return self.frame_counts.get(anim_type) orelse 1;
    }

    /// Create a new Animation component for a given type
    pub fn createAnimation(self: *AnimationPlayer, anim_type: AnimationType) Animation {
        return .{
            .frame = 0,
            .total_frames = self.getFrameCount(anim_type),
            .frame_duration = self.default_frame_duration,
            .elapsed_time = 0,
            .anim_type = anim_type,
            .looping = true,
            .playing = true,
        };
    }

    /// Transition an animation to a new type
    pub fn transitionTo(self: *AnimationPlayer, anim: *Animation, new_type: AnimationType) void {
        if (anim.anim_type != new_type) {
            anim.anim_type = new_type;
            anim.total_frames = self.getFrameCount(new_type);
            anim.frame = 0;
            anim.elapsed_time = 0;
            anim.playing = true;
        }
    }
};

/// Generate sprite name for current animation frame
/// Format: "{prefix}/{anim_type}_{frame:04}"
pub fn generateSpriteName(
    buffer: []u8,
    prefix: []const u8,
    anim_type: AnimationType,
    frame: u32,
) []const u8 {
    const anim_name = anim_type.toSpriteName();
    const result = std.fmt.bufPrint(buffer, "{s}/{s}_{d:0>4}", .{
        prefix,
        anim_name,
        frame + 1, // Frames typically 1-indexed in sprite sheets
    }) catch return "";
    return result;
}

test "animation update" {
    var anim = Animation{
        .frame = 0,
        .total_frames = 4,
        .frame_duration = 0.1,
        .elapsed_time = 0,
        .anim_type = .walk,
        .looping = true,
        .playing = true,
    };

    // Update less than frame duration
    anim.update(0.05);
    try std.testing.expectEqual(@as(u32, 0), anim.frame);

    // Update past frame duration
    anim.update(0.06);
    try std.testing.expectEqual(@as(u32, 1), anim.frame);

    // Update to wrap around
    anim.frame = 3;
    anim.elapsed_time = 0.09;
    anim.update(0.02);
    try std.testing.expectEqual(@as(u32, 0), anim.frame);
}

test "animation non-looping" {
    var anim = Animation{
        .frame = 3,
        .total_frames = 4,
        .frame_duration = 0.1,
        .elapsed_time = 0.09,
        .anim_type = .die,
        .looping = false,
        .playing = true,
    };

    anim.update(0.02);
    try std.testing.expectEqual(@as(u32, 3), anim.frame);
    try std.testing.expectEqual(false, anim.playing);
}

# Example 02: Animation System

This example demonstrates the animation system for sprite-based animations.

## What You'll Learn

- Creating an AnimationPlayer
- Registering animation types with frame counts
- Updating animations over time
- Transitioning between animation types
- Generating sprite names for animation frames

## Running the Example

```bash
zig build run-example-02
```

## Controls

- **1**: Switch to Idle animation (4 frames)
- **2**: Switch to Walk animation (8 frames)
- **3**: Switch to Run animation (6 frames)
- **4**: Switch to Jump animation (4 frames)
- **ESC**: Exit

## Code Highlights

### Setting Up AnimationPlayer

```zig
var anim_player = gfx.AnimationPlayer.init(allocator);
defer anim_player.deinit();

// Register animations with frame counts
try anim_player.registerAnimation(.idle, 4);
try anim_player.registerAnimation(.walk, 8);
try anim_player.registerAnimation(.run, 6);
```

### Creating and Updating Animations

```zig
// Create animation from registered type
var animation = anim_player.createAnimation(.idle);
animation.frame_duration = 0.15; // 150ms per frame

// Update each frame
animation.update(delta_time);
```

### Transitioning Between Animations

```zig
// Smooth transition - resets frame to 0
anim_player.transitionTo(&animation, .walk);
```

### Generating Sprite Names

```zig
// Generates: "player/walk_0001", "player/walk_0002", etc.
const sprite_name = gfx.animation.generateSpriteName(
    &buffer,
    "player",      // prefix
    animation.anim_type,
    animation.frame,
);
```

## Sprite Naming Convention

The animation system expects sprites named like:
```
{prefix}/{animation_type}_{frame_number:04}
```

Examples:
- `player/idle_0001`
- `player/walk_0001`, `player/walk_0002`, ...
- `enemy/attack_0001`

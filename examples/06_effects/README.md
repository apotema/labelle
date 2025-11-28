# Example 06: Visual Effects

This example demonstrates the visual effects system including fades and flashes.

## What You'll Learn

- Fade in/out effects
- Temporal fade (time-of-day effects)
- Flash effects for hit feedback
- Using effect systems with ECS

## Running the Example

```bash
zig build run-example-06
```

## Controls

- **R**: Reset fade effects
- **F**: Trigger flash effect
- **Up/Down Arrows**: Adjust time speed
- **ESC**: Exit

## Available Effects

### Fade Effect

Gradually changes entity alpha over time.

```zig
registry.add(entity, gfx.effects.Fade{
    .alpha = 0,           // Current alpha (0-1)
    .target_alpha = 1.0,  // Target to fade towards
    .speed = 0.5,         // Alpha change per second
    .remove_on_fadeout = false,  // Remove entity when alpha reaches 0
});
```

### Temporal Fade

Changes alpha based on game time (day/night cycle).

```zig
registry.add(entity, gfx.effects.TemporalFade{
    .fade_start_hour = 18.0,  // Start fading at 6 PM
    .fade_end_hour = 22.0,    // Fully faded at 10 PM
    .min_alpha = 0.2,         // Minimum alpha when fully faded
});
```

### Flash Effect

Quick alpha pulse for hit feedback or attention.

```zig
// Store original tint before adding flash
const original_tint = registry.get(gfx.Render, entity).tint;

registry.add(entity, gfx.effects.Flash{
    .duration = 0.15,          // Total flash duration
    .remaining = 0.15,         // Time remaining
    .color = rl.Color.white,   // Flash color
    .original_tint = original_tint,  // Restored after flash
});
```

## Updating Effects

Add these system calls to your game loop:

```zig
// Update fade effects
gfx.effects.fadeUpdateSystem(&registry, dt);

// Update temporal fades (pass current game hour 0-24)
gfx.effects.temporalFadeSystem(&registry, game_hour);

// Update flash effects
gfx.effects.flashUpdateSystem(&registry, dt);
```

## Use Cases

| Effect | Use Case |
|--------|----------|
| Fade In | Scene transitions, spawning entities |
| Fade Out | Death animations, despawning |
| Temporal | Day/night lighting, time-based visibility |
| Flash | Damage feedback, item collection, alerts |

## Combining with Render Component

Effects modify the `Render` component's tint alpha:

```zig
// Fade effect updates render.tint.a based on fade.alpha
render.tint.a = @intFromFloat(fade.alpha * 255.0);

// Flash temporarily replaces render.tint with flash.color
```

This means effects work automatically with the sprite render system.

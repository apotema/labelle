# Example 04: Camera System

This example demonstrates the 2D camera system with pan, zoom, and bounds.

## What You'll Learn

- Creating and configuring a camera
- Panning (moving) the camera
- Zooming in and out
- Setting world bounds
- Converting between screen and world coordinates

## Running the Example

```bash
zig build run-example-04
```

## Controls

- **WASD / Arrow Keys**: Pan camera
- **Mouse Wheel / +/-**: Zoom in/out
- **R**: Reset camera position and zoom
- **B**: Toggle world bounds
- **ESC**: Exit

## Code Highlights

### Creating a Camera

```zig
var camera = gfx.Camera.init();

// Optional: Set zoom limits
camera.min_zoom = 0.25;
camera.max_zoom = 4.0;
```

### Panning

```zig
// Pan by delta (accounts for zoom)
camera.pan(dx, dy);

// Set absolute position
camera.setPosition(x, y);
```

### Zooming

```zig
// Zoom by delta
camera.zoomBy(0.1);  // Zoom in
camera.zoomBy(-0.1); // Zoom out

// Set absolute zoom
camera.setZoom(2.0);
```

### World Bounds

```zig
// Set bounds to keep camera within world
camera.setBounds(0, 0, world_width, world_height);

// Clear bounds for free movement
camera.clearBounds();

// Check if bounds are enabled
if (camera.bounds.isEnabled()) { ... }
```

### Coordinate Conversion

```zig
// Screen to world (e.g., for mouse picking)
const mouse_screen = rl.getMousePosition();
const mouse_world = camera.screenToWorld(mouse_screen.x, mouse_screen.y);

// World to screen (e.g., for UI positioning)
const screen_pos = camera.worldToScreen(entity.x, entity.y);
```

### Using with Raylib

```zig
// Begin camera mode
rl.beginMode2D(camera.toRaylib());

// Draw world objects here...

rl.endMode2D();

// Draw UI (screen space) after endMode2D
```

## Camera Properties

| Property | Default | Description |
|----------|---------|-------------|
| x, y | 0, 0 | Camera center position |
| zoom | 1.0 | Zoom level (1.0 = normal) |
| rotation | 0 | Rotation in degrees |
| min_zoom | 0.1 | Minimum zoom level |
| max_zoom | 3.0 | Maximum zoom level |

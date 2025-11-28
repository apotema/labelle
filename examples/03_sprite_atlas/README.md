# Example 03: Sprite Atlas Loading

This example demonstrates loading and managing TexturePacker sprite atlases.

## What You'll Learn

- Loading sprite atlases from JSON + PNG files
- Managing multiple atlases with TextureManager
- Querying sprite data by name
- Finding sprites across multiple atlases

## Running the Example

```bash
zig build run-example-03
```

## Supported Atlas Format

The library supports TexturePacker JSON format (both array and hash variants):

### Hash Format
```json
{
  "frames": {
    "player_idle_0001": {
      "frame": {"x": 0, "y": 0, "w": 32, "h": 32}
    },
    "player_idle_0002": {
      "frame": {"x": 32, "y": 0, "w": 32, "h": 32}
    }
  },
  "meta": {
    "image": "characters.png",
    "size": {"w": 512, "h": 512}
  }
}
```

### Array Format
```json
{
  "frames": [
    {
      "filename": "player_idle_0001",
      "frame": {"x": 0, "y": 0, "w": 32, "h": 32}
    },
    {
      "filename": "player_idle_0002",
      "frame": {"x": 32, "y": 0, "w": 32, "h": 32}
    }
  ]
}
```

## Code Highlights

### Loading Multiple Atlases

```zig
var texture_manager = gfx.TextureManager.init(allocator);
defer texture_manager.deinit();

// Load character sprites
try texture_manager.loadAtlas(
    "characters",
    "assets/characters.json",
    "assets/characters.png"
);

// Load tile sprites
try texture_manager.loadAtlas(
    "tiles",
    "assets/tiles.json",
    "assets/tiles.png"
);
```

### Finding Sprites

```zig
// Find in specific atlas
if (texture_manager.getAtlas("characters")) |atlas| {
    if (atlas.getSprite("player_idle_0001")) |sprite| {
        // Use sprite.x, sprite.y, sprite.width, sprite.height
    }
}

// Find across all atlases
if (texture_manager.findSprite("player_idle_0001")) |result| {
    // result.atlas - the atlas containing the sprite
    // result.rect - raylib Rectangle for drawing
}
```

### Unloading Atlases

```zig
// Unload specific atlas to free memory
texture_manager.unloadAtlas("characters");
```

## Creating Atlases with TexturePacker

1. Open TexturePacker
2. Add your sprite images
3. Set Data Format to "JSON (Hash)" or "JSON (Array)"
4. Export JSON and PNG files
5. Load in your game using this library

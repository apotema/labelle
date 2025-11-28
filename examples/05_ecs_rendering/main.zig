//! Example 05: ECS Rendering
//!
//! This example demonstrates:
//! - Using render components with zig-ecs
//! - Sprite render system
//! - Animation update system
//! - Z-index layering
//!
//! Run with: zig build run-example-05

const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs");
const gfx = @import("raylib-ecs-gfx");

// Game-specific Position component
const Position = struct {
    x: f32 = 0,
    y: f32 = 0,
};

// Velocity for movement
const Velocity = struct {
    dx: f32 = 0,
    dy: f32 = 0,
};

pub fn main() !void {
    // Initialize raylib
    rl.initWindow(800, 600, "Example 05: ECS Rendering");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    // Initialize allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize ECS registry
    var registry = ecs.Registry(u32).init(allocator);
    defer registry.deinit();

    // Initialize renderer
    var renderer = gfx.Renderer.init(allocator);
    defer renderer.deinit();

    // Create entities with different z-indices
    // Background entity (z=0)
    const bg_entity = registry.create();
    registry.add(bg_entity, Position{ .x = 400, .y = 300 });
    registry.add(bg_entity, gfx.Render{
        .z_index = gfx.ZIndex.background,
        .sprite_name = "background",
        .tint = rl.Color.dark_blue,
    });

    // Floor tiles (z=10)
    for (0..5) |i| {
        const tile = registry.create();
        registry.add(tile, Position{
            .x = 100 + @as(f32, @floatFromInt(i)) * 150,
            .y = 400,
        });
        registry.add(tile, gfx.Render{
            .z_index = gfx.ZIndex.floor,
            .sprite_name = "tile",
            .tint = rl.Color.brown,
        });
    }

    // Items (z=30)
    const item1 = registry.create();
    registry.add(item1, Position{ .x = 200, .y = 350 });
    registry.add(item1, gfx.Render{
        .z_index = gfx.ZIndex.items,
        .sprite_name = "item",
        .tint = rl.Color.gold,
        .scale = 0.5,
    });

    // Player character (z=40) with animation
    const player = registry.create();
    registry.add(player, Position{ .x = 400, .y = 350 });
    registry.add(player, Velocity{ .dx = 0, .dy = 0 });
    registry.add(player, gfx.Render{
        .z_index = gfx.ZIndex.characters,
        .sprite_name = "player",
        .tint = rl.Color.sky_blue,
    });
    registry.add(player, gfx.Animation{
        .frame = 0,
        .total_frames = 4,
        .frame_duration = 0.2,
        .anim_type = .idle,
        .looping = true,
        .playing = true,
    });

    // Enemy characters (z=40)
    const enemy1 = registry.create();
    registry.add(enemy1, Position{ .x = 600, .y = 350 });
    registry.add(enemy1, Velocity{ .dx = -50, .dy = 0 });
    registry.add(enemy1, gfx.Render{
        .z_index = gfx.ZIndex.characters,
        .sprite_name = "enemy",
        .tint = rl.Color.red,
    });
    registry.add(enemy1, gfx.Animation{
        .frame = 0,
        .total_frames = 6,
        .frame_duration = 0.15,
        .anim_type = .walk,
        .looping = true,
        .playing = true,
    });

    // UI overlay (z=70)
    const ui_element = registry.create();
    registry.add(ui_element, Position{ .x = 100, .y = 50 });
    registry.add(ui_element, gfx.Render{
        .z_index = gfx.ZIndex.ui,
        .sprite_name = "ui_panel",
        .tint = rl.Color{ .r = 255, .g = 255, .b = 255, .a = 200 },
    });

    // Main loop
    while (!rl.windowShouldClose()) {
        const dt = rl.getFrameTime();

        // Player movement
        var player_vel = registry.get(Velocity, player);
        player_vel.dx = 0;

        if (rl.isKeyDown(rl.KeyboardKey.key_left) or rl.isKeyDown(rl.KeyboardKey.key_a)) {
            player_vel.dx = -200;
            var render = registry.get(gfx.Render, player);
            render.flip_x = true;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_right) or rl.isKeyDown(rl.KeyboardKey.key_d)) {
            player_vel.dx = 200;
            var render = registry.get(gfx.Render, player);
            render.flip_x = false;
        }

        // Update player animation based on movement
        var player_anim = registry.get(gfx.Animation, player);
        if (player_vel.dx != 0) {
            if (player_anim.anim_type != .walk) {
                player_anim.setAnimation(.walk, 6);
            }
        } else {
            if (player_anim.anim_type != .idle) {
                player_anim.setAnimation(.idle, 4);
            }
        }

        // Movement system
        {
            var view = registry.view(.{ Position, Velocity }, .{});
            var iter = view.iterator();
            while (iter.next()) |entity| {
                var pos = view.get(Position, entity);
                const vel = view.getConst(Velocity, entity);
                pos.x += vel.dx * dt;
                pos.y += vel.dy * dt;

                // Simple bounds
                pos.x = @max(50, @min(750, pos.x));
            }
        }

        // Enemy patrol (simple bounce)
        {
            var enemy_pos = registry.get(Position, enemy1);
            var enemy_vel = registry.get(Velocity, enemy1);
            if (enemy_pos.x < 400 or enemy_pos.x > 700) {
                enemy_vel.dx = -enemy_vel.dx;
                var render = registry.get(gfx.Render, enemy1);
                render.flip_x = enemy_vel.dx > 0;
            }
        }

        // Update animations
        gfx.systems.animationUpdateSystem(&registry, dt);

        // Rendering
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.dark_gray);

        // Render entities (with placeholder visuals since we don't have actual sprites)
        // In a real game, use: gfx.systems.spriteRenderSystem(Position, &registry, &renderer);

        // Manual rendering with z-sorting for demo
        var render_list = std.ArrayList(struct {
            pos: Position,
            render: gfx.Render,
            anim: ?gfx.Animation,
        }).init(allocator);
        defer render_list.deinit();

        {
            var view = registry.view(.{ Position, gfx.Render }, .{});
            var iter = view.iterator();
            while (iter.next()) |entity| {
                const pos = view.getConst(Position, entity);
                const render = view.getConst(gfx.Render, entity);
                const anim = if (registry.has(gfx.Animation, entity))
                    registry.getConst(gfx.Animation, entity)
                else
                    null;
                render_list.append(.{ .pos = pos, .render = render, .anim = anim }) catch continue;
            }
        }

        // Sort by z_index
        std.mem.sort(@TypeOf(render_list.items[0]), render_list.items, {}, struct {
            fn lessThan(_: void, a: anytype, b: anytype) bool {
                return a.render.z_index < b.render.z_index;
            }
        }.lessThan);

        // Draw
        for (render_list.items) |item| {
            const size: f32 = 40 * item.render.scale;
            var x = item.pos.x - size / 2 + item.render.offset_x;
            const y = item.pos.y - size / 2 + item.render.offset_y;

            // Handle flip
            if (item.render.flip_x) {
                x = item.pos.x + size / 2 - item.render.offset_x;
            }

            // Draw with animation frame indicator
            rl.drawRectangle(
                @intFromFloat(x),
                @intFromFloat(y),
                @intFromFloat(size),
                @intFromFloat(size),
                item.render.tint,
            );

            // Show animation frame if animated
            if (item.anim) |anim| {
                var frame_buf: [8]u8 = undefined;
                const frame_str = std.fmt.bufPrint(&frame_buf, "{d}", .{anim.frame + 1}) catch "?";
                rl.drawText(
                    @ptrCast(frame_str),
                    @intFromFloat(x + size / 2 - 4),
                    @intFromFloat(y + size / 2 - 8),
                    16,
                    rl.Color.white,
                );
            }
        }

        // UI
        rl.drawText("ECS Rendering Example", 10, 10, 20, rl.Color.white);
        rl.drawText("A/D or Left/Right: Move player", 10, 40, 14, rl.Color.light_gray);
        rl.drawText("ESC: Exit", 10, 60, 14, rl.Color.light_gray);

        // Z-index legend
        rl.drawText("Z-Index Layers:", 600, 10, 14, rl.Color.white);
        rl.drawText("Background: 0", 600, 30, 12, rl.Color.dark_blue);
        rl.drawText("Floor: 10", 600, 45, 12, rl.Color.brown);
        rl.drawText("Items: 30", 600, 60, 12, rl.Color.gold);
        rl.drawText("Characters: 40", 600, 75, 12, rl.Color.sky_blue);
        rl.drawText("UI: 70", 600, 90, 12, rl.Color.white);

        // Entity count
        var entity_buf: [32]u8 = undefined;
        const entity_str = std.fmt.bufPrint(&entity_buf, "Entities: {d}", .{registry.alive()}) catch "?";
        rl.drawText(@ptrCast(entity_str), 10, 580, 14, rl.Color.light_gray);
    }
}

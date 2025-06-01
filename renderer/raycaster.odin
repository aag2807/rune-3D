package renderer

import u "../constants"
import "../game"
import "core:fmt"
import "core:math"
import "core:slice"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

RaycastHit :: struct {
	distance:  f32,
	wall_type: u8,
	hit_side:  bool,
	texture_x: f32,
}

render_frame :: proc() {
	camera := get_camera()
	game_map := game.get_map()
	player := game.get_player()


	render_3d_view(camera, game_map)
	render_enemies_3d(camera)
	render_crosshair()
	render_player_sprites(player)
}

@(private = "file")
render_player_sprites :: proc(player: ^game.Player) {
	scale: f32 = 2.0

	#partial switch player.state {
	case .idle:
		texture_width: f32 = 57
		texture_height: f32 = 56
		rl.DrawTextureEx(
			player.idle_sprite,
			rl.Vector2 {
				(SCREEN_WIDTH / 2) - ((texture_width * scale) / 2),
				SCREEN_HEIGHT - (texture_height * scale),
			},
			0.0,
			scale,
			rl.WHITE,
		)
	//shooting has 4 sprites and should run at 12 fps 
	case .shooting:
		frames_elapsed := int(rl.GetTime() * 12) - player.shoot_start_frame
		frame := frames_elapsed % 4

		if frames_elapsed >= 4 && frame == 0 {
			player.state = game.PlayerState.idle
			return
		}

		texture := player.shoot_sprites[frame]
		texture_width: f32 = f32(texture.width)
		texture_height: f32 = f32(texture.height)

		rl.DrawTextureEx(
			texture,
			rl.Vector2 {
				(SCREEN_WIDTH / 2) - ((texture_width * scale) / 2),
				SCREEN_HEIGHT - (texture_height * scale),
			},
			0.0,
			scale,
			rl.WHITE,
		)
	}
}

@(private = "file")
render_3d_view :: proc(camera: Camera, game_map: ^game.Map) {
	half_fov: f32 = FOV * 0.5

	for x in 0 ..< SCREEN_WIDTH {
		// Calculate ray angle
		screen_x: f32 = (f32(x) / SCREEN_WIDTH) * 2.0 - 1.0 // -1 to 1
		ray_angle := camera.angle + screen_x * half_fov

		// Cast ray
		hit := cast_ray(camera.pos, ray_angle, game_map)

		// Calculate wall height and position
		wall_height := SCREEN_HEIGHT / (hit.distance * math.cos(screen_x * half_fov))
		wall_center := SCREEN_HEIGHT * 0.5 + camera.pitch * 100 // pitch scaling

		wall_top := wall_center - wall_height * 0.5
		wall_bottom := wall_center + wall_height * 0.5

		// Choose wall color based on hit side (simple shading)
		wall_color := rl.WHITE

		if hit.texture_x == 1 do wall_color = u.LOTUS_BRIGHT_TEAL
		if hit.texture_x == 2 do wall_color = rl.GREEN // Example texture colors

		if hit.hit_side {
			if hit.texture_x == 1 do wall_color = u.LOTUS_DEEP_TEAL // EW walls darker
			if hit.texture_x == 2 do wall_color = rl.DARKGREEN
		}

		// Draw wall slice
		rl.DrawLine(i32(x), i32(wall_top), i32(x), i32(wall_bottom), wall_color)

		// Draw floor and ceiling
		ceiling_color := rl.DARKGRAY
		floor_color := rl.GRAY

		if wall_top > 0 {
			rl.DrawLine(i32(x), 0, i32(x), i32(wall_top), ceiling_color)
		}
		if wall_bottom < SCREEN_HEIGHT {
			rl.DrawLine(i32(x), i32(wall_bottom), i32(x), SCREEN_HEIGHT, floor_color)
		}
	}
}


cast_ray :: proc(start: [2]f32, angle: f32, game_map: ^game.Map) -> RaycastHit {
	//dda algorithm implementation
	dx := math.cos(angle)
	dy := math.sin(angle)

	map_x := int(start.x)
	map_y := int(start.y)

	// Calculate delta distances
	delta_dist_x := math.abs(1.0 / dx) if dx != 0 else math.F32_MAX
	delta_dist_y := math.abs(1.0 / dy) if dy != 0 else math.F32_MAX

	// Calculate step and initial side_dist
	step_x, step_y: int
	side_dist_x, side_dist_y: f32

	if dx < 0 {
		step_x = -1
		side_dist_x = (start.x - f32(map_x)) * delta_dist_x
	} else {
		step_x = 1
		side_dist_x = (f32(map_x) + 1.0 - start.x) * delta_dist_x
	}

	if dy < 0 {
		step_y = -1
		side_dist_y = (start.y - f32(map_y)) * delta_dist_y
	} else {
		step_y = 1
		side_dist_y = (f32(map_y) + 1.0 - start.y) * delta_dist_y
	}

	// Perform DDA
	hit := false
	side := false // false = EW wall hit, true = NS wall hit

	tile_identity: u8 = 1
	for !hit {
		// Jump to next map square, either in x-direction, or in y-direction
		if side_dist_x < side_dist_y {
			side_dist_x += delta_dist_x
			map_x += step_x
			side = false
		} else {
			side_dist_y += delta_dist_y
			map_y += step_y
			side = true
		}

		map_tile := game.get_tile(game_map, map_x, map_y)
		// Check if ray has hit a wall
		if map_tile != 0 {
			hit = true
			tile_identity = map_tile
		}
	}

	// Calculate distance
	distance: f32
	if !side {
		distance = (f32(map_x) - start.x + (1 - f32(step_x)) / 2) / dx
	} else {
		distance = (f32(map_y) - start.y + (1 - f32(step_y)) / 2) / dy
	}

	return RaycastHit {
		distance  = distance,
		wall_type = 1,
		hit_side  = side,
		texture_x = f32(tile_identity), // TODO: calculate texture coordinate
	}
}

render_crosshair :: proc() {
	center_x: i32 = SCREEN_WIDTH / 2
	center_y: i32 = SCREEN_HEIGHT / 2

	size: i32 = 10

	rl.DrawLine(center_x - size, center_y, center_x + size, center_y, rl.WHITE)
	rl.DrawLine(center_x, center_y - size, center_x, center_y + size, rl.WHITE)
}


Enemy_Render_Data :: struct {
	enemy:       ^game.Enemy,
	distance:    f32,
	screen_x:    f32,
	sprite_size: f32,
}

@(private = "file")
render_enemies_3d :: proc(camera: Camera) {
	enemies := game.get_enemies()
	render_list: [dynamic]Enemy_Render_Data
	defer delete(render_list)


	for &enemy in enemies {
		if !enemy.alive do continue

		// Calculate relative position to camera (world space)
		rel_x := enemy.pos.x - camera.pos.x
		rel_y := enemy.pos.y - camera.pos.y

		// Calculate actual distance for depth sorting
		world_distance := math.sqrt(rel_x * rel_x + rel_y * rel_y)

		// Transform to camera space for projection
		cos_a := math.cos(-camera.angle)
		sin_a := math.sin(-camera.angle)

		transformed_x := rel_x * cos_a - rel_y * sin_a
		transformed_y := rel_x * sin_a + rel_y * cos_a

		// Skip if behind camera or too far
		if transformed_y <= 0.1 || world_distance > 15.0 do continue

		// Project to screen coordinates
		screen_x :=
			(transformed_x / transformed_y) * (f32(SCREEN_WIDTH) / 2) + f32(SCREEN_WIDTH) / 2

		// Calculate sprite size based on distance
		sprite_size := f32(SCREEN_HEIGHT) / transformed_y * 0.6 // Reduced from 0.8 for better scaling

		// Only render if on screen
		if screen_x > -sprite_size / 2 && screen_x < f32(SCREEN_WIDTH) + sprite_size / 2 {
			append(
				&render_list,
				Enemy_Render_Data {
					enemy       = &enemy,
					distance    = world_distance, // Use world distance for sorting
					screen_x    = screen_x,
					sprite_size = sprite_size,
				},
			)
		}
	}

	// Sort by distance (far to near for proper depth)
	slice.sort_by(render_list[:], proc(a, b: Enemy_Render_Data) -> bool {
		return a.distance > b.distance
	})

	// Render enemies
	for render_data in render_list {
		enemy := render_data.enemy

		// Calculate sprite position (centered horizontally, bottom-aligned to floor)
		sprite_x := render_data.screen_x - render_data.sprite_size / 2
		sprite_y := f32(SCREEN_HEIGHT) / 2 - render_data.sprite_size / 2 + camera.pitch * 100

		// Choose color based on enemy state for visual feedback
		tint_color := rl.WHITE
		switch enemy.state {
		case .idle:
			tint_color = rl.WHITE
		case .chasing:
			tint_color = rl.Color{255, 200, 200, 255} // Slight red tint when chasing
		case .attacking:
			tint_color = rl.Color{255, 150, 150, 255} // More red when attacking
		case .dead:
			tint_color = rl.Color{100, 100, 100, 255} // Gray when dead
		}

		// Draw the enemy sprite (billboard - always faces camera)
		scale := render_data.sprite_size / f32(enemy.sprite.height)
		rl.DrawTextureEx(enemy.sprite, rl.Vector2{sprite_x, sprite_y}, 0.0, scale, tint_color)

		// Optional: Draw a health bar above the enemy
		if enemy.health < enemy.max_health && enemy.alive {
			bar_width: f32 = render_data.sprite_size * 0.8
			bar_height: f32 = 4
			bar_x := render_data.screen_x - bar_width / 2
			bar_y := sprite_y - 10

			health_ratio := f32(enemy.health) / f32(enemy.max_health)

			// Background (red)
			rl.DrawRectangle(i32(bar_x), i32(bar_y), i32(bar_width), i32(bar_height), rl.RED)
			// Foreground (green)
			rl.DrawRectangle(
				i32(bar_x),
				i32(bar_y),
				i32(bar_width * health_ratio),
				i32(bar_height),
				rl.GREEN,
			)
		}
	}
}

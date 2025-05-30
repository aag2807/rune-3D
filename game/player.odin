package game

import "core:math"
import rl "vendor:raylib"

PlayerState :: enum {
	idle,
	shooting,
	reloading,
	dead,
}

Player :: struct {
	// position and orientation 
	pos:               [2]f32,
	angle:             f32,
	pitch:             f32,

	//movement speed 
	move_speed:        f32,
	state:             PlayerState,

	//camera settings
	sensitivity:       f32, // mouse sensitivity
	pitch_limit:       f32,
	idle_sprite:       rl.Texture2D,
	shoot_sprites:     [4]rl.Texture2D, // array of textures for shooting animation
	shoot_start_frame: int,
}

move_player :: proc(player: ^Player, forward, strafe, dt: f32) {
	new_pos := player.pos
	m := get_map()

	if forward != 0 {
		new_pos.x += math.cos(player.angle) * forward * player.move_speed * dt
		new_pos.y += math.sin(player.angle) * forward * player.move_speed * dt
	}

	if strafe != 0 {
		strafe_angle := player.angle + math.PI * 0.5
		new_pos.x += math.cos(strafe_angle) * strafe * player.move_speed * dt
		new_pos.y += math.sin(strafe_angle) * strafe * player.move_speed * dt
	}


	if !is_wall(m, new_pos.x, player.pos.y) {
		player.pos.x = new_pos.x
	}

	if !is_wall(m, player.pos.x, new_pos.y) {
		player.pos.y = new_pos.y
	}
}

rotate_player :: proc(player: ^Player, delta_yaw, delta_picth: f32) {
	player.angle += delta_yaw
	player.pitch += delta_picth

	if player.angle < 0 do player.angle += 2 * math.PI
	if player.angle >= 2 * math.PI do player.angle -= 2 * math.PI

	player.pitch = math.clamp(player.pitch, -player.pitch_limit, player.pitch_limit)
}

package inputs

import "../game"
import "core:fmt"
import rl "vendor:raylib"

update_input :: proc(dt: f32) {
	player := game.get_player()

	mouse_delta := rl.GetMouseDelta()
	if mouse_delta.x != 0 || mouse_delta.y != 0 {
		delta_yaw := mouse_delta.x * player.sensitivity
		delta_pitch := -mouse_delta.y * player.sensitivity

		game.rotate_player(player, delta_yaw, delta_pitch)
	}

	forward: f32 = 0.0
	strafe: f32 = 0.0

	if rl.IsKeyDown(.W) {
		forward += 1
	}
	if rl.IsKeyDown(.S) {
		forward -= 1
	}

	if rl.IsKeyDown(.A) {
		strafe -= 1
	}

	if rl.IsKeyDown(.D) {
		strafe += 1
	}

	if forward != 0 || strafe != 0 {
		game.move_player(player, forward, strafe, dt)
	}

  shoot()
}

shoot :: proc() {
	player := game.get_player()
	if player.state == game.PlayerState.idle && rl.IsMouseButtonPressed(.LEFT) {
		player.state = game.PlayerState.shooting
    player.shoot_start_frame = int(rl.GetTime() * 12) // Start the shooting animation at the current time
  }
}

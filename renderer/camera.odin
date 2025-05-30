package renderer

import "../game"
import "core:math"

FOV :: math.PI * 0.66 // 120 degrees
RENDER_DISTANCE :: 20.0

Camera :: struct {
	pos:   [2]f32,
	angle: f32,
	pitch: f32,
}

get_camera :: proc() -> Camera {
	player := game.get_player()

	return Camera{pos = player.pos, angle = player.angle, pitch = player.pitch}
}

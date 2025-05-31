package game

import rl "vendor:raylib"

EnemyState :: enum {
	idle,
	chasing,
	attacking,
	dead,
}

Enemy :: struct {
	pos:        [2]f32,
	angle:      f32,
	health:     i32,
	max_health: i32,
	state:      EnemyState,
	sprite:     rl.Texture2D,
	size:       f32,
	alive:      bool,
}

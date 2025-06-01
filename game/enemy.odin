package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

EnemyState :: enum {
	idle,
	chasing,
	attacking,
	dead,
}

Enemy :: struct {
	pos:             [2]f32,
	angle:           f32,
	health:          i32,
	max_health:      i32,
	state:           EnemyState,
	sprite:          rl.Texture2D,
	size:            f32,
	alive:           bool,

	// AI properties
	speed:           f32,
	detection_range: f32,
	attack_range:    f32,
	last_attack:     f32,
	attack_cooldown: f32,
}

update_enemies :: proc(dt: f32) {
	player := get_player()
	enemies := get_enemies()

	for i in 0 ..< len(enemies) {
		enemy := &enemies[i]
		if !enemy.alive do continue

		update_enemy_ai(enemy, player, dt)
	}
}

update_enemy_ai :: proc(enemy: ^Enemy, player: ^Player, dt: f32) {
	dx := player.pos.x - enemy.pos.x
	dy := player.pos.y - enemy.pos.y
	distance_to_player := math.sqrt(dx * dx + dy * dy)

	angle_to_player := math.atan2(dy, dx)

	switch enemy.state {
	case .idle:
		if distance_to_player <= enemy.detection_range {
			enemy.state = .chasing
		}

	case .chasing:
		// Move towards player
		if distance_to_player > enemy.attack_range {
			move_enemy_towards_player(enemy, player, dt)
		} else {
			// Close enough to attack
			enemy.state = .attacking
		}

		// Lose interest if player gets too far
		if distance_to_player > enemy.detection_range * 1.5 {
			enemy.state = .idle
		}

	case .attacking:
		// Face the player
		enemy.angle = angle_to_player

		// Attack if cooldown is ready
		current_time := f32(rl.GetTime())
		if current_time - enemy.last_attack >= enemy.attack_cooldown {
			attack_player(enemy, player)
			enemy.last_attack = current_time
		}

		// Go back to chasing if player moves away
		if distance_to_player > enemy.attack_range * 1.2 {
			enemy.state = .chasing
		}

	case .dead:
	// Do nothing
	}
}

// Move enemy towards player with collision detection
move_enemy_towards_player :: proc(enemy: ^Enemy, player: ^Player, dt: f32) {
	dx := player.pos.x - enemy.pos.x
	dy := player.pos.y - enemy.pos.y
	distance := math.sqrt(dx * dx + dy * dy)

	if distance == 0 do return

	// Normalize direction
	norm_dx := dx / distance
	norm_dy := dy / distance

	// Calculate new position
	new_pos := enemy.pos
	new_pos.x += norm_dx * enemy.speed * dt
	new_pos.y += norm_dy * enemy.speed * dt

	// Check collision with walls
	m := get_map()
	if !is_wall(m, new_pos.x, enemy.pos.y) {
		enemy.pos.x = new_pos.x
	}
	if !is_wall(m, enemy.pos.x, new_pos.y) {
		enemy.pos.y = new_pos.y
	}

	// Update enemy angle to face movement direction
	enemy.angle = math.atan2(norm_dy, norm_dx)
}

// Simple attack - just print for now, you can add damage later
attack_player :: proc(enemy: ^Enemy, player: ^Player) {
	// For now, just print attack
	// Later you can add player health and damage
	fmt.println("Enemy attacks player!")
}

package game

import "core:math"
import rl "vendor:raylib"

GameState :: struct {
	player:    Player,
	level_map: Map,
	running:   bool,
	enemies:   [dynamic]Enemy,
}

game_state: GameState

init :: proc() {

	game_state.player = {
		pos         = {2.0, 2.0},
		angle       = 0,
		pitch       = 0,
		sensitivity = 0.003,
		move_speed  = 5.0,
		pitch_limit = math.PI * 0.4,
	}

	game_state.enemies = make([dynamic]Enemy)

	append(&game_state.enemies, create_dummy_enemy())
	game_state.player.shoot_range = 10.0
	game_state.player.fire_rate = 2.0
	game_state.player.last_shot_time = 0.0

	game_state.player.state = PlayerState.idle
	game_state.player.idle_sprite = rl.LoadTexture("assets/Idle.png")

	shoot_1 := rl.LoadTexture("assets/Shoot1.png")
	shoot_2 := rl.LoadTexture("assets/Shoot2.png")
	shoot_3 := rl.LoadTexture("assets/Shoot3.png")
	shoot_4 := rl.LoadTexture("assets/Shoot4.png")

	game_state.player.shoot_sprites = [4]rl.Texture2D{shoot_1, shoot_2, shoot_3, shoot_4}

	game_state.level_map = create_test_map()
	game_state.running = true
}

get_player :: proc() -> ^Player {
	return &game_state.player
}

get_map :: proc() -> ^Map {
	return &game_state.level_map
}

@(private = "file")
create_dummy_enemy :: proc() -> Enemy {
	enemy_sprite := rl.LoadTexture("assets/Enemy.png")

	return {
		pos = {5.0, 5.0},
		angle = 0,
		health = 100,
		max_health = 100,
		state = .idle,
		sprite = enemy_sprite,
		size = 0.3,
		alive = true,
	}
}

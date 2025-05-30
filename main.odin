package main

import "game"
import "inputs"
import "renderer"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600
TARGET_FPS :: 60

cursor_disabled: bool = false

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "RUNE ᛟ")
	rl.SetTargetFPS(TARGET_FPS)
	defer rl.CloseWindow()

	rl.DisableCursor()

	game.init()

	for !rl.WindowShouldClose() {
		// updates
		toggle_cursor()
		dt := rl.GetFrameTime()
		inputs.update_input(dt)


		//draw 
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		renderer.render_frame()

		rl.EndDrawing()
	}
}

toggle_cursor :: proc() {
	if rl.IsKeyPressed(.Q) {
		if cursor_disabled {
			rl.EnableCursor()
		} else {
			rl.DisableCursor()
		}
		cursor_disabled = !cursor_disabled
	}
}

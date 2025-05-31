package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

PlayerState :: enum {
  idle,
  shooting,
  reloading,
  dead,
}

ShotResult :: struct {
  hit:       bool,
  distance:  f32,
  hit_pos:   [2]f32,
  wall_type: u8,
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

  //shooting system 
  shoot_range:       f32,
  last_shot_time:    f32,
  fire_rate:         f32,
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

fire_shot :: proc(player: ^Player) -> ShotResult {
  current_time:f64 = rl.GetTime()

  if f32(current_time) - player.last_shot_time < (1.0 / player.fire_rate) {
    return ShotResult{hit = false}
  }

  if player.state == PlayerState.idle {
    player.state = PlayerState.shooting;
    player.shoot_start_frame = int(current_time * 12)
    player.last_shot_time = f32(current_time)
  } else {
    return ShotResult{hit = false}
  }

  // Cast a ray forward from player position
  shot_result := cast_shot_ray(player.pos, player.angle, player.shoot_range)

  fmt.println(shot_result)

  return shot_result
}

check_enemy_hit :: proc(start: [2]f32, dx, dy, max_range: f32) -> ShotResult {
  enemies := get_enemies()
  closest_distance := max_range
  hit_enemy := false

  for i in 0..<len(enemies) {
    enemy := &enemies[i]
    if !enemy.alive do continue

    // Vector from start to enemy
    to_enemy := enemy.pos - start

    // Project enemy position onto ray
    projection := to_enemy.x * dx + to_enemy.y * dy

    if projection < 0 || projection > max_range do continue

    // Calculate perpendicular distance from ray to enemy
    closest_point := start + [2]f32{dx * projection, dy * projection}
    distance_to_enemy := math.sqrt(
      math.pow(enemy.pos.x - closest_point.x, 2) + 
      math.pow(enemy.pos.y - closest_point.y, 2)
    )
  

    if distance_to_enemy <= enemy.size && projection < closest_distance {
      closest_distance = projection
      hit_enemy = true

      // Damage the enemy
      enemy.health -= 25
      if enemy.health <= 0 {
        enemy.alive = false
        enemy.state = .dead
      }
    }
  }

  if hit_enemy {
    return ShotResult{
      hit = true,
      distance = closest_distance,
      hit_pos = start + [2]f32{dx * closest_distance, dy * closest_distance},
      wall_type = 255, // Special value for enemy hit
    }
  }

  return ShotResult{hit = false}
}

cast_shot_ray :: proc(start: [2]f32, angle: f32, max_range: f32) -> ShotResult {
  dx := math.cos(angle)
  dy := math.sin(angle)

  closest_enemy_hit := check_enemy_hit(start, dx, dy, max_range)

  map_x := int(start.x)
  map_y := int(start.y)
  m := get_map()

  // Calculate delta distances (same as raycasting)
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
  side := false
  distance: f32 = 0
  tile_identity: u8 = 0

  for !hit {
    // Jump to next map square
    if side_dist_x < side_dist_y {
      side_dist_x += delta_dist_x
      map_x += step_x
      side = false
      distance = (f32(map_x) - start.x + (1 - f32(step_x)) / 2) / dx
    } else {
      side_dist_y += delta_dist_y
      map_y += step_y
      side = true
      distance = (f32(map_y) - start.y + (1 - f32(step_y)) / 2) / dy
    }

    // Check if we've exceeded max range
    if distance > max_range {
      return ShotResult{
        hit = false,
        distance = max_range,
        hit_pos = {start.x + dx * max_range, start.y + dy * max_range},
      }
    }

    // Check if ray has hit a wall
    map_tile := get_tile(m, map_x, map_y)
    if map_tile != 0 {
      hit = true
      tile_identity = map_tile
    }
  }

  if closest_enemy_hit.hit && closest_enemy_hit.distance < distance {
    return closest_enemy_hit
  }

  hit_pos := [2]f32{start.x + dx * distance, start.y + dy * distance}

  return ShotResult{
    hit = true,
    distance = distance,
    hit_pos = hit_pos,
    wall_type = tile_identity,
  }
}


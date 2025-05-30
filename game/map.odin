package game

Map :: struct {
	width, height: int,
	tiles:         []u8,
}

create_test_map :: proc() -> Map {
	width, height := 10, 10
	tiles := make([]u8, width * height)

	map_data := [10][10]u8 {
		{1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
		{1, 0, 0, 0, 0, 0, 1, 0, 0, 1},
		{1, 0, 0, 0, 0, 0, 1, 0, 0, 1},
		{1, 0, 0, 0, 0, 0, 1, 0, 0, 1},
		{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
		{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
		{1, 0, 0, 0, 0, 0, 1, 0, 0, 1},
		{1, 0, 0, 0, 0, 0, 1, 0, 0, 1},
		{1, 0, 0, 0, 0, 0, 1, 0, 0, 1},
		{1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	}

	for y in 0 ..< height {
		for x in 0 ..< width {
			tiles[y * width + x] = map_data[y][x]
		}
	}

	return Map{width, height, tiles}
}

get_tile :: proc(m: ^Map, x, y: int) -> u8 {
	if x < 0 || x >= m.width || y < 0 || y >= m.height {
		return 1
	}

	return m.tiles[y * m.width + x]
}

is_wall :: proc(m: ^Map, x, y: f32) -> bool {
	tile_identity := get_tile(m, int(x), int(y))
	return tile_identity == 1 || tile_identity == 2
}

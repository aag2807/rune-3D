# RUNE ᛟ

A retro-style raycasting engine built in Odin using Raylib, featuring smooth first-person movement and weapon animations.

## Features

- **Classic Raycasting**: DDA algorithm implementation for fast wall rendering
- **Smooth Movement**: WASD movement with mouse look and collision detection
- **Weapon System**: Animated shooting with sprite-based weapon display
- **Beautiful Aesthetics**: Lotus-inspired color palette with teal and pink tones
- **Performance**: 60 FPS target with optimized rendering

## Screenshots

_Add screenshots of your game here_

## Controls

| Key/Input  | Action                              |
| ---------- | ----------------------------------- |
| W, A, S, D | Move forward, left, backward, right |
| Mouse      | Look around (pitch and yaw)         |
| Left Click | Shoot                               |
| Q          | Toggle cursor (for debugging)       |
| ESC        | Exit game                           |

## Getting Started

### Prerequisites

- [Odin compiler](https://odin-lang.org/) (latest version)
- [Raylib](https://www.raylib.com/) (included via Odin's vendor package)

### Installation

1. Clone the repository:

```bash
git clone <your-repo-url>
cd rune-raycaster
```

2. Make sure you have the required assets in the `assets/` folder:

   - `Idle.png` - Player idle sprite
   - `Shoot1.png`, `Shoot2.png`, `Shoot3.png`, `Shoot4.png` - Shooting animation frames

3. Build and run:

```bash
odin build . -out:rune.exe
./rune.exe
```

## Project Structure

```
├── main.odin              # Entry point and main game loop
├── game/                  # Core game logic
│   ├── game.odin         # Game state management
│   ├── player.odin       # Player struct and movement
│   └── map.odin          # Level data and collision detection
├── renderer/              # Rendering system
│   ├── raycaster.odin    # Main raycasting implementation
│   └── camera.odin       # Camera and FOV management
├── inputs/                # Input handling
│   └── input.odin        # Keyboard and mouse input
├── constants/             # Shared constants
│   └── colors.odin       # Color palette definitions
└── assets/               # Game assets (sprites, textures)
```

## Technical Details

### Raycasting Engine

- Uses the DDA (Digital Differential Analyzer) algorithm for efficient wall detection
- Supports different wall types with unique colors
- Implements proper distance calculation to prevent fisheye effect
- 120-degree field of view for immersive gameplay

### Animation System

- Frame-based sprite animation at 12 FPS
- Smooth transitions between idle and shooting states
- Precise timing control to prevent animation glitches

### Color Palette

Inspired by lotus flowers, featuring:

- **Lotus Pale Pink** (`#F1DCE5`) - Light tones
- **Lotus Soft Pink** (`#EA9CB5`) - Medium tones
- **Lotus Rose Pink** (`#BA7693`) - Accent colors
- **Lotus Bright Teal** (`#40948C`) - Environment
- **Lotus Deep Teal** (`#2D5754`) - Shadows

## Configuration

Key constants you can modify:

```odin
// In main.odin
SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600
TARGET_FPS :: 60

// In renderer/camera.odin
FOV :: math.PI * 0.66  // Field of view (120 degrees)

// In game/player.odin (via init)
move_speed: 5.0        // Player movement speed
sensitivity: 0.003     // Mouse sensitivity
```

## Development

### Adding New Levels

Edit the `map_data` array in `game/map.odin`:

- `0` = Empty space (walkable)
- `1` = Wall (teal colored)
- `2` = Alternative wall type

### Adding New Animations

1. Add new states to `PlayerState` enum in `game/player.odin`
2. Load sprites in `game/game.odin` init function
3. Handle rendering in `renderer/raycaster.odin` sprite rendering function

## Known Issues

- Textures are currently solid colors (planned enhancement)
- No sound system implemented yet
- Limited to single-level gameplay

## Roadmap

- [ ] Texture mapping for walls
- [ ] Sprite-based enemies/objects
- [ ] Audio system integration
- [ ] Multiple levels
- [ ] Improved lighting effects
- [ ] Minimap display

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

This project is open source. Feel free to use and modify as needed.

## Acknowledgments

- Built with [Odin](https://odin-lang.org/) programming language
- Graphics powered by [Raylib](https://www.raylib.com/)
- Inspired by classic games like Wolfenstein 3D and DOOM

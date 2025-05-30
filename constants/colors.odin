package constants

import rl "vendor:raylib"

// Light pinks and whites
LOTUS_PALE_PINK :: rl.Color{241, 220, 229, 255} // Very light pink/white
LOTUS_SOFT_PINK :: rl.Color{234, 156, 181, 255} // Medium soft pink
LOTUS_ROSE_PINK :: rl.Color{186, 118, 147, 255} // Deeper rose pink

// Teals and greens (background)
LOTUS_BRIGHT_TEAL :: rl.Color{64, 148, 140, 255} // Bright teal
LOTUS_DEEP_TEAL :: rl.Color{45, 87, 84, 255} // Deep teal/forest


// Wall color variations
WALL_LIGHT :: LOTUS_PALE_PINK
WALL_MEDIUM :: LOTUS_SOFT_PINK
WALL_DARK :: LOTUS_ROSE_PINK

// Environment colors
CEILING_COLOR :: LOTUS_DEEP_TEAL
FLOOR_COLOR :: LOTUS_BRIGHT_TEAL

// UI colors
CROSSHAIR_COLOR :: LOTUS_PALE_PINK
TEXT_COLOR :: LOTUS_SOFT_PINK

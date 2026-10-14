//-----------------------------------------------------------------------------
//	SCRATCHER CONFIG
//-----------------------------------------------------------------------------
//	Defaults for every oScratchCard. Each card copies these into its own
//	variables on Create, so individual cards can be tuned after creation
//	(e.g. card.brushRadius_ = 80) without touching the others.
//-----------------------------------------------------------------------------

// Brush radius in room units
#macro SCRATCH_BRUSH_RADIUS 48

// 0 = hard-edged brush, 1 = fully feathered from the centre out
#macro SCRATCH_BRUSH_SOFTNESS 0.35

// Distance between brush stamps along a stroke, as a fraction of the radius.
// Lower is smoother but stamps more often.
#macro SCRATCH_BRUSH_SPACING 0.25

// Size of the brush texture in pixels (scaled to the brush radius when stamped)
#macro SCRATCH_BRUSH_TEXTURE_SIZE 128

// Share of the cover (0-1) that has to be scratched off before the rest is cleared automatically
#macro SCRATCH_REVEAL_THRESHOLD 0.7

// Seconds the leftover cover takes to fade out once the threshold is reached
#macro SCRATCH_REVEAL_FADE_TIME 0.35

// Coverage grid cell size in mask pixels. Smaller is more accurate but costs more per stamp.
#macro SCRATCH_GRID_CELL 16

// Cover pixels with less alpha than this (0-1) don't count towards progress
#macro SCRATCH_ALPHA_CUTOFF 0.5

// How dark the leftover cover gets along the edge of a scratch (0 = off), and how wide that edge is in mask pixels
#macro SCRATCH_EDGE_SHADE 0.35
#macro SCRATCH_EDGE_WIDTH 3

// Pointer position in room space. The display scaler's version corrects for the
// device pixel ratio on HTML5; use mouse_x / mouse_y in projects without it.
#macro SCRATCH_POINTER_X display_mouse_world_x()
#macro SCRATCH_POINTER_Y display_mouse_world_y()

/// @description Init
//-----------------------------------------------------------------------------
//	SCRATCH CARD
//	Draws a cover sprite that the player scratches away with the pointer, with
//	an optional reveal sprite underneath it.
//
//	- Mask: a surface the size of the card. The brush stamps white into it and
//	  shd_scratch_reveal erases the cover wherever it's white.
//	- Progress: a coarse grid over the cover's opaque pixels. Brush stamps tick
//	  cells off, so progress costs nothing to read and never touches the GPU.
//	  Once revealThreshold_ of the cells are gone the rest of the cover fades out.
//
//	Create with scratch_card_create(), or create an instance and call setup().
//	Set the scale before setup(); the mask is sized from it.
//-----------------------------------------------------------------------------

// SETTINGS (per card, safe to change after creation):
//-----------------------------------------------------------------------------
brushRadius_		= SCRATCH_BRUSH_RADIUS;			// Room units
revealThreshold_	= SCRATCH_REVEAL_THRESHOLD;		// 0-1
enabled_			= true;							// False ignores input
flakes_				= true;							// Spray particles while scratching
flakeColour_		= make_colour_rgb(196, 202, 212);

onReveal_			= undefined;	// function() - called once the threshold is reached
onScratch_			= undefined;	// function(progress) - called when progress changes

// STATE:
//-----------------------------------------------------------------------------
coverSprite_	= -1;
revealSprite_	= -1;

maskSurface_	= -1;
maskBuffer_		= -1;		// Copy of the mask so it can be rebuilt if the surface is lost
maskWidth_		= 0;
maskHeight_		= 0;

grid_			= [];		// Per cell: -1 = no cover there, 0 = covered, 1 = scratched
gridCols_		= 0;
gridRows_		= 0;
cellsTotal_		= 0;
cellsCleared_	= 0;
progress_		= 0;		// 0-1, share of the cover scratched off

revealed_		= false;
coverAlpha_		= 1;		// Fades to 0 after the reveal
scratching_		= false;
lastX_			= 0;		// Last stamp position, in mask pixels
lastY_			= 0;

brushSprite_	= scratch_brush_sprite();

uMask_			= shader_get_sampler_index(shd_scratch_reveal, "u_mask");
uMaskTransform_	= shader_get_uniform(shd_scratch_reveal, "u_maskTransform");
uEdgeOffset_	= shader_get_uniform(shd_scratch_reveal, "u_edgeOffset");
uEdgeShade_		= shader_get_uniform(shd_scratch_reveal, "u_edgeShade");

// Flakes of cover that come off as it's scratched
flakeSystem_ = part_system_create();
part_system_depth(flakeSystem_, depth - 1);
flakeType_ = part_type_create();
part_type_shape(flakeType_, pt_shape_square);
part_type_size(flakeType_, 0.04, 0.09, -0.001, 0);
part_type_orientation(flakeType_, 0, 360, 6, 0, false);
part_type_speed(flakeType_, 1, 4, -0.05, 0);
part_type_direction(flakeType_, 0, 360, 0, 0);
part_type_gravity(flakeType_, 0.35, 270);
part_type_alpha2(flakeType_, 1, 0);
part_type_life(flakeType_, 20, 40);

#region METHODS

/// Sets the sprites and builds the mask and coverage grid. Call again to swap the cover.
setup = function(_cover, _reveal = -1) {
	coverSprite_ = _cover;
	revealSprite_ = _reveal;
	sprite_index = _cover;		// So bbox_* and collision functions match the card
	image_index = 0;
	image_speed = 0;

	maskWidth_ = max(1, ceil(sprite_get_width(_cover) * abs(image_xscale)));
	maskHeight_ = max(1, ceil(sprite_get_height(_cover) * abs(image_yscale)));

	if (surface_exists(maskSurface_)) surface_free(maskSurface_);
	if (buffer_exists(maskBuffer_)) buffer_delete(maskBuffer_);
	maskSurface_ = surface_create(maskWidth_, maskHeight_);
	maskBuffer_ = buffer_create(maskWidth_ * maskHeight_ * 4, buffer_fixed, 1);

	build_grid();
	reset();
}

/// Swaps the sprite underneath without touching the cover or the scratches
set_reveal = function(_reveal) {
	revealSprite_ = _reveal;
}

/// Puts the whole cover back
reset = function() {
	ensure_mask();
	surface_set_target(maskSurface_);
	draw_clear(c_black);
	surface_reset_target();
	save_mask();

	for (var i = 0; i < array_length(grid_); i++) {
		if (grid_[i] == 1) grid_[i] = 0;
	}
	cellsCleared_ = 0;
	progress_ = 0;
	revealed_ = false;
	coverAlpha_ = 1;
	scratching_ = false;
}

/// Clears whatever is left of the cover (fades it out)
reveal = function() {
	if (revealed_) return;
	revealed_ = true;
	scratching_ = false;
	progress_ = 1;
	save_mask();
	if (!is_undefined(onReveal_)) onReveal_();
}

get_progress = function() {
	return progress_;
}

is_revealed = function() {
	return revealed_;
}

/// Room position of the mask's top-left pixel
mask_origin_x = function() {
	return x - sprite_get_xoffset(coverSprite_) * image_xscale;
}

mask_origin_y = function() {
	return y - sprite_get_yoffset(coverSprite_) * image_yscale;
}

/// Recreates the mask surface from its buffer copy if it has been lost
ensure_mask = function() {
	if (surface_exists(maskSurface_)) return;
	maskSurface_ = surface_create(maskWidth_, maskHeight_);
	buffer_set_surface(maskBuffer_, maskSurface_, 0);
}

/// Copies the mask into its buffer. Reading a surface back stalls the GPU,
/// so this only runs at the end of a stroke.
save_mask = function() {
	if (surface_exists(maskSurface_)) buffer_get_surface(maskBuffer_, maskSurface_, 0);
}

/// Splits the cover into SCRATCH_GRID_CELL cells and marks the ones that have
/// cover in them. Transparent corners or holes never count towards progress.
build_grid = function() {
	// Draw the cover at mask size with blending off, so the surface holds its exact alpha
	var _surf = surface_create(maskWidth_, maskHeight_);
	surface_set_target(_surf);
	draw_clear_alpha(c_black, 0);
	gpu_set_blendenable(false);
	draw_sprite_ext(coverSprite_, 0,
		sprite_get_xoffset(coverSprite_) * image_xscale, sprite_get_yoffset(coverSprite_) * image_yscale,
		image_xscale, image_yscale, 0, c_white, 1);
	gpu_set_blendenable(true);
	surface_reset_target();

	var _buf = buffer_create(maskWidth_ * maskHeight_ * 4, buffer_fixed, 1);
	buffer_get_surface(_buf, _surf, 0);
	surface_free(_surf);

	var _cell = SCRATCH_GRID_CELL;
	var _cutoff = SCRATCH_ALPHA_CUTOFF * 255;
	gridCols_ = ceil(maskWidth_ / _cell);
	gridRows_ = ceil(maskHeight_ / _cell);
	grid_ = array_create(gridCols_ * gridRows_, -1);
	cellsTotal_ = 0;

	for (var _row = 0; _row < gridRows_; _row++) {
		var _py = min(floor((_row + 0.5) * _cell), maskHeight_ - 1);
		for (var _col = 0; _col < gridCols_; _col++) {
			var _px = min(floor((_col + 0.5) * _cell), maskWidth_ - 1);
			// Alpha is the 4th byte on every target (RGBA on HTML5, BGRA on desktop)
			if (buffer_peek(_buf, (_py * maskWidth_ + _px) * 4 + 3, buffer_u8) >= _cutoff) {
				grid_[_row * gridCols_ + _col] = 0;
				cellsTotal_++;
			}
		}
	}
	buffer_delete(_buf);
}

/// Stamps the brush along a line in mask pixels and ticks off the cells it covers
stamp_line = function(_x1, _y1, _x2, _y2) {
	var _dist = point_distance(_x1, _y1, _x2, _y2);
	var _spacing = max(1, brushRadius_ * SCRATCH_BRUSH_SPACING);
	var _count = max(1, ceil(_dist / _spacing));
	var _scale = brushRadius_ / (sprite_get_width(brushSprite_) / 2);
	var _cleared = 0;

	ensure_mask();
	surface_set_target(maskSurface_);
	gpu_set_colourwriteenable(true, true, true, false);		// Only the red channel is read
	for (var i = 1; i <= _count; i++) {
		var _t = i / _count;
		var _sx = lerp(_x1, _x2, _t);
		var _sy = lerp(_y1, _y2, _t);
		draw_sprite_ext(brushSprite_, 0, _sx, _sy, _scale, _scale, 0, c_white, 1);
		_cleared += clear_cells(_sx, _sy);
	}
	gpu_set_colourwriteenable(true, true, true, true);
	surface_reset_target();

	if (_cleared > 0) {
		if (flakes_) {
			part_particles_create_colour(flakeSystem_, mask_origin_x() + _x2, mask_origin_y() + _y2,
				flakeType_, flakeColour_, min(_cleared, 4));
		}
		progress_ = (cellsTotal_ > 0) ? cellsCleared_ / cellsTotal_ : 1;
		if (!is_undefined(onScratch_)) onScratch_(progress_);
		if (progress_ >= revealThreshold_) reveal();
	}
}

/// Marks covered cells inside the brush's solid core as scratched. Returns how many it cleared.
clear_cells = function(_sx, _sy) {
	var _cell = SCRATCH_GRID_CELL;
	var _r = brushRadius_ * (1 - SCRATCH_BRUSH_SOFTNESS * 0.5);
	var _col1 = max(0, floor((_sx - _r) / _cell));
	var _col2 = min(gridCols_ - 1, floor((_sx + _r) / _cell));
	var _row1 = max(0, floor((_sy - _r) / _cell));
	var _row2 = min(gridRows_ - 1, floor((_sy + _r) / _cell));
	var _r2 = _r * _r;
	var _cleared = 0;

	for (var _row = _row1; _row <= _row2; _row++) {
		var _dy = (_row + 0.5) * _cell - _sy;
		for (var _col = _col1; _col <= _col2; _col++) {
			var _i = _row * gridCols_ + _col;
			if (grid_[_i] != 0) continue;
			var _dx = (_col + 0.5) * _cell - _sx;
			if (_dx * _dx + _dy * _dy <= _r2) {
				grid_[_i] = 1;
				_cleared++;
			}
		}
	}
	cellsCleared_ += _cleared;
	return _cleared;
}

/// Draws the mask surface at _x, _y (for debugging / showing how it works)
draw_debug_mask = function(_x, _y, _scale) {
	if (!surface_exists(maskSurface_)) return;
	// Blending off shows the mask exactly as stored; alpha writes off so the
	// canvas underneath can't turn see-through on HTML5
	gpu_set_blendenable(false);
	gpu_set_colourwriteenable(true, true, true, false);
	draw_surface_ext(maskSurface_, _x, _y, _scale, _scale, 0, c_white, 1);
	gpu_set_colourwriteenable(true, true, true, true);
	gpu_set_blendenable(true);
}

/// Draws the coverage grid at _x, _y: scratched cells green, covered cells grey,
/// cells with no cover in them left out
draw_debug_grid = function(_x, _y, _scale) {
	var _cs = SCRATCH_GRID_CELL * _scale;
	var _colCleared = make_colour_rgb(80, 220, 140);
	var _colCovered = make_colour_rgb(70, 76, 90);
	draw_set_colour(c_black);
	draw_rectangle(_x, _y, _x + maskWidth_ * _scale, _y + maskHeight_ * _scale, false);
	for (var _row = 0; _row < gridRows_; _row++) {
		for (var _col = 0; _col < gridCols_; _col++) {
			var _state = grid_[_row * gridCols_ + _col];
			if (_state < 0) continue;
			draw_set_colour(_state == 1 ? _colCleared : _colCovered);
			var _cx = _x + _col * _cs;
			var _cy = _y + _row * _cs;
			draw_rectangle(_cx + 1, _cy + 1, _cx + _cs - 1, _cy + _cs - 1, false);
		}
	}
	draw_set_colour(c_white);
}

#endregion

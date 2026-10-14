///
/// @function				scratch_card_create(_x, _y, _depth, _cover, [_reveal], [_scale])
/// @description            Creates a scratch card. _cover is the sprite the player scratches
///							away; _reveal (optional) is drawn underneath it with the same
///							position, origin and scale. Leave _reveal out to scratch a sprite
///							away over whatever is already behind it.
///
/// @param {Real}			[_x] - The x position in the room.
/// @param {Real}			[_y] - The y position in the room.
/// @param {Real}			[_depth] - The card's depth.
/// @param {Asset.GMSprite}	[_cover] - The sprite that gets scratched away.
/// @param {Asset.GMSprite}	[_reveal] - The sprite underneath the cover, or -1 for none.
/// @param {Real}			[_scale] - Draw scale for both sprites (default 1).
/// @returns {Id.Instance}	The oScratchCard instance.
///
function scratch_card_create(_x, _y, _depth, _cover, _reveal = -1, _scale = 1) {
	var _card = instance_create_depth(_x, _y, _depth, oScratchCard);
	with (_card) {
		image_xscale = _scale;
		image_yscale = _scale;
		setup(_cover, _reveal);
	}
	return _card;
}

///
/// @function				scratch_brush_sprite()
/// @description            Returns the round, soft-edged brush stamped into scratch masks.
///							It's built once and shared by every card.
///
/// @returns {Asset.GMSprite}
///
function scratch_brush_sprite() {
	static _sprite = -1;
	if (sprite_exists(_sprite)) return _sprite;

	var _size = SCRATCH_BRUSH_TEXTURE_SIZE;
	var _radius = _size / 2;
	var _feather = max(1, _radius * SCRATCH_BRUSH_SOFTNESS);
	var _surf = surface_create(_size, _size);

	surface_set_target(_surf);
	draw_clear_alpha(c_white, 0);

	// Blending off: each ring overwrites the one before it, so its alpha is exactly the falloff value
	gpu_set_blendenable(false);
	draw_set_circle_precision(64);
	draw_set_colour(c_white);
	for (var _r = _radius; _r > 0; _r--) {
		var _t = clamp((_radius - _r) / _feather, 0, 1);
		draw_set_alpha(_t * _t * (3 - 2 * _t));	// Smoothstep
		draw_circle(_radius, _radius, _r, false);
	}
	draw_set_alpha(1);
	gpu_set_blendenable(true);
	surface_reset_target();

	_sprite = sprite_create_from_surface(_surf, 0, 0, _size, _size, false, false, _radius, _radius);
	surface_free(_surf);
	return _sprite;
}

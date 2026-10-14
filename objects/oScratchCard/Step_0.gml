/// @description Scratch Input

// Fade out what's left of the cover after the reveal
if (revealed_ && coverAlpha_ > 0) {
	coverAlpha_ = max(0, coverAlpha_ - 1 / (SCRATCH_REVEAL_FADE_TIME * game_get_speed(gamespeed_fps)));
}

if (!enabled_ || revealed_ || !sprite_exists(coverSprite_)) {
	scratching_ = false;
	exit;
}

if (mouse_check_button(mb_left)) {
	var _mx = SCRATCH_POINTER_X - mask_origin_x();
	var _my = SCRATCH_POINTER_Y - mask_origin_y();

	if (!scratching_) {
		// New stroke: a single stamp, no line from where the last stroke ended
		scratching_ = true;
		stamp_line(_mx, _my, _mx, _my);
	}
	else if (point_distance(lastX_, lastY_, _mx, _my) >= 1) {
		stamp_line(lastX_, lastY_, _mx, _my);
	}
	lastX_ = _mx;
	lastY_ = _my;
}
else if (scratching_) {
	scratching_ = false;
	save_mask();
}

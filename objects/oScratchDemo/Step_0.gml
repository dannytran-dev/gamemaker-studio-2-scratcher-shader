/// @description Input

shownProgress_ = lerp(shownProgress_, card_.get_progress(), 0.25);

// Keys: N new card, R reset, M mask view, D display scaler details
if (keyboard_check_pressed(ord("N"))) new_card();
if (keyboard_check_pressed(ord("R"))) card_.reset();
if (keyboard_check_pressed(ord("M"))) toggle_mask_view();
if (keyboard_check_pressed(ord("D"))) display_scaler_show_overlay(!oDisplayScaler.showOverlay_);

// On-screen buttons (hit-tested against the DPR-corrected GUI mouse)
if (mouse_check_button_pressed(mb_left)) {
	var _mx = display_mouse_gui_x();
	var _my = display_mouse_gui_y();
	for (var i = 0; i < array_length(buttons_); i++) {
		var _r = buttons_[i].rect;
		if (point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3])) {
			buttons_[i].action();
			break;
		}
	}
}

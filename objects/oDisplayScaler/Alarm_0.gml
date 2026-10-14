/// @description Check/Update Resolution

if (has_screen_changed()) {
	refresh();
}

alarm[0] = DISPLAY_SCALER_POLL_FRAMES;

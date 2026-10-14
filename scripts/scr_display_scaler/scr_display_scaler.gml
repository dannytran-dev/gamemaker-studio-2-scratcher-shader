///
/// @function				display_scaler_refresh()
/// @description            Forces the display to be re-fitted to the current browser/window size.
///
/// @returns {undefined}
///
function display_scaler_refresh() {
	with (oDisplayScaler) {
		refresh();
	}
}

///
/// @function				display_scaler_set_zoom(_zoom)
/// @description            Zooms the world camera. The GUI layer is not affected.
///
/// @param {Real}			[_zoom] - 1 = default, >1 zooms in, <1 zooms out.
/// @returns {undefined}
///
function display_scaler_set_zoom(_zoom) {
	with (oDisplayScaler) {
		set_zoom(_zoom);
	}
}

///
/// @function				display_scaler_get_zoom()
/// @description            Returns the current world camera zoom.
///
/// @returns {Real}
///
function display_scaler_get_zoom() {
	return instance_exists(oDisplayScaler) ? oDisplayScaler.zoom_ : 1;
}

///
/// @function				display_scaler_set_focus(_x, _y)
/// @description            Centres the world camera on a room position.
///
/// @param {Real}			[_x] - The x position in the room.
/// @param {Real}			[_y] - The y position in the room.
/// @returns {undefined}
///
function display_scaler_set_focus(_x, _y) {
	with (oDisplayScaler) {
		set_focus(_x, _y);
	}
}

///
/// @function				display_scaler_set_mode(_mode)
/// @description            Changes how the visible area follows the screen's aspect ratio
///							and re-fits immediately (fires DisplayScalerEvent.RESIZE).
///
///							Pass a DisplayScaleMode value, or your own function for a custom
///							mode: function(canvasWidth, canvasHeight) -> [viewWidth, viewHeight]
///							in game units, e.g. a fixed 4:3 view:
///								display_scaler_set_mode(function(_cw, _ch) { return [1440, 1080]; });
///
/// @param {Real|Function}	[_mode] - A DisplayScaleMode value or a custom sizing function.
/// @returns {undefined}
///
function display_scaler_set_mode(_mode) {
	with (oDisplayScaler) {
		set_mode(_mode);
	}
}

///
/// @function				display_scaler_get_mode()
/// @description            Returns the current scale mode (DisplayScaleMode value or custom function).
///
/// @returns {Real|Function}
///
function display_scaler_get_mode() {
	return instance_exists(oDisplayScaler) ? oDisplayScaler.mode_ : DISPLAY_SCALER_DEFAULT_MODE;
}

///
/// @function				display_scaler_get_info()
/// @description            Returns a snapshot of the current display state, or undefined if
///							the scaler hasn't fitted the display yet. Fields:
///							mode, modeName, screenWidth/Height (CSS px), canvasWidth/Height
///							(physical px), pixelRatio, viewWidth/Height (game units),
///							guiWidth/Height, cameraX/Y/Width/Height, zoom.
///
/// @returns {Struct|Undefined}
///
function display_scaler_get_info() {
	if (!instance_exists(oDisplayScaler) || oDisplayScaler.canvasWidth_ <= 0) return undefined;
	return oDisplayScaler.get_info();
}

///
/// @function				display_scaler_show_overlay(_enabled)
/// @description            Shows/hides the resolution debug overlay.
///
/// @param {Bool}			[_enabled] - True to show, false to hide.
/// @returns {undefined}
///
function display_scaler_show_overlay(_enabled) {
	with (oDisplayScaler) {
		showOverlay_ = _enabled;
	}
}

///
/// @function				display_gui_anchor_x(_x, _anchor)
/// @description            Converts an x position authored against BASE_WIDTH into the current GUI
///							width, keeping the same distance from the anchored edge (or centre).
///
/// @param {Real}			[_x] - The x position in BASE_WIDTH space.
/// @param {Real}			[_anchor] - A DisplayAnchor value.
/// @returns {Real}			Returns the GUI x position.
///
function display_gui_anchor_x(_x, _anchor) {
	var _gw = display_get_gui_width();
	switch (_anchor mod 3) {
		case 0:  return _x;										// Left
		case 1:  return (_gw / 2) - ((BASE_WIDTH / 2) - _x);	// Center
		default: return _gw - (BASE_WIDTH - _x);				// Right
	}
}

///
/// @function				display_gui_anchor_y(_y, _anchor)
/// @description            Converts a y position authored against BASE_HEIGHT into the current GUI
///							height, keeping the same distance from the anchored edge (or centre).
///
/// @param {Real}			[_y] - The y position in BASE_HEIGHT space.
/// @param {Real}			[_anchor] - A DisplayAnchor value.
/// @returns {Real}			Returns the GUI y position.
///
function display_gui_anchor_y(_y, _anchor) {
	var _gh = display_get_gui_height();
	switch (_anchor div 3) {
		case 0:  return _y;										// Top
		case 1:  return (_gh / 2) - ((BASE_HEIGHT / 2) - _y);	// Middle
		default: return _gh - (BASE_HEIGHT - _y);				// Bottom
	}
}

///
/// @function				display_mouse_gui_x()
/// @description            Mouse x in GUI space, corrected for the device pixel ratio.
///							(The HTML5 runner maps CSS-pixel mouse events against the
///							physical-pixel canvas, so it under-reports by the DPR.)
///
/// @returns {Real}
///
function display_mouse_gui_x() {
	return device_mouse_x_to_gui(0) * global.DISPLAY_SCALEX;
}

///
/// @function				display_mouse_gui_y()
/// @description            Mouse y in GUI space, corrected for the device pixel ratio.
///
/// @returns {Real}
///
function display_mouse_gui_y() {
	return device_mouse_y_to_gui(0) * global.DISPLAY_SCALEY;
}

///
/// @function				display_mouse_world_x()
/// @description            Mouse x in room space, corrected for the device pixel ratio.
///
/// @returns {Real}
///
function display_mouse_world_x() {
	return display_gui_to_world_x(display_mouse_gui_x());
}

///
/// @function				display_mouse_world_y()
/// @description            Mouse y in room space, corrected for the device pixel ratio.
///
/// @returns {Real}
///
function display_mouse_world_y() {
	return display_gui_to_world_y(display_mouse_gui_y());
}

///
/// @function				display_world_to_gui_x(_x)
/// @description            Converts a room x position to GUI space (e.g. health bars over enemies).
///
/// @param {Real}			[_x] - The x position in the room.
/// @returns {Real}
///
function display_world_to_gui_x(_x) {
	var _cam = view_camera[0];
	return ((_x - camera_get_view_x(_cam)) / camera_get_view_width(_cam)) * display_get_gui_width();
}

///
/// @function				display_world_to_gui_y(_y)
/// @description            Converts a room y position to GUI space.
///
/// @param {Real}			[_y] - The y position in the room.
/// @returns {Real}
///
function display_world_to_gui_y(_y) {
	var _cam = view_camera[0];
	return ((_y - camera_get_view_y(_cam)) / camera_get_view_height(_cam)) * display_get_gui_height();
}

///
/// @function				display_gui_to_world_x(_x)
/// @description            Converts a GUI x position to room space.
///
/// @param {Real}			[_x] - The x position in GUI space.
/// @returns {Real}
///
function display_gui_to_world_x(_x) {
	var _cam = view_camera[0];
	return camera_get_view_x(_cam) + (_x / display_get_gui_width()) * camera_get_view_width(_cam);
}

///
/// @function				display_gui_to_world_y(_y)
/// @description            Converts a GUI y position to room space.
///
/// @param {Real}			[_y] - The y position in GUI space.
/// @returns {Real}
///
function display_gui_to_world_y(_y) {
	var _cam = view_camera[0];
	return camera_get_view_y(_cam) + (_y / display_get_gui_height()) * camera_get_view_height(_cam);
}

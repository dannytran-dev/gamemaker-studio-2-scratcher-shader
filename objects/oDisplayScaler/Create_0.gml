/// @description Init
//-----------------------------------------------------------------------------
//	DISPLAY SCALER
//	Fits the game to any browser/window size without stretching or letterboxing.
//	The scale mode decides which axis is locked to the base resolution; the
//	other follows the screen's aspect ratio. On HTML5 the canvas is rendered at
//	the device's native pixel density so it stays sharp on HiDPI screens.
//
//	Drop one instance into the first room. It is persistent and re-applies
//	itself on every room start.
//
//	Other systems hook in through display_scaler_subscribe() (see
//	scr_display_scaler_events) instead of being called from here.
//-----------------------------------------------------------------------------

// Only one scaler may exist
if (instance_number(oDisplayScaler) > 1) {
	instance_destroy();
	exit;
}

// The JS extension is the only caller of this script; referencing it here stops
// "Automatically remove unused assets" from stripping it out of the build
jsCallback_		= gmcallback_display_scaler_resize;

// STATE:
//-----------------------------------------------------------------------------
screenWidth_	= 0;			// Last browser/window size we fitted to (CSS px on HTML5)
screenHeight_	= 0;
canvasWidth_	= 0;			// Canvas backing store size (physical px)
canvasHeight_	= 0;
pixelRatio_		= 1;			// Device pixel ratio reported by the browser
viewWidth_		= BASE_WIDTH;	// Visible area in game units, before zoom
viewHeight_		= BASE_HEIGHT;
subPixelScale_	= DISPLAY_SCALER_SURFACE_SCALE;

mode_			= DISPLAY_SCALER_DEFAULT_MODE;
zoom_			= 1;
focusX_			= BASE_WIDTH / 2;	// Room position the camera is centred on
focusY_			= BASE_HEIGHT / 2;

showOverlay_	= false;		// Resolution readout (display_scaler_show_overlay)
font_			= fntDefault;

// CAMERA:
//-----------------------------------------------------------------------------
camera_ = camera_create_view(0, 0, BASE_WIDTH, BASE_HEIGHT);

#region METHODS

/// Assigns our camera to view 0 of the current room
attach_view = function() {
	view_enabled = true;
	view_set_visible(0, true);
	view_set_camera(0, camera_);
}

/// Returns true if the browser/window has changed size since the last refresh
has_screen_changed = function() {
	if (IS_BROWSER) {
		// Pixel ratio changes on its own when the window moves to a screen with a different density
		return (browser_width != screenWidth_ || browser_height != screenHeight_
			|| display_scaler_js_pixel_ratio() != pixelRatio_);
	}
	return (window_get_width() != screenWidth_ || window_get_height() != screenHeight_);
}

/// Re-fits the display to the current browser/window size
refresh = function() {
	if (IS_BROWSER) {
		screenWidth_ = browser_width;
		screenHeight_ = browser_height;
		// JS works out the DPR-scaled canvas size, then calls back into apply_canvas_size()
		// through gmcallback_display_scaler_resize
		display_scaler_js_resize(screenWidth_, screenHeight_);
	}
	else {
		screenWidth_ = window_get_width();
		screenHeight_ = window_get_height();
		apply_canvas_size(screenWidth_, screenHeight_, 1);
	}
}

/// Works out the visible area in game units for a _cw x _ch canvas using the current scale mode
compute_view_size = function(_cw, _ch) {
	var _aspect = _cw / _ch;

	// Custom mode: function(canvasWidth, canvasHeight) -> [viewWidth, viewHeight]
	if (!is_numeric(mode_)) {
		var _size = mode_(_cw, _ch);
		viewWidth_ = round(_size[0]);
		viewHeight_ = round(_size[1]);
		return;
	}

	var _lockHeight = true;
	switch (mode_) {
		case DisplayScaleMode.LOCK_WIDTH:
			_lockHeight = false;
			break;
		case DisplayScaleMode.EXPAND:
			// Wider than the base aspect: lock height (bleed sides). Taller: lock width (bleed top/bottom)
			_lockHeight = (_aspect >= BASE_WIDTH / BASE_HEIGHT);
			break;
	}

	if (_lockHeight) {
		viewHeight_ = BASE_HEIGHT;
		viewWidth_ = round(BASE_HEIGHT * _aspect);
	}
	else {
		viewWidth_ = BASE_WIDTH;
		viewHeight_ = round(BASE_WIDTH / _aspect);
	}
}

/// Resizes the canvas, viewport, application surface and GUI layer for a
/// canvas that is _cw x _ch physical pixels
apply_canvas_size = function(_cw, _ch, _dpr) {
	// Minimised window / hidden iframe
	if (_cw <= 0 || _ch <= 0) return;

	canvasWidth_ = _cw;
	canvasHeight_ = _ch;
	pixelRatio_ = _dpr;

	// Size the <canvas> backing store to physical pixels and centre it in the page
	if (IS_BROWSER) {
		window_set_size(_cw, _ch);
		window_center();
	}

	compute_view_size(_cw, _ch);

	var _surfW = viewWidth_ * subPixelScale_;
	var _surfH = viewHeight_ * subPixelScale_;
	view_set_wport(0, _surfW);
	view_set_hport(0, _surfH);
	surface_resize(application_surface, _surfW, _surfH);
	display_set_gui_size(viewWidth_, viewHeight_);

	// The HTML5 runner maps CSS-pixel mouse events against the physical-pixel canvas,
	// so GUI mouse coordinates come out too small by exactly the DPR
	global.DISPLAY_SCALEX = _dpr;
	global.DISPLAY_SCALEY = _dpr;

	update_camera();
	__display_scaler_emit(DisplayScalerEvent.RESIZE);
}

/// Applies zoom + focus to the camera
update_camera = function() {
	var _camW = viewWidth_ / zoom_;
	var _camH = viewHeight_ / zoom_;
	camera_set_view_size(camera_, _camW, _camH);
	camera_set_view_pos(camera_, focusX_ - (_camW / 2), focusY_ - (_camH / 2));
	__display_scaler_emit(DisplayScalerEvent.CAMERA);
}

set_zoom = function(_zoom) {
	zoom_ = clamp(_zoom, DISPLAY_SCALER_ZOOM_MIN, DISPLAY_SCALER_ZOOM_MAX);
	update_camera();
}

set_focus = function(_x, _y) {
	focusX_ = _x;
	focusY_ = _y;
	update_camera();
}

set_mode = function(_mode) {
	mode_ = _mode;
	refresh();
}

/// Readable name of the current scale mode
get_mode_name = function() {
	if (!is_numeric(mode_)) return "CUSTOM";
	switch (mode_) {
		case DisplayScaleMode.LOCK_HEIGHT:	return "LOCK_HEIGHT";
		case DisplayScaleMode.LOCK_WIDTH:	return "LOCK_WIDTH";
		case DisplayScaleMode.EXPAND:		return "EXPAND";
	}
	return "UNKNOWN";
}

/// Snapshot of the current display state (see display_scaler_get_info)
get_info = function() {
	return {
		mode:			mode_,
		modeName:		get_mode_name(),
		screenWidth:	screenWidth_,
		screenHeight:	screenHeight_,
		canvasWidth:	canvasWidth_,
		canvasHeight:	canvasHeight_,
		pixelRatio:		pixelRatio_,
		viewWidth:		viewWidth_,
		viewHeight:		viewHeight_,
		guiWidth:		display_get_gui_width(),
		guiHeight:		display_get_gui_height(),
		cameraX:		camera_get_view_x(camera_),
		cameraY:		camera_get_view_y(camera_),
		cameraWidth:	camera_get_view_width(camera_),
		cameraHeight:	camera_get_view_height(camera_),
		zoom:			zoom_,
	};
}

#endregion

// APPLY:
//-----------------------------------------------------------------------------
attach_view();
refresh();
alarm[0] = DISPLAY_SCALER_POLL_FRAMES;

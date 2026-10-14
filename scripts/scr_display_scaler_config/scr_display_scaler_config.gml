//-----------------------------------------------------------------------------
//	DISPLAY SCALER CONFIG
//-----------------------------------------------------------------------------
//	BASE_WIDTH x BASE_HEIGHT is the resolution the game is authored at.
//	The scale mode decides which axis stays fixed and which one grows or
//	shrinks with the screen's aspect ratio. Keep important content inside the
//	BASE_WIDTH x BASE_HEIGHT "safe area" and treat the rest as bleed.
//-----------------------------------------------------------------------------

#macro BASE_WIDTH 1920
#macro BASE_HEIGHT 1080

#macro IS_BROWSER (os_browser != browser_not_a_browser)

// How often (in frames) the manager polls for a browser/window size change
#macro DISPLAY_SCALER_POLL_FRAMES 10

// Application surface resolution relative to the view (e.g. 2 renders the world at twice
// the view size for extra detail on HiDPI screens, at a fill-rate cost)
#macro DISPLAY_SCALER_SURFACE_SCALE 1

// World camera zoom limits
#macro DISPLAY_SCALER_ZOOM_MIN 0.5
#macro DISPLAY_SCALER_ZOOM_MAX 3.0

// Scale mode used at startup (a DisplayScaleMode value or a custom function, see display_scaler_set_mode)
#macro DISPLAY_SCALER_DEFAULT_MODE DisplayScaleMode.LOCK_HEIGHT

// How the visible area (in game units) is derived from the screen's aspect ratio
enum DisplayScaleMode
{
	LOCK_HEIGHT,	// Height = BASE_HEIGHT, width follows the aspect ratio (bleed left/right)
	LOCK_WIDTH,		// Width = BASE_WIDTH, height follows the aspect ratio (bleed top/bottom)
	EXPAND,			// The whole safe area is always visible; bleed on whichever axis has spare room
	__COUNT
}

// Events other systems can subscribe to with display_scaler_subscribe()
enum DisplayScalerEvent
{
	RESIZE,			// Canvas / view / GUI size changed (resize, orientation change, scale mode change)
	CAMERA,			// Camera view rectangle changed (resize, zoom, focus)
	__COUNT
}

// Anchor points for GUI elements authored in BASE_WIDTH x BASE_HEIGHT space
// (column = anchor mod 3, row = anchor div 3)
enum DisplayAnchor
{
	TOPLEFT,
	TOPCENTER,
	TOPRIGHT,
	MIDDLELEFT,
	MIDDLECENTER,
	MIDDLERIGHT,
	BOTTOMLEFT,
	BOTTOMCENTER,
	BOTTOMRIGHT
}

// Device pixel ratio correction for GUI mouse coordinates (set by the scaler)
global.DISPLAY_SCALEX = 1;
global.DISPLAY_SCALEY = 1;

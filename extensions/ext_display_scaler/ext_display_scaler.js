///
/// @function				display_scaler_js_resize(targetWidth, targetHeight)
/// @description            Resizes the GameMaker canvas to fill the target CSS size at the device's
///							native pixel density, so the game stays sharp on HiDPI / Retina screens.
///
///							1. Works out the physical pixel size of the target area (CSS px * DPR).
///							2. Hands that size back to GML (gmcallback_display_scaler_resize), which
///							   resizes the canvas backing store, view, application surface and GUI.
///							3. Shrinks the canvas back down to the target size with CSS.
///
/// @param {number}         [targetWidth] - The width to fill, in CSS pixels (browser_width).
/// @param {number}         [targetHeight] - The height to fill, in CSS pixels (browser_height).
/// @returns {void}
///
function display_scaler_js_resize(targetWidth, targetHeight) {
    var pixelScale = display_scaler_js_pixel_ratio();

    var canvasWidth = Math.round(targetWidth * pixelScale);
    var canvasHeight = Math.round(targetHeight * pixelScale);

    // Let GML resize the canvas backing store and rebuild the view/GUI.
    // Scripts prefixed with gmcallback_ keep their name in obfuscated builds, so they can be called from JS.
    if (typeof gml_Script_gmcallback_display_scaler_resize === "function") {
        var payload = JSON.stringify({ w: canvasWidth, h: canvasHeight, dpr: pixelScale });
        gml_Script_gmcallback_display_scaler_resize(null, null, payload);
    }

    // Scale the oversized canvas back down with CSS
    if (pixelScale != 1) {
        canvas.style.width = (canvasWidth / pixelScale) + "px";
        canvas.style.height = (canvasHeight / pixelScale) + "px";
    } else {
        canvas.style.width = "";
        canvas.style.height = "";
    }

    // Canvas 2D fallback renderer needs its transform scaled to match (WebGL has no scale())
    if (typeof g_CurrentGraphics.scale === "function")
        g_CurrentGraphics.scale(pixelScale, pixelScale);
}

///
/// @function				display_scaler_js_pixel_ratio()
/// @description            Returns how many canvas pixels make up one CSS pixel. Polled by the
///							scaler so moving the window to a screen with a different density re-fits it.
///
/// @returns {number}
///
function display_scaler_js_pixel_ratio() {
    var pixelRatio = window.devicePixelRatio || 1;
    var backingStoreRatio = (g_CurrentGraphics.webkitBackingStorePixelRatio || g_CurrentGraphics.mozBackingStorePixelRatio ||
                             g_CurrentGraphics.msBackingStorePixelRatio || g_CurrentGraphics.oBackingStorePixelRatio ||
                             g_CurrentGraphics.backingStorePixelRatio || 1);
    return pixelRatio / backingStoreRatio;
}

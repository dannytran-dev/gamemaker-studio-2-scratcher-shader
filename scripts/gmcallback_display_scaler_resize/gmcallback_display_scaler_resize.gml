///
/// @function				gmcallback_display_scaler_resize(_json)
/// @description            Called from ext_display_scaler.js once it knows the canvas size in
///							physical pixels. The gmcallback_ prefix keeps this name intact in
///							obfuscated HTML5 builds so JavaScript can call it.
///
/// @param {String}			[_json] - JSON string: { "w": canvas width, "h": canvas height, "dpr": pixel ratio }
/// @returns {undefined}
///
function gmcallback_display_scaler_resize(_json) {
	var _data;
	try {
		_data = json_parse(_json);
	}
	catch (_e) {
		show_debug_message("[DisplayScaler] Invalid resize payload: " + string(_json));
		exit;
	}

	if (!is_struct(_data) || !variable_struct_exists(_data, "w") || !variable_struct_exists(_data, "h")) exit;

	var _dpr = variable_struct_exists(_data, "dpr") ? _data.dpr : 1;
	with (oDisplayScaler) {
		apply_canvas_size(_data.w, _data.h, _dpr);
	}
}

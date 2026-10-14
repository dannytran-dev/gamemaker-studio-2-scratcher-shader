//-----------------------------------------------------------------------------
//	DISPLAY SCALER EVENTS
//	Lets other systems (GUI, input, cameras, layout...) react to display changes
//	without the scaler knowing anything about them.
//
//	Example - a GUI manager re-laying out its elements:
//
//		// Create
//		resizeHandle_ = display_scaler_subscribe(DisplayScalerEvent.RESIZE, function(_info) {
//			layout_elements(_info.guiWidth, _info.guiHeight);
//		});
//
//		// Clean Up
//		display_scaler_unsubscribe(resizeHandle_);
//
//	Every callback receives the same struct as display_scaler_get_info(), plus
//	an "event" field. Treat it as read-only; it is shared by all listeners.
//
//	Callbacks bound to an instance are skipped while that instance doesn't
//	exist (destroyed or deactivated), so a missed unsubscribe can't crash the
//	game - but do unsubscribe in Clean Up to free the listener.
//-----------------------------------------------------------------------------

///
/// @function				display_scaler_subscribe(_event, _callback, [_fireNow])
/// @description            Registers a callback for a display scaler event.
///
/// @param {Real}			[_event] - A DisplayScalerEvent value.
/// @param {Function}		[_callback] - Called as _callback(info).
/// @param {Bool}			[_fireNow] - Call it straight away with the current state
///							if the scaler is already running (default true), so
///							systems created after the scaler start in sync.
/// @returns {Real}			A handle for display_scaler_unsubscribe().
///
function display_scaler_subscribe(_event, _callback, _fireNow = true) {
	var _state = __display_scaler_events();
	var _handle = ++_state.nextHandle;
	array_push(_state.listeners, { handle: _handle, event: _event, callback: _callback, active: true });

	if (_fireNow) {
		var _info = display_scaler_get_info();
		if (!is_undefined(_info)) {
			_info.event = _event;
			_callback(_info);
		}
	}
	return _handle;
}

///
/// @function				display_scaler_unsubscribe(_handle)
/// @description            Removes a callback added with display_scaler_subscribe().
///
/// @param {Real}			[_handle] - The handle returned by display_scaler_subscribe().
/// @returns {Bool}			True if a listener was removed.
///
function display_scaler_unsubscribe(_handle) {
	var _listeners = __display_scaler_events().listeners;
	for (var i = array_length(_listeners) - 1; i >= 0; i--) {
		if (_listeners[i].handle == _handle) {
			_listeners[i].active = false;	// In case we're mid-emit
			array_delete(_listeners, i, 1);
			return true;
		}
	}
	return false;
}

///
/// @function				__display_scaler_emit(_event)
/// @description            Internal. Notifies every listener of _event. Called by oDisplayScaler.
///
/// @param {Real}			[_event] - A DisplayScalerEvent value.
/// @returns {undefined}
///
function __display_scaler_emit(_event) {
	var _listeners = __display_scaler_events().listeners;
	var _count = array_length(_listeners);
	if (_count == 0) return;

	var _info = display_scaler_get_info();
	if (is_undefined(_info)) return;
	_info.event = _event;

	// Iterate over a copy so listeners can subscribe/unsubscribe while being notified
	var _snapshot = array_create(_count);
	array_copy(_snapshot, 0, _listeners, 0, _count);

	for (var i = 0; i < _count; i++) {
		var _listener = _snapshot[i];
		if (!_listener.active || _listener.event != _event) continue;
		if (!__display_scaler_callback_ready(_listener.callback)) continue;
		_listener.callback(_info);
	}
}

///
/// @function				__display_scaler_callback_ready(_callback)
/// @description            Internal. False if the callback is bound to an instance that
///							doesn't currently exist (calling it would throw).
///
/// @param {Function}		[_callback]
/// @returns {Bool}
///
function __display_scaler_callback_ready(_callback) {
	if (!is_method(_callback)) return true;

	var _self = method_get_self(_callback);
	if (is_undefined(_self) || is_struct(_self)) return true;
	return instance_exists(_self);
}

///
/// @function				__display_scaler_events()
/// @description            Internal. Lazily created listener storage, so systems can
///							subscribe before oDisplayScaler exists.
///
/// @returns {Struct}
///
function __display_scaler_events() {
	static _state = { listeners: [], nextHandle: 0 };
	return _state;
}

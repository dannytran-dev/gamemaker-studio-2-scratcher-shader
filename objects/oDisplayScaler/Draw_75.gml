/// @description Resolution Overlay

if (!showOverlay_) exit;

var _scale	= 0.7;
var _pad	= 20;

var _screenLabel = IS_BROWSER ? "Browser" : "Window";
var _labels	= "Mode\n" + _screenLabel + "\nCanvas\nDPR\nView\nCamera\nApp Surface\nGUI\nZoom";
var _values	= get_mode_name() + "\n"
			+ string(screenWidth_)  + " x " + string(screenHeight_) + "\n"
			+ string(canvasWidth_) + " x " + string(canvasHeight_) + "\n"
			+ string_format(pixelRatio_, 1, 2) + "\n"
			+ string(round(viewWidth_)) + " x " + string(round(viewHeight_)) + "\n"
			+ string(round(camera_get_view_width(camera_))) + " x " + string(round(camera_get_view_height(camera_))) + "\n"
			+ string(surface_get_width(application_surface)) + " x " + string(surface_get_height(application_surface)) + "\n"
			+ string(display_get_gui_width()) + " x " + string(display_get_gui_height()) + "\n"
			+ string_format(zoom_, 1, 2) + "x";

draw_set_font(font_);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _labelW	= string_width(_labels) * _scale;
var _gap	= 24;
var _w		= _pad * 2 + _labelW + _gap + string_width(_values) * _scale;
var _h		= _pad * 2 + string_height(_labels) * _scale;

// Bottom-left, kept clear of any bottom-edge UI
var _xx		= display_gui_anchor_x(48, DisplayAnchor.BOTTOMLEFT);
var _yy		= display_gui_anchor_y(BASE_HEIGHT - 250, DisplayAnchor.BOTTOMLEFT) - _h;

// Panel
draw_set_alpha(0.75);
draw_set_colour(c_black);
draw_rectangle(_xx, _yy, _xx + _w, _yy + _h, false);
draw_set_alpha(1);
draw_set_colour(make_colour_rgb(63, 169, 245));
draw_rectangle(_xx, _yy, _xx + _w, _yy + _h, true);

// Text
draw_set_colour(make_colour_rgb(150, 160, 175));
draw_text_transformed(_xx + _pad, _yy + _pad, _labels, _scale, _scale, 0);
draw_set_colour(c_white);
draw_text_transformed(_xx + _pad + _labelW + _gap, _yy + _pad, _values, _scale, _scale, 0);

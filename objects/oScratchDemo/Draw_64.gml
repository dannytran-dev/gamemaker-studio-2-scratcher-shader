/// @description GUI

draw_set_font(fntDefault);

var _gw = display_get_gui_width();
var _mx = display_mouse_gui_x();
var _my = display_mouse_gui_y();

// TITLE (wraps on narrow portrait screens):
//-----------------------------------------------------------------------------
var _tx = display_gui_anchor_x(BASE_WIDTH / 2, DisplayAnchor.TOPCENTER);
var _ty = display_gui_anchor_y(56, DisplayAnchor.TOPCENTER);
var _titleScale = 1.2;
var _subScale = 0.55;
var _wrap = min(_gw - 120, 1100);
var _title = "Scratch & Reveal Shader";

draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_colour(c_white);
draw_text_ext_transformed(_tx, _ty, _title, -1, _wrap / _titleScale, _titleScale, _titleScale, 0);
_ty += string_height_ext(_title, -1, _wrap / _titleScale) * _titleScale + 6;
draw_set_colour(colMuted_);
draw_text_ext_transformed(_tx, _ty, "Drag across the foil to scratch it off", -1, _wrap / _subScale, _subScale, _subScale, 0);

// MASK VIEW (top-left): the two things that drive the effect
//-----------------------------------------------------------------------------
if (showMask_) {
	var _scale = 0.32;
	var _pad = 20;
	var _labelScale = 0.5;
	var _labelH = string_height("M") * _labelScale;
	var _imgW = card_.maskWidth_ * _scale;
	var _imgH = card_.maskHeight_ * _scale;
	var _px = display_gui_anchor_x(40, DisplayAnchor.TOPLEFT);
	var _py = display_gui_anchor_y(40, DisplayAnchor.TOPLEFT);
	var _pw = _imgW + _pad * 2;
	var _ph = _pad * 2 + (_labelH + 8 + _imgH) * 2 + 20;

	draw_set_alpha(0.85);
	draw_set_colour(colPanel_);
	draw_roundrect_ext(_px, _py, _px + _pw, _py + _ph, 16, 16, false);
	draw_set_alpha(1);
	draw_set_colour(colGold_);
	draw_roundrect_ext(_px, _py, _px + _pw, _py + _ph, 16, 16, true);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	var _x = _px + _pad;
	var _y = _py + _pad;

	draw_set_colour(colMuted_);
	draw_text_transformed(_x, _y, "MASK SURFACE (white = scratched)", _labelScale, _labelScale, 0);
	_y += _labelH + 8;
	card_.draw_debug_mask(_x, _y, _scale);
	_y += _imgH + 20;

	draw_set_colour(colMuted_);
	draw_text_transformed(_x, _y, "COVERAGE GRID  " + string(card_.cellsCleared_) + " / " + string(card_.cellsTotal_) + " cells", _labelScale, _labelScale, 0);
	_y += _labelH + 8;
	card_.draw_debug_grid(_x, _y, _scale);
}

// BUTTONS:
//-----------------------------------------------------------------------------
var _cx = display_gui_anchor_x(BASE_WIDTH / 2, DisplayAnchor.BOTTOMCENTER);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var i = 0; i < array_length(buttons_); i++) {
	var _r = buttons_[i].rect;
	var _hover = point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3]);

	draw_set_colour(_hover ? colGold_ : colPanel_);
	draw_roundrect_ext(_r[0], _r[1], _r[2], _r[3], 16, 16, false);
	draw_set_colour(colGold_);
	draw_roundrect_ext(_r[0], _r[1], _r[2], _r[3], 16, 16, true);
	draw_set_colour(_hover ? c_black : c_white);
	draw_text_transformed((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, buttons_[i].label, 0.75, 0.75, 0);
}

// CONTROLS HINT (below the buttons):
//-----------------------------------------------------------------------------
var _r0 = buttons_[0].rect;
draw_set_valign(fa_top);
draw_set_colour(colMuted_);
draw_text_ext_transformed(_cx, _r0[3] + 14, "N  new card   |   R  reset   |   M  mask view   |   D  display details", -1, _wrap / 0.5, 0.5, 0.5, 0);

draw_set_colour(c_white);

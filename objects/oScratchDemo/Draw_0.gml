/// @description Card + Prize
// The scratch card instance draws the foil on top of this, over the prize panel.

draw_set_font(fntDefault);

var _cx = BASE_WIDTH / 2;

// Card
draw_sprite(sDemoCard, 0, cardX1_, cardY1_);

// Prize under the foil
draw_sprite(sDemoPrizePanel, 0, windowX_, windowY_);
for (var i = 0; i < 3; i++) {
	draw_sprite(sDemoSymbols, symbols_[i], windowX_ + symbolX_[i], windowY_ + symbolY_);
}
draw_sprite(sDemoResult, isWin_ ? 0 : 1, windowX_ + windowW_ / 2, windowY_ + resultY_);

// Progress bar
var _barW = 800;
var _barH = 18;
var _barX = _cx - _barW / 2;
var _barY = windowY_ + windowH_ + 58;
var _revealed = card_.is_revealed();

draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_colour(colMuted_);
draw_text_transformed(_barX, _barY - 8, "REVEALED", 0.6, 0.6, 0);
draw_set_halign(fa_right);
draw_set_colour(c_white);
draw_text_transformed(_barX + _barW, _barY - 8, string(round(shownProgress_ * 100)) + "%", 0.6, 0.6, 0);

draw_set_colour(colPanel_);
draw_roundrect_ext(_barX, _barY, _barX + _barW, _barY + _barH, _barH, _barH, false);
var _fillW = _barW * clamp(shownProgress_, 0, 1);
if (_fillW > _barH) {
	draw_set_colour(colGold_);
	draw_roundrect_ext(_barX, _barY, _barX + _fillW, _barY + _barH, _barH, _barH, false);
}

// Threshold marker
var _markX = _barX + _barW * card_.revealThreshold_;
draw_set_colour(c_white);
draw_set_alpha(_revealed ? 0.25 : 0.8);
draw_rectangle(_markX - 1, _barY - 4, _markX + 1, _barY + _barH + 4, false);
draw_set_alpha(1);

// Status line
var _status;
if (!_revealed) {
	_status = "Scratch " + string(round(card_.revealThreshold_ * 100)) + "% of the foil to reveal";
	draw_set_colour(colMuted_);
}
else if (isWin_) {
	_status = "Three of a kind - winner!";
	draw_set_colour(colGold_);
}
else {
	_status = "No match this time";
	draw_set_colour(colMuted_);
}
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text_transformed(_cx, _barY + _barH + 16, _status, 0.7, 0.7, 0);

draw_set_colour(c_white);

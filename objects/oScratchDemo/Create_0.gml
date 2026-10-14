/// @description Init
//-----------------------------------------------------------------------------
//	Showcase for oScratchCard: a "match 3" scratch card.
//		- World: the card and prize sprites, with an oScratchCard holding the
//		  foil over the prize. The card only has a cover; the prize is drawn
//		  underneath it by this object, so each deal is just new symbol frames.
//		- GUI: title, buttons, and an optional view of the scratch mask and
//		  coverage grid that drive the effect.
//
//	The camera is set up by oDisplayScaler (LOCK_HEIGHT), so the card stays
//	centred and full height on every screen; wide screens just show more
//	background either side.
//-----------------------------------------------------------------------------

gpu_set_texfilter(true);

colGold_	= make_colour_rgb(242, 193, 78);
colMuted_	= make_colour_rgb(150, 140, 185);
colPanel_	= make_colour_rgb(59, 34, 112);

// CARD LAYOUT (room space, centred in the BASE_WIDTH x BASE_HEIGHT safe area):
//-----------------------------------------------------------------------------
cardX1_		= (BASE_WIDTH - sprite_get_width(sDemoCard)) / 2;
cardY1_		= (BASE_HEIGHT - sprite_get_height(sDemoCard)) / 2;

// The foil and prize panel sit in the window cut into sDemoCard
windowW_	= sprite_get_width(sDemoFoil);
windowH_	= sprite_get_height(sDemoFoil);
windowX_	= cardX1_ + 80;
windowY_	= cardY1_ + 90;

// Symbol centres on sDemoPrizePanel, and where the result line goes
symbolX_	= [190, 420, 650];
symbolY_	= 165;
resultY_	= 322;

winChance_	= 0.5;

// CARD:
//-----------------------------------------------------------------------------
symbols_		= [0, 0, 0];	// sDemoSymbols frames under the foil
isWin_			= false;
shownProgress_	= 0;			// Eases towards the card's real progress for the bar

card_ = scratch_card_create(windowX_, windowY_, depth - 10, sDemoFoil);

// CONFETTI (wins only):
//-----------------------------------------------------------------------------
confettiSystem_ = part_system_create();
part_system_depth(confettiSystem_, depth - 100);
confettiType_ = part_type_create();
part_type_shape(confettiType_, pt_shape_square);
part_type_size(confettiType_, 0.14, 0.24, 0, 0);
part_type_scale(confettiType_, 1, 0.5);
part_type_orientation(confettiType_, 0, 360, 8, 4, false);
part_type_speed(confettiType_, 9, 17, -0.12, 0);
part_type_direction(confettiType_, 50, 130, 0, 6);
part_type_gravity(confettiType_, 0.35, 270);
part_type_alpha3(confettiType_, 1, 1, 0);
part_type_life(confettiType_, 90, 140);
confettiColours_ = [
	make_colour_rgb(242, 193, 78),
	make_colour_rgb(232, 80, 106),
	make_colour_rgb(63, 167, 224),
	c_white,
];

// BUTTONS (bottom-centre anchored, laid out left to right):
//-----------------------------------------------------------------------------
showMask_ = false;

buttonHeight_ = 60;
buttonGap_ = 12;
buttonY_ = BASE_HEIGHT - 72 - buttonHeight_;
buttons_ = [
	{ label: "New card",	width: 180,	action: method(id, function() { new_card(); }) },
	{ label: "Reset",		width: 140,	action: method(id, function() { card_.reset(); }) },
	{ label: "Show mask",	width: 200,	action: method(id, function() { toggle_mask_view(); }) },
];

#region METHODS

/// Deals a new card: picks three symbols and puts the foil back
new_card = function() {
	var _count = sprite_get_number(sDemoSymbols);
	isWin_ = (random(1) < winChance_);
	if (isWin_) {
		var _s = irandom(_count - 1);
		symbols_ = [_s, _s, _s];
	}
	else {
		do {
			symbols_ = [irandom(_count - 1), irandom(_count - 1), irandom(_count - 1)];
		} until (!(symbols_[0] == symbols_[1] && symbols_[1] == symbols_[2]));
	}
	card_.reset();
}

toggle_mask_view = function() {
	showMask_ = !showMask_;
	buttons_[2].label = showMask_ ? "Hide mask" : "Show mask";
}

/// Called by the card once enough foil is gone
on_card_revealed = function() {
	if (!isWin_) return;
	var _x = BASE_WIDTH / 2;
	var _y = windowY_ + windowH_ / 2;
	for (var i = 0; i < array_length(confettiColours_); i++) {
		part_particles_create_colour(confettiSystem_, _x - 200, _y, confettiType_, confettiColours_[i], 14);
		part_particles_create_colour(confettiSystem_, _x + 200, _y, confettiType_, confettiColours_[i], 14);
	}
}

/// Re-anchors the buttons. Runs on DisplayScalerEvent.RESIZE only.
layout = function(_info) {
	var _total = (array_length(buttons_) - 1) * buttonGap_;
	for (var i = 0; i < array_length(buttons_); i++) _total += buttons_[i].width;

	var _x = (BASE_WIDTH / 2) - (_total / 2);
	var _y1 = display_gui_anchor_y(buttonY_, DisplayAnchor.BOTTOMCENTER);
	for (var i = 0; i < array_length(buttons_); i++) {
		var _btn = buttons_[i];
		var _x1 = display_gui_anchor_x(_x, DisplayAnchor.BOTTOMCENTER);
		_btn.rect = [_x1, _y1, _x1 + _btn.width, _y1 + buttonHeight_];
		_x += _btn.width + buttonGap_;
	}
}

#endregion

card_.onReveal_ = method(id, on_card_revealed);
new_card();

// HOOK INTO THE SCALER:
//-----------------------------------------------------------------------------
layout();
resizeHandle_ = display_scaler_subscribe(DisplayScalerEvent.RESIZE, layout, false);

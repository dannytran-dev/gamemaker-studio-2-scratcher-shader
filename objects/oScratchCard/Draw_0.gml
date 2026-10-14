/// @description Draw Reveal + Cover

if (!sprite_exists(coverSprite_)) exit;

if (revealSprite_ >= 0 && sprite_exists(revealSprite_)) {
	draw_sprite_ext(revealSprite_, 0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha);
}

if (coverAlpha_ <= 0) exit;

ensure_mask();

// Map the cover's texture-page UVs onto the mask's UVs (see shd_scratch_reveal).
// uvs[4..7] account for any transparent border trimmed off the sprite when it was packed.
var _uvs = sprite_get_uvs(coverSprite_, 0);
var _sw = sprite_get_width(coverSprite_);
var _sh = sprite_get_height(coverSprite_);
var _maskTex = surface_get_texture(maskSurface_);
var _m = texture_get_uvs(_maskTex);
var _mw = _m[2] - _m[0];
var _mh = _m[3] - _m[1];
var _kx = (_uvs[6] * _mw) / (_uvs[2] - _uvs[0]);
var _ky = (_uvs[7] * _mh) / (_uvs[3] - _uvs[1]);
var _bx = _m[0] + (_uvs[4] / _sw) * _mw - _kx * _uvs[0];
var _by = _m[1] + (_uvs[5] / _sh) * _mh - _ky * _uvs[1];

shader_set(shd_scratch_reveal);
texture_set_stage(uMask_, _maskTex);
gpu_set_texfilter_ext(uMask_, true);
shader_set_uniform_f(uMaskTransform_, _kx, _ky, _bx, _by);
shader_set_uniform_f(uEdgeOffset_, (SCRATCH_EDGE_WIDTH / maskWidth_) * _mw, (SCRATCH_EDGE_WIDTH / maskHeight_) * _mh);
shader_set_uniform_f(uEdgeShade_, SCRATCH_EDGE_SHADE);
draw_sprite_ext(coverSprite_, 0, x, y, image_xscale, image_yscale, 0, image_blend, image_alpha * coverAlpha_);
shader_reset();

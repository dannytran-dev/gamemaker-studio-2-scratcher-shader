//
// Scratch reveal: erases the sprite being drawn wherever the scratch mask is white.
//
// The mask is a surface the size of the sprite. It starts black, and the brush
// paints white into it. Its red channel is used as "how scratched" (0-1), so
// soft brush edges fade the cover out smoothly instead of cutting it hard.
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_mask;

// Maps the sprite's texture-page UVs to mask UVs: maskUV = uv * xy + zw.
// The sprite is usually packed somewhere on a texture page, so its UVs don't
// run 0-1 like the mask's do.
uniform vec4 u_maskTransform;

// Offset (in mask UVs) towards the light, and how dark the edge of a scratch gets
uniform vec2 u_edgeOffset;
uniform float u_edgeShade;

void main()
{
    vec4 base = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );

    vec2 maskUV = v_vTexcoord * u_maskTransform.xy + u_maskTransform.zw;
    float scratched = texture2D( u_mask, maskUV ).r;

    // Leftover cover next to a scratch is shaded as if its edge is raised,
    // lit from the top-left
    float scratchedNear = texture2D( u_mask, maskUV - u_edgeOffset ).r;
    float edge = clamp( scratchedNear - scratched, 0.0, 1.0 );
    base.rgb *= 1.0 - edge * u_edgeShade;

    base.a *= 1.0 - scratched;

    gl_FragColor = base;
}

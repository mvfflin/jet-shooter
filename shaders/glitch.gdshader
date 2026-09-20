shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    if (glitch_intensity > 0.0) {
        // Efek garis-garis terpotong horizontal (Scanline Displace)
        float noise = random(vec2(trunc(uv.y * 30.0), TIME));
        if (noise < glitch_intensity * 0.4) {
            uv.x += (random(vec2(TIME, uv.y)) - 0.5) * 0.08 * glitch_intensity;
        }
        
        // Chromatic Aberration (Pemisahan warna Merah & Biru)
        float r = texture(SCREEN_TEXTURE, uv + vec2(0.005 * glitch_intensity, 0.0)).r;
        float g = texture(SCREEN_TEXTURE, uv).g;
        float b = texture(SCREEN_TEXTURE, uv - vec2(0.005 * glitch_intensity, 0.0)).b;
        COLOR = vec4(r, g, b, 1.0);
    } else {
        COLOR = texture(SCREEN_TEXTURE, uv);
    }
}
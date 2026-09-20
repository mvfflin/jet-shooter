shader_type canvas_item;

uniform float perspective : hint_range(0.0, 1.0) = 0.5;
uniform float width_scale : hint_range(0.5, 2.0) = 1.3;

void fragment() {
    vec2 uv = UV;
    
    float centered_x = (uv.x - 0.5) / width_scale;
    
    float target_x = centered_x / (1.0 - (1.0 - uv.y) * perspective) + 0.5;
    
    if (target_x < 0.0 || target_x > 1.0) {
        discard;
    }
    
    COLOR = texture(TEXTURE, vec2(target_x, uv.y));
}
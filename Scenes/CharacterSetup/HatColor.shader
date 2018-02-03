shader_type canvas_item;

uniform vec4 u_color_key : hint_color;
uniform vec4 u_replacement_color : hint_color;
// How much tolerance for the replacement color (between 0 and 1)
uniform float u_tolerance;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    vec4 d4 = abs(col - u_color_key);
    float d = max(max(d4.r, d4.g), d4.b);
    if(d < 0.01) {
        col = u_replacement_color;
    }
    COLOR = col;
}

//void fragment() {
//    // Get color from the sprite texture at the current pixel we are rendering
//    vec4 original_color = texture(TEXTURE, UV);
//    vec3 col = original_color.rgb;
//    // Get a rough degree of difference between the texture color and the color key
//    vec3 diff3 = col - u_color_key.rgb;
//    float m = max(max(abs(diff3.r), abs(diff3.g)), abs(diff3.b));
//    // Change color of pixels below tolerance threshold, while keeping shades if any (a bit naive, there may better ways)
//    float brightness = length(col);
//    col = mix(col, u_replacement_color.rgb * brightness, step(m, u_tolerance));
//    // Assign final color for the pixel, and preserve transparency
//    COLOR = vec4(col.rgb, original_color.a);
//}
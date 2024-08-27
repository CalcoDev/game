shader_type canvas_item;

uniform vec3 u_shadow_color : source_color = vec3(1.0, 0.0, 0.0);

uniform sampler2D u_scene_tex;
uniform vec3 u_light_dir = vec3(0.0); // the Z acts as sun elevation
//uniform float u_max_height = 100.0;
// uniform float u_distance = 20;

const vec2 step_size_xy = vec2(1.0 / 320.0 / 4.0, 1.0 / 180.0 / 4.0);

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void checkHit(vec2 pos, out bool hit) {
    vec4 col = texture(u_scene_tex, pos);
    hit = col.a > 0.0;
}

void fragment() {
    //vec2 p = UV;
    //float angle_offset = random(UV) * PI / 16.0;
    
    // vec2 stp = rotate(-u_light_dir, vec2(0.0, 0.0), angle_offset) * step_size;
    
    float height = texture(u_scene_tex, UV).r;
    // starting point
    vec3 p = vec3(UV.xy, height);
    vec3 step_dist = vec3(-u_light_dir.xy * step_size_xy, u_light_dir.z);
    float in_shadow = 0.0;
    while (
        p.x >= 0.0 && p.x <= 1.0 &&
        p.y >= 0.0 && p.y <= 1.0 &&
        p.z >= 0.0 && p.z <= 1.0 &&
        in_shadow < 1.0
    ) {
        p += step_dist;
        vec4 sampl = texture(u_scene_tex, p.xy);
        float height = sampl.r;
        float hover = sampl.g;
        if (height > p.z && p.z > hover) {
            in_shadow = 1.0;
        }
    }
    COLOR = vec4(u_shadow_color.xyz, 1.0 * in_shadow);
    //COLOR = vec4(height, height, height, 1.0);
    //COLOR = vec4(texture(u_scene_tex, UV));
    //COLOR = vec4(1.0, 0.0, 0.0, texture(u_scene_tex, UV).a);
    
    //vec3 step_diff = u_light_pos - p;
    //vec3 step_count = vec3(step_diff.xy / step_size_xy, step_diff.z * u_max_height);
    //step_count.x = max(step_count.x, max(step_count.y, step_count.z));
    //vec3 step_dist = step_diff / step_count.x;
    //float in_shadow = 0.0;
    //for (float i = 0.0; i < step_count.x; ++i) {
        //p += step_dist;
        //
        //float h = texture(u_scene_tex, p.xy).r;
        //if (h > p.z) {
            //in_shadow = 1.0;
            //break;
        //} else if (p.z > 1.0) {
            //break;
        //}
    //}
    //COLOR = vec4(u_shadow_color.xyz, 1.0 * in_shadow);
    
    
    
    //float stplen = length(stp);
    //float tries = 0.0;
    //bool hit = false;
    //checkHit(p, hit);
    //while(p.x > 0.0 && p.x < 1.0 && p.y > 0.0 && p.y < 1.0 && !hit && tries < u_distance) {
        //tries += 1.0;
        //p += stp;
        //checkHit(p, hit);
    //}
    
    //float dist_scale = 1.0 - tries / u_distance;
    //float steps = 1.0 / 5.0;
    //dist_scale = floor(dist_scale / steps) * steps;
    
    // Dithering effect based on distance
    //float noise = random(UV * tries) * 0.2; // Adjust the noise factor (0.2 here is for subtle dithering)
    //float dithering = dist_scale + noise; // Modulate dist_scale with noise

    // Clamp dithering to [0, 1] to avoid negative alpha values
    //dithering = clamp(dithering, 0.0, 1.0);
    //COLOR = vec4(u_shadow_color.xyz, 1.0 * float(hit) * float(tries != 0.0) * float(dithering > 0.05));
}
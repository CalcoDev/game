shader_type canvas_item;

uniform vec2 u_cam_offset = vec2(0.0, 0.0);

void vertex() {
    VERTEX += u_cam_offset;
}
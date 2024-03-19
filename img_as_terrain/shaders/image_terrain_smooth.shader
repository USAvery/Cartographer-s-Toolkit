shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D texture_1;
uniform sampler2D texture_2;
uniform sampler2D texture_3;
uniform sampler2D texture_4;
uniform sampler2D splat;
uniform float blend_step = 0.04;
uniform vec2 map_size;
varying vec2 world_uv;
varying vec2 texture_1_uv;
varying vec2 texture_2_uv;
varying vec2 texture_3_uv;
varying vec2 texture_4_uv;


uniform bool texture_1_stretch;
uniform bool texture_2_stretch;
uniform bool texture_3_stretch;
uniform bool texture_4_stretch;


vec2 texture2uv(sampler2D t, vec2 uv)
{
	ivec2 size = textureSize(t, 0);
	uv.x /= float(size.x);
	uv.y /= float(size.y);
	return uv;
}

vec2 texture2uv_stretch(sampler2D t, vec2 uv)
{
	ivec2 size = textureSize(t, 0);
	uv.x /= float(map_size.x);
	uv.y /= float(map_size.y);
	return uv;
}

void vertex()
{
	world_uv = VERTEX;

    if (texture_1_stretch) {
        texture_1_uv = texture2uv_stretch(texture_1, world_uv);
    }
    else {
        texture_1_uv = texture2uv(texture_1, world_uv);
    }

    if (texture_2_stretch) {
        texture_2_uv = texture2uv_stretch(texture_2, world_uv);
    }
    else {
        texture_2_uv = texture2uv(texture_2, world_uv);
    }

    if (texture_3_stretch) {
        texture_3_uv = texture2uv_stretch(texture_3, world_uv);
    }
    else {
        texture_3_uv = texture2uv(texture_3, world_uv);
    }

    if (texture_4_stretch) {
        texture_4_uv = texture2uv_stretch(texture_4, world_uv);
    }
    else {
        texture_4_uv = texture2uv(texture_4, world_uv);
    }
}

void fragment()
{
	vec4 s = texture(splat, world_uv / map_size);
	vec4 t1 = texture(texture_1, texture_1_uv);
	vec4 t2 = texture(texture_2, texture_2_uv);
	vec4 t3 = texture(texture_3, texture_3_uv);
	vec4 t4 = texture(texture_4, texture_4_uv);
	vec3 albedo = t1.rgb * s.r + t2.rgb * s.g + t3.rgb * s.b + t4.rgb * s.a;

	COLOR.rgb = albedo;
}
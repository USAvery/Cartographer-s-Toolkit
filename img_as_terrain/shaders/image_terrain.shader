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

uniform vec4 texture_1_tint;
uniform vec4 texture_2_tint;
uniform vec4 texture_3_tint;
uniform vec4 texture_4_tint;


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

float max4(float v1, float v2, float v3, float v4)
{
	return max(max(v1, v2), max(v3, v4));
}

vec3 blend(vec3 t1, float h1, vec3 t2, float h2, vec3 t3, float h3, vec3 t4, float h4)
{
	float height_start = max4(h1, h2, h3, h4) - blend_step;
	float s1 = max(h1 - height_start, 0);
	float s2 = max(h2 - height_start, 0);
	float s3 = max(h3 - height_start, 0);
	float s4 = max(h4 - height_start, 0);
	float splat_sum = s1 + s2 + s3 + s4;
	return ((t1 * s1) + (t2 * s2) + (t3 * s3) + (t4 * s4)) / splat_sum;
}

void fragment()
{
	vec4 s = texture(splat, world_uv / map_size);
	vec4 t1 = texture(texture_1, texture_1_uv) * texture_1_tint;
	vec4 t2 = texture(texture_2, texture_2_uv) * texture_2_tint;
	vec4 t3 = texture(texture_3, texture_3_uv) * texture_3_tint;
	vec4 t4 = texture(texture_4, texture_4_uv) * texture_4_tint;
	vec3 albedo = blend(t1.rgb, t1.a * s.r, t2.rgb, t2.a * s.g, t3.rgb, t3.a * s.b, t4.rgb, t4.a * s.a);

	COLOR.rgb = albedo;
	COLOR.a = 1.0;
}

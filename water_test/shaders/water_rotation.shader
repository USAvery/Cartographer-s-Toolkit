shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D distortion;
uniform float current_rotation;

varying vec2 world_distort_uv;
varying vec2 world_disort_b_uv;


float average(in vec3 color)
{
	return (color.r + color.g + color.b) / 3.0;
}

vec2 rotateUVmatrix(vec2 uv, vec2 pivot, float rotation)
{
    mat2 rotation_matrix = mat2(vec2(sin(rotation), -cos(rotation)), vec2(cos(rotation), sin(rotation)));
	uv -= pivot;
    uv= uv*rotation_matrix;
    uv += pivot;
    return uv;
}

void vertex()
{
	world_distort_uv = rotateUVmatrix(VERTEX, vec2(-100.0), current_rotation);
	world_disort_b_uv = rotateUVmatrix(VERTEX, vec2(100.0), -current_rotation);

	ivec2 distort_size = textureSize(distortion, 0) * 2;
	
	world_distort_uv.x /= float(distort_size.x);
	world_distort_uv.y /= float(distort_size.y);
	
	world_disort_b_uv.x /= float(distort_size.x);
	world_disort_b_uv.y /= float(distort_size.y);
}

void fragment()
{
	vec2 distort1 = (texture(distortion, -world_disort_b_uv*0.05).rg - 0.5) * 0.005;
	vec2 distort2 = (texture(distortion, world_distort_uv*0.05).rg - 0.5) * 0.005;

	vec2 uv_offset = mix(distort1, distort2, 0.5);
	vec3 distorted_floor = texture(SCREEN_TEXTURE, SCREEN_UV + uv_offset).rgb;
	float avg = average(distorted_floor);

	if (avg < 0.5)
	{
		COLOR.rgb *= smoothstep(0.0, 0.5, avg);
	}
}
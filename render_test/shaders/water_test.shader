shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D distortion;
varying vec2 world_distort_uv;


float average(in vec3 color)
{
	return (color.r + color.g + color.b) / 3.0;
}

void vertex()
{
	world_distort_uv = VERTEX;
	ivec2 distort_size = textureSize(distortion, 0) * 2;

	world_distort_uv.x /= float(distort_size.x);
	world_distort_uv.y /= float(distort_size.y);
}

void fragment()
{
	vec2 distort1 = (texture(distortion, world_distort_uv - TIME * 0.05).rg - 0.5) * 0.01;
	vec2 distort2 = (texture(distortion, world_distort_uv + TIME * 0.05).rg - 0.5) * 0.01;

	vec2 uv_offset = mix(distort1, distort2, 0.5);
	vec3 distorted_floor = texture(SCREEN_TEXTURE, SCREEN_UV + uv_offset).rgb;
	float avg = average(distorted_floor);

	if (avg < 0.5)
	{
		COLOR.rgb *= smoothstep(0.0, 0.5, avg);
	}
}
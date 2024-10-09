shader_type spatial;
render_mode unshaded;

uniform sampler2D sky_gradient;
void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float diameter = 100;
uniform float band_size = 0.1;
uniform float interpolation_val =0.0;

float dist_from_sun(vec3 position){
	float radius = diameter/2.0;
	float dist = mix(interpolation_val-band_size/2.0, interpolation_val+band_size/2.0, 1.0+position.z/radius);
	return dist;
}

void fragment() {
	vec4 world_frag_pos = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);

	float dist = dist_from_sun(world_frag_pos.xyz);

	vec3 sampled_color = texture(sky_gradient, vec2(dist,0)).rgb;
	vec3 world_normal = NORMAL * mat3(VIEW_MATRIX);

	ALBEDO = sampled_color;

	if (world_normal.y < 0.0){
		ALBEDO = sampled_color - vec3(0.04);
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

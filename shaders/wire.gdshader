shader_type spatial;
uniform vec2 point_a = vec2(-5.0,1.0);
uniform vec2 point_b = vec2(5.0,1.0);
uniform float a = 1;


void vertex() {
	float x = VERTEX.x;
	VERTEX.y += a * cosh(x/a);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

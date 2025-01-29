shader_type spatial;
uniform float a = 1;
uniform float b = 1;
uniform float c = 1;
uniform float d = 1;

void vertex() {
	float x = VERTEX.x;
	VERTEX.y += a * pow(x/d, 2) + b * x + c;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

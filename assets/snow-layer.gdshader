shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
	if (NORMAL.y > 0.5) {
		VERTEX.y += 0.1;
	}
	VERTEX.y += 1.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

uniform float fillAmount = 1.0;

void fragment() {
	// Called for every pixel the material is visible on.
	if (UV.y < (1.0 - fillAmount))
	{
		discard;
	}
	
	COLOR = texture(TEXTURE, UV);
}

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

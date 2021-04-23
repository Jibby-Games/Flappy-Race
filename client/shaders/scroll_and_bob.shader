shader_type canvas_item;
uniform float scroll_speed;
uniform float bob_speed;
uniform float bob_amplitude;

// Fragments run on every individual pixel
void fragment() {
	// This is the location shift applied to each pixel by the GPU
	
	vec2 shiftedUV = UV;
	
	// This simply takes the time run, multiplies the speed by it, and sets the 
	// new x to that.
	// This means that altering the speed results in jumps. Need to fix. 
	// Can shaders access dt?
	shiftedUV.x += TIME * scroll_speed;
	shiftedUV.y += bob_amplitude * sin(TIME*bob_speed);
	
	vec4 col = texture(TEXTURE, shiftedUV);
	
	COLOR = col;
}
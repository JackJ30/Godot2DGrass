shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform float frequencyMod = 300.0;
uniform float windSpeed = 0.05;

float map(float value, float startLow, float startHigh, float finalLow, float finalHigh)
{
	return finalLow + (value - startLow) * (finalHigh - finalLow) / (startHigh - startLow);
}

void vertex() {
	vec2 windUVOffset = vec2(TIME * windSpeed);
	float randomWind = texture(noise, (VERTEX.xy / frequencyMod) + windUVOffset).r;
	float influence = pow(UV.x, 0.5) * randomWind;// min(random * 0.5, 1.0);
	VERTEX.x += cos(TIME * 1.5) * 5.0 * influence;// random * 120.0;
	VERTEX.y += sin(TIME * 1.5) * 2.0 * influence;
	
}

void fragment() {
	//COLOR += (max(UV.y, 0.7) - 0.7) * 0.3;
	COLOR += clamp(map(UV.y, 0.65, 1.0, 0.0, 0.08), 0.0, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

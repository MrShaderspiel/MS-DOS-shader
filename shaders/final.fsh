#version 460 compatibility

// Varyings
varying vec2 texcoord;

// Samplers
uniform sampler2D texture;
uniform sampler2D colortex4;

// Get the screen resolution
uniform float viewWidth;
uniform float viewHeight;
vec2 resolution = vec2(viewWidth, viewHeight);

// Get the texture size
vec2 textureSize = textureSize(colortex4);

// Set the character size
const vec2 fontSize = vec2(8.0f, 16.0f);

// #define COLOR_ENABLE   // Enable color

vec4 lookupChar(float asciiValue){
	vec2 pos = (mod(gl_FragCoord.xy, fontSize.xy) / textureSize) + asciiValue;
	
	// Flip the texture upside down and sideways
	pos *= vec2(-1.0f, -1.0f);

	return vec4(texture2D(colortex4, pos).rgb, 1.0f);
}

// Function to get the average value of a vec3
float avgVec3(vec3 vector) {
	return (vector.x + vector.y + vector.z) * 0.3333f;
}

/***** MAIN *****/
void main() {
	vec2 invViewport = vec2(1.0f, 1.0f) / resolution;
	vec2 pixelSize = fontSize;
	vec4 sum = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	vec2 texcoordClamped = texcoord - mod(texcoord, pixelSize * invViewport);
	for (float x = 0.0f; x < fontSize.x; x++) {
		for (float y = 0.0f; y < fontSize.y; y++) {
			vec2 offset = vec2(x, y);
			sum += texture2D(texture, texcoordClamped + (offset * invViewport));
		}
	}
	vec4 average = sum / vec4(fontSize.x * fontSize.y);
	float brightness = avgVec3(average);
	float asciiChar = floor((1.0f - brightness) * 256.0f) / 256.0f;
	
	#ifdef COLOR_ENABLE
		vec4 roundedColor = floor(average * 8.0f) / 8.0f;
		vec4 color = roundedColor * lookupChar(asciiChar);
	#else
		vec4 color = lookupChar(asciiChar);
	#endif
	
/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
}

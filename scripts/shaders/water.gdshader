shader_type canvas_item;

uniform vec2 scale;
uniform float y_zoom;

uniform vec4 water_color : source_color ;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform sampler2D noise ;
uniform vec2 distortion_scale ;
uniform float intensity ;
uniform float dist_speed ;

uniform float wave_amplitude ;
uniform float wave_period ;
uniform float wave_speed ;

// altering the figures too much can flip the shoreline
// increased value range use as is
uniform vec4 shorelineColor : source_color = vec4(1.);
uniform float shorelineSize : hint_range(-0.6, 1.0) = 0.0025;
uniform float foamsize : hint_range(0.0, 1.1) = 0.1 ;
uniform float foamstrength : hint_range(0.0, 1.0) = 0.3 ;


void fragment() {
	
	float waves = UV.y * scale.y + sin( UV.x * scale.x / wave_period - TIME*wave_speed ) * cos(0.2 * UV.x * scale.x / wave_period + TIME-wave_speed)
	* wave_amplitude - wave_amplitude ;
	
	float distortion = texture(noise , UV*distortion_scale*scale + TIME*dist_speed).x  ;
	distortion -= 0.3
	 ;
	
	
	float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	
	vec2 reflected_screen_uv = vec2(SCREEN_UV.x - (distortion * intensity * y_zoom), SCREEN_UV.y - uv_height * UV.y * y_zoom * scale.y * 2.0);
	
	vec4 reflection = textureLod( SCREEN_TEXTURE , reflected_screen_uv , 0);
	
	
	
	float shoreline = smoothstep(foamsize - shorelineSize, foamstrength, waves);
	
	COLOR.rgb = mix(shorelineColor.rgb, mix(reflection.rgb, water_color.rgb, water_color.a), shoreline );
	COLOR.a = smoothstep(0.1, 0.13, waves);

//	COLOR.rgb = mix(reflection.rgb , water_color.rgb , water_color.a);
//	COLOR.a = smoothstep(0.1 , 0.13 ,waves ) ;
	
	
}
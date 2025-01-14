shader_type spatial;

uniform sampler2D height_map;
uniform sampler2D path_map;

uniform float height_scale = 1.0;
uniform float offset_x = -2559.5;
uniform float offset_z = -2559.5;
uniform float offset_y = 0.5;
uniform float path_scaler = 1.0;

varying vec3 distortion;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform sampler2D texture_ambient_occlusion : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 ao_texture_channel;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);

uniform float subsurface_scattering_strength : hint_range(0.0, 1.0, 0.01);
uniform sampler2D texture_subsurface_scattering : hint_default_white, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_heightmap : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform float heightmap_scale : hint_range(-16.0, 16.0, 0.001);
uniform int heightmap_min_layers : hint_range(1, 64);
uniform int heightmap_max_layers : hint_range(1, 64);
uniform vec2 heightmap_flip;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

const vec2 size = vec2(2.0,0.0);
const vec3 off = vec3(-1.0,0.0,1.0);

void vertex() {
	// Called for every vertex the material is visible on.
	vec3 world_position = NODE_POSITION_WORLD;
	vec3 vertex_position = world_position + VERTEX;
	vec2 texture_pos = vec2((vertex_position.x + offset_x) / 5120.0, (vertex_position.z + offset_z) / 4608.0);
	float height = texture(height_map, (texture_pos)).x - vertex_position.y;
	
	vec2 path_tex_coords = vec2((VERTEX.x / 100.0) + 0.5, (VERTEX.z / 100.0) + 0.5);
	float path_offset = -texture(path_map, path_tex_coords).r;
	if (path_offset != 0.0) {
		height += path_offset * path_scaler;
	}
	
	//float from_center = sqrt(pow(abs(VERTEX.x),2)+pow(abs(VERTEX.z),2));
	//if (from_center <= 0.5) {
		//height -= offset_y - from_center;
	//}
	
	distortion = vec3(0,height * height_scale + offset_y ,0);
	VERTEX.y += height * height_scale + offset_y;
	
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	// Called for every pixel the material is visible on.
	
    // Compute partial derivatives
	vec3 pos = VERTEX;
    vec3 dx = dFdx(pos);
    vec3 dy = dFdy(pos);

    // Compute the normal
    //vec3 normal = normalize(cross(dx, dy));
	vec3 tangent = normalize(dx); // Assumes primary variation along x
    vec3 binormal = normalize(dy); // Assumes primary variation along z
    vec3 normal = normalize(cross(binormal, tangent)); // Normal from tangent and binormal
	NORMAL = normal;

    // Output the normal (visualize it)
    // ALBEDO = normal * 0.5 + 0.5; // Normalize to 0-1 range for visualization

	vec2 base_uv = (100.0 + (UV * 2.0 - 1.0)) * 5.0;

	{
		// Height: Enabled
		vec3 view_dir = normalize(normalize(-VERTEX + EYE_OFFSET) * mat3(TANGENT * heightmap_flip.x, -BINORMAL * heightmap_flip.y, NORMAL));
		float depth = 1.0 - texture(texture_heightmap, base_uv).r;
		vec2 ofs = base_uv - view_dir.xy * depth * heightmap_scale * 0.01;
		base_uv = ofs;
	}

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;

	// Ambient Occlusion: Enabled
	AO = dot(texture(texture_ambient_occlusion, base_uv), ao_texture_channel);
	AO_LIGHT_AFFECT = ao_light_affect;

	// Subsurface Scattering: Enabled
	float sss_tex = texture(texture_subsurface_scattering, base_uv).r;
	SSS_STRENGTH = subsurface_scattering_strength * sss_tex;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}

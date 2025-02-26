extends Node

@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@export var day_length_s: float = 600;

const NIGHT_SKY_HDRI_002_2K_TONEMAPPED = preload("res://assets/textures/NightSkyHDRI002_2K-TONEMAPPED.jpg")
const KLOPPENHEIM_07_PURESKY_4K = preload("res://assets/textures/kloppenheim_07_puresky_4k.hdr")

var start_time_ms: float;
var initial_light_energy: float;
var initial_sky_energy: float;
var initial_sky_cover_modulate: Color;

var ref_sky_material: ProceduralSkyMaterial;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time_ms = Time.get_ticks_msec();
	initial_light_energy = directional_light_3d.light_energy;
	initial_sky_energy = world_environment.environment.sky.sky_material.energy_multiplier;
	initial_sky_cover_modulate = world_environment.environment.sky.sky_material.sky_cover_modulate;
	ref_sky_material = world_environment.environment.sky.sky_material
	assert(ref_sky_material == world_environment.environment.sky.sky_material)
	ref_sky_material.sky_cover = KLOPPENHEIM_07_PURESKY_4K


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	directional_light_3d.rotate_x(deg_to_rad((360.0 / day_length_s) * delta))
	var energy = initial_light_energy * ((90-abs(rad_to_deg(directional_light_3d.rotation.z))) / 90)
	var energy_pos = clamp(energy, 0.0, 1.0)
	var energy_neg = clamp(energy, -1.0, 0.0)
	if abs(rad_to_deg(directional_light_3d.rotation.z)) > 90.0:
		directional_light_3d.light_energy = 0.0
		if ref_sky_material.sky_cover == KLOPPENHEIM_07_PURESKY_4K:
			ref_sky_material.sky_cover = NIGHT_SKY_HDRI_002_2K_TONEMAPPED
		ref_sky_material.sky_cover_modulate.a = clamp(pow(abs(energy_neg), 0.5), 0.0, 1.0)
		print(energy)
	else:
		directional_light_3d.light_energy = clamp(energy_pos + 0.2, 0.0, 0.9)
		if ref_sky_material.sky_cover == NIGHT_SKY_HDRI_002_2K_TONEMAPPED:
			ref_sky_material.sky_cover = KLOPPENHEIM_07_PURESKY_4K
		world_environment.environment.sky.sky_material.sky_cover_modulate.a = energy_pos
	world_environment.environment.sky.sky_material.energy_multiplier = clamp(energy_pos, 0.3, 1.0)
	
	
	

extends Node

@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment

@export var day_length_s: float = 600;

var start_time_ms: float;
var initial_light_energy: float;
var initial_sky_energy: float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time_ms = Time.get_ticks_msec();
	initial_light_energy = directional_light_3d.light_energy;
	initial_sky_energy = world_environment.environment.sky.sky_material.energy_multiplier;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	directional_light_3d.rotate_x(deg_to_rad((360.0 / day_length_s) * delta))
	var energy = clamp(initial_light_energy * ((90-abs(rad_to_deg(directional_light_3d.rotation.z))) / 90) + 0.2, 0.0, 0.8)
	directional_light_3d.light_energy = energy
	world_environment.environment.sky.sky_material.energy_multiplier = clamp(energy, 0.3, 1.0)
	
	
	

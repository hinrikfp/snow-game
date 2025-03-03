extends StaticBody3D
class_name Fireplace

@onready var fire_noise: AudioStreamPlayer3D = $FireNoise
@onready var fire: Node3D = $Fire

@export var fire_lit: bool = false

@export var fire_alive_s: float = 300;

var fire_lit_time: float = 0.0;

func _ready() -> void:
	if fire_lit:
		start_fire()
	else:
		stop_fire()

func _physics_process(delta: float) -> void:
	if Time.get_ticks_msec() - fire_lit_time >= fire_alive_s * 1000.0 && fire_lit:
		stop_fire()

func interact(player: Player) -> void:
	if fire_lit:
		fire_lit = false
		stop_fire()
	elif player.inventory["wood"] > 0:
		fire_lit = true
		player.inventory["wood"] -= 1
		start_fire()

func start_fire() -> void:
	fire_noise.play()
	fire.show()
	fire_lit_time = Time.get_ticks_msec()

func stop_fire() -> void:
	fire_noise.stop()
	fire.hide()

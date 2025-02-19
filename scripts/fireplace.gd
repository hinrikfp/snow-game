extends StaticBody3D

@onready var fire_noise: AudioStreamPlayer3D = $FireNoise
@onready var fire: Node3D = $Fire


@export var fire_lit: bool = false

func _ready() -> void:
	if fire_lit:
		start_fire()
	else:
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

func stop_fire() -> void:
	fire_noise.stop()
	fire.hide()

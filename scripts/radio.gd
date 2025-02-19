extends StaticBody3D

@export var generator: Generator;
@export var tower: RadioTower;

func interact(player: Player) -> void:
	if generator.generator_state == Generator.GeneratorState.Running:
		if tower.tower_fixed:
			print("radio used")
		else:
			print("radio tower seems to be broken")
	else:
		print("generator doesn't seem to be running")
		

func get_focus_message() -> String:
	return "try to turn on radio"

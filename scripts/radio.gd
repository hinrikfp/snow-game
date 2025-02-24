extends StaticBody3D

@export var generator: Generator;
@export var tower: RadioTower;

var focus_message: String = "try to turn on radio"

func interact(player: Player) -> void:
	if generator.generator_state == Generator.GeneratorState.Running:
		if tower.tower_fixed:
			print("radio used")
		else:
			focus_message = "fix radio tower to use radio"
	else:
		focus_message = "turn on generator to use radio"
		

func get_focus_message() -> String:
	return focus_message

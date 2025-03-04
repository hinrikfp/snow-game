extends StaticBody3D

@export var generator: Generator;
@export var tower: RadioTower;
@export var game_manager: GameManager;

var focus_message: String = "try to turn on radio"

func interact(player: Player) -> void:
	if generator.generator_state == Generator.GeneratorState.Running:
		if tower.tower_fixed:
			game_manager.finish_game()
			focus_message = "radio used, help is coming."
		else:
			focus_message = "fix radio tower to use radio"
	else:
		focus_message = "turn on generator to use radio"
		

func get_focus_message() -> String:
	return focus_message

extends StaticBody3D
class_name RadioTower

var tower_fixed: bool = false;

func interact(player: Player) -> void:
	if player.inventory["parts"] > 0:
		tower_fixed = true

func get_focus_message() -> String:
	if tower_fixed:
		return "tower fixed"
	else:
		return "fix radio tower"

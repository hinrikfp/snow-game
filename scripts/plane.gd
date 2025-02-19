extends StaticBody3D

signal got_parts()

func interact(player: Player) -> void:
	emit_signal("got_parts")

func get_focus_message() -> String:
	return "collect parts from wreckage"

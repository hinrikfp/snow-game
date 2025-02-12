extends StaticBody3D

signal got_parts()

func interact(player: Player) -> void:
	emit_signal("got_parts")

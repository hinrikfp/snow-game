extends StaticBody3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func interact(player: Player) -> void:
	player.inventory["axe"] += 1
	self.hide()
	collision_shape_3d.disabled = true
	

func get_focus_message() -> String:
	return "pick up axe"

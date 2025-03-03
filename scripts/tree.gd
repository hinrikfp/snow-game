extends Node3D
@onready var tree_upper: RigidBody3D = $"Tree-Upper"

signal got_wood(amount: int)

var hits: int = 0

func hit(player: Player) -> bool:
	if player.inventory["axe"] > 0:
		var fall_direction = player.position.direction_to(position)
		fall_direction = Vector3(fall_direction.x, 0, fall_direction.z)
		tree_upper.apply_force(fall_direction * 250.0, Vector3(0,1,0))
		if self.hits >= 3:
			return false
		else:
			self.emit_signal("got_wood", 1)
			self.hits += 1
			return true
	return false

extends RigidBody3D

@onready var tree: Node3D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func interact(player: CharacterBody3D) -> void:
	var fall_direction = player.position.direction_to(position)
	fall_direction = Vector3(fall_direction.x, 0, fall_direction.z)
	self.apply_force(fall_direction * 50.0, Vector3(0,1,0))
	tree.emit_signal("got_wood", 1)

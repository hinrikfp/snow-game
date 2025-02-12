extends RigidBody3D

@onready var tree: Node3D = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func interact(player: Player) -> void:
	tree.hit(player)

extends StaticBody3D
@onready var tree_upper: RigidBody3D = $"../Tree-Upper"

func interact(player: CharacterBody3D) -> void:
	tree_upper.interact(player)

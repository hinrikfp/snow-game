extends Control

class_name UI

@onready var health_label: RichTextLabel = $HealthLabel
@onready var interactable_label: RichTextLabel = $InteractableLabel

func set_health_label(health: int) -> void:
	health_label.text = "Health: " + str(health)

func set_interactable_label(s: String) -> void:
	interactable_label.text = s

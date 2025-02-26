extends Control

class_name UI

@onready var health_label: RichTextLabel = $HealthLabel
@onready var stamina_label: RichTextLabel = $StaminaLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var interactable_label: RichTextLabel = $InteractableLabel

func set_health_label(health: int) -> void:
	health_label.text = "Health: " + str(health)
	health_bar.value = health
	

func set_stamina_label(stamina: float) -> void:
	stamina_label.text = "Stamina: " + str(stamina).pad_decimals(1)
	stamina_bar.value = stamina * 10.0

func set_interactable_label(s: String) -> void:
	interactable_label.text = s

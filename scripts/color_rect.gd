extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween: Tween = get_tree().create_tween()
	color.a = 1.0
	tween.tween_property(self, "color:a", 0, 20.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)


func _on_game_game_won() -> void:
	var tween: Tween = get_tree().create_tween()
	color.a = 0.0
	tween.tween_property(self, "color:a", 1.0, 10.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)

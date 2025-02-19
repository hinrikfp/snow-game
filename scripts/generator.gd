extends StaticBody3D
class_name Generator

signal generator_started()
signal generator_stopped()

@onready var active_sound: AudioStreamPlayer3D = $ActiveSound
@onready var failure_sound: AudioStreamPlayer3D = $FailureSound

enum GeneratorState {
	Broken,
	Fixed,
	Running,
}

var generator_state: GeneratorState = GeneratorState.Broken

func interact(player: Player) -> void:
	if generator_state == GeneratorState.Broken:
		if player.inventory.get("parts") >= 1:
			generator_state = GeneratorState.Fixed
			player.inventory["parts"] -= 1
		else:
			failure_sound.play()
	elif generator_state == GeneratorState.Fixed:
		active_sound.play(0)
		generator_state = GeneratorState.Running
		emit_signal("generator_started")
	elif generator_state == GeneratorState.Running:
		active_sound.stream_paused = true
		generator_state = GeneratorState.Fixed
		emit_signal("generator_stopped")

func get_generator_state() -> GeneratorState:
	return self.generator_state

func get_focus_message() -> String:
	match generator_state:
		GeneratorState.Broken:
			return "use parts to fix the generator"
		GeneratorState.Fixed:
			return "turn on generator"
		GeneratorState.Running:
			return "turn off generator"
	return "generator"

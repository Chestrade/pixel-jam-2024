extends Control

@onready var hoverSfx : AudioStreamPlayer = $Audio/Hover
@onready var pressedSfx : AudioStreamPlayer = $Audio/Pressed

func play_hover_sfx() -> void:
	hoverSfx.play()

func play_pressed_sfx() -> void:
	pressedSfx.play()

func _on_play_pressed() -> void:
	play_pressed_sfx()
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")
	
func _on_options_pressed() -> void:
	play_pressed_sfx()
	get_tree().change_scene_to_file("res://Scenes/UI/Options.tscn")

func _on_quit_pressed() -> void:
	play_pressed_sfx()
	get_tree().quit()


func _on_play_mouse_entered():
	play_hover_sfx()


func _on_options_mouse_entered():
	play_hover_sfx()


func _on_quit_mouse_entered():
	play_hover_sfx()

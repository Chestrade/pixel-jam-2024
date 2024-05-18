extends Control


var isPaused : bool = false


func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if isPaused:
			toggleMenu()
		else:
			toggleMenu()

func toggleMenu() -> void:
	if isPaused:
		hide()
		Engine.time_scale = 1
	else:
		show()
		Engine.time_scale = 0

	isPaused =!isPaused



func _on_resume_pressed() -> void:
	toggleMenu()

func _on_exit_pressed() -> void: #Return to main menu
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_quit_game_pressed() -> void: # Quit to desktop
	get_tree().quit




extends Node

var isPaused : bool = false
@export var pauseMenu : Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if isPaused:
			toggleMenu()
		else:
			toggleMenu()

func toggleMenu() -> void:
	if isPaused:
		pauseMenu.hide()
		Engine.time_scale = 1
	else:
		pauseMenu.show()
		Engine.time_scale = 0

	isPaused =!isPaused

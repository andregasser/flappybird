extends Node2D

@onready var swoosh: AudioStreamPlayer = $SwooshSound


func _ready() -> void:
	swoosh.play()


func _unhandled_input(event: InputEvent) -> void:
	var pressed := false
	if event is InputEventMouseButton and event.pressed:
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			pressed = true
	if pressed:
		get_tree().change_scene_to_file("res://scenes/Game.tscn")

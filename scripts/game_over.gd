extends Node2D

@onready var score_label: Label = $ScoreLabel
@onready var best_label: Label = $BestLabel
@onready var play_again_button: Button = $PlayAgainButton
@onready var menu_button: Button = $MenuButton
@onready var swoosh: AudioStreamPlayer = $SwooshSound


func _ready() -> void:
	swoosh.play()
	score_label.text = "Score: %d" % GameState.last_score
	best_label.text = "Best: %d" % GameState.get_highscore()
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

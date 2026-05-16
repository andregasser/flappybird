extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var point_sound: AudioStreamPlayer = $PointSound


func set_score(value: int) -> void:
	score_label.text = str(value)
	if value > 0:
		point_sound.play()

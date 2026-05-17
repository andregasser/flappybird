extends CanvasLayer

signal answered(correct: bool)

@onready var attempt_label: Label = $Panel/Layout/AttemptLabel
@onready var question_label: Label = $Panel/Layout/QuestionLabel
@onready var buttons: Array[Button] = [
	$Panel/Layout/ButtonGrid/Option0,
	$Panel/Layout/ButtonGrid/Option1,
	$Panel/Layout/ButtonGrid/Option2,
	$Panel/Layout/ButtonGrid/Option3,
]

var _correct_index: int = -1


func _ready() -> void:
	visible = false
	for i in range(buttons.size()):
		var idx := i
		buttons[i].pressed.connect(func(): _on_option_pressed(idx))


func show_puzzle(puzzle: Dictionary, attempt_number: int) -> void:
	_correct_index = int(puzzle["correct_index"])
	attempt_label.text = "Versuch %d/3" % attempt_number
	question_label.text = String(puzzle["question"])
	var options: Array = puzzle["options"]
	for i in range(buttons.size()):
		buttons[i].text = String(options[i])
		buttons[i].disabled = false
	visible = true


func hide_overlay() -> void:
	visible = false


func _on_option_pressed(idx: int) -> void:
	for b in buttons:
		b.disabled = true
	answered.emit(idx == _correct_index)

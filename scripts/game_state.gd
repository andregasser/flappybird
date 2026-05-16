extends Node

const SAVE_PATH := "user://highscore.save"

var last_score: int = 0
var highscore: int = 0


func _ready() -> void:
	_load()


func submit_score(score: int) -> void:
	last_score = score
	if score > highscore:
		highscore = score
		_save()


func get_highscore() -> int:
	return highscore


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open highscore file for writing")
		return
	file.store_string(JSON.stringify({"highscore": highscore}))
	file.close()


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var content := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("highscore"):
		highscore = int(parsed["highscore"])

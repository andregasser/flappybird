extends Node2D

enum State { WAITING, PLAYING, QUIZ, DEAD }

const PIPE_SCENE := preload("res://scenes/Pipe.tscn")
const VIEWPORT_HEIGHT := 768
const VIEWPORT_WIDTH := 432
const GROUND_TOP_Y := 672
const PIPE_GAP_MIN_Y := 200
const PIPE_GAP_MAX_Y := 568
const MAX_QUIZ_ATTEMPTS := 3

var state: State = State.WAITING
var score: int = 0
var quiz_attempts: int = 0

@onready var bird = $Bird
@onready var hud = $HUD
@onready var pipe_spawner: Timer = $PipeSpawner
@onready var pipes_container: Node2D = $Pipes
@onready var bgm: AudioStreamPlayer = $BGM
@onready var ground = $Ground
@onready var puzzle_overlay = $PuzzleOverlay


func _ready() -> void:
	randomize()
	bird.position = Vector2(100, 384)
	bird.frozen = true
	bird.died.connect(_on_bird_died)
	pipe_spawner.timeout.connect(_on_spawn_pipe)
	puzzle_overlay.answered.connect(_on_puzzle_answered)
	hud.set_score(0)
	PuzzleBank.start_round()
	_start_bgm()


func _start_bgm() -> void:
	if bgm.stream == null:
		return
	if "loop" in bgm.stream:
		bgm.stream.loop = true
	bgm.play()


func _unhandled_input(event: InputEvent) -> void:
	var pressed := false
	if event is InputEventMouseButton and event.pressed:
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			pressed = true

	if not pressed:
		return

	match state:
		State.WAITING:
			state = State.PLAYING
			pipe_spawner.start()
			bird.flap()
		State.PLAYING:
			bird.flap()
		State.QUIZ:
			pass
		State.DEAD:
			pass


func _on_spawn_pipe() -> void:
	var pipe = PIPE_SCENE.instantiate()
	pipes_container.add_child(pipe)
	pipe.position = Vector2(VIEWPORT_WIDTH + 50, 0)
	pipe.set_gap_center(randi_range(PIPE_GAP_MIN_Y, PIPE_GAP_MAX_Y))
	pipe.scored.connect(_on_pipe_scored)


func _on_pipe_scored() -> void:
	if state != State.PLAYING:
		return
	score += 1
	hud.set_score(score)


func _on_bird_died() -> void:
	if state == State.QUIZ or state == State.DEAD:
		return
	state = State.QUIZ
	quiz_attempts = 0
	_pause_world()
	_show_next_puzzle()


func _pause_world() -> void:
	bird.frozen = true
	pipe_spawner.stop()
	for pipe in pipes_container.get_children():
		pipe.set_process(false)
	ground.set_process(false)
	bgm.stream_paused = true


func _resume_world() -> void:
	pipe_spawner.start()
	for pipe in pipes_container.get_children():
		pipe.set_process(true)
	ground.set_process(true)
	bgm.stream_paused = false


func _show_next_puzzle() -> void:
	var puzzle = PuzzleBank.next_puzzle()
	puzzle_overlay.show_puzzle(puzzle, quiz_attempts + 1)


func _on_puzzle_answered(correct: bool) -> void:
	if correct:
		quiz_attempts = 0
		puzzle_overlay.hide_overlay()
		_clear_pipes_ahead()
		_resume_world()
		bird.revive()
		state = State.PLAYING
	else:
		quiz_attempts += 1
		if quiz_attempts >= MAX_QUIZ_ATTEMPTS:
			puzzle_overlay.hide_overlay()
			_trigger_game_over()
		else:
			_show_next_puzzle()


func _clear_pipes_ahead() -> void:
	for pipe in pipes_container.get_children():
		if pipe.position.x > bird.position.x:
			pipe.queue_free()


func _trigger_game_over() -> void:
	state = State.DEAD
	pipe_spawner.stop()
	for pipe in pipes_container.get_children():
		pipe.set_process(false)
	if bgm.playing:
		var bgm_tween := create_tween()
		bgm_tween.tween_property(bgm, "volume_db", -40.0, 0.6)
		bgm_tween.tween_callback(bgm.stop)
	GameState.submit_score(score)
	var tween := create_tween()
	tween.tween_interval(0.8)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
	)

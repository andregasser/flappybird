extends Node2D

enum State { WAITING, PLAYING, DEAD }

const PIPE_SCENE := preload("res://scenes/Pipe.tscn")
const VIEWPORT_HEIGHT := 768
const VIEWPORT_WIDTH := 432
const GROUND_TOP_Y := 672
const PIPE_GAP_MIN_Y := 200
const PIPE_GAP_MAX_Y := 568

var state: State = State.WAITING
var score: int = 0

@onready var bird = $Bird
@onready var hud = $HUD
@onready var pipe_spawner: Timer = $PipeSpawner
@onready var pipes_container: Node2D = $Pipes


func _ready() -> void:
	randomize()
	bird.position = Vector2(100, 384)
	bird.frozen = true
	bird.died.connect(_on_bird_died)
	pipe_spawner.timeout.connect(_on_spawn_pipe)
	hud.set_score(0)


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
		State.DEAD:
			pass


func _on_spawn_pipe() -> void:
	var pipe = PIPE_SCENE.instantiate()
	pipes_container.add_child(pipe)
	pipe.position = Vector2(VIEWPORT_WIDTH + 50, 0)
	pipe.set_gap_center(randi_range(PIPE_GAP_MIN_Y, PIPE_GAP_MAX_Y))
	pipe.scored.connect(_on_pipe_scored)


func _on_pipe_scored() -> void:
	score += 1
	hud.set_score(score)


func _on_bird_died() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	pipe_spawner.stop()
	# Stop all pipes from moving
	for pipe in pipes_container.get_children():
		pipe.set_process(false)
	# Wait briefly, then transition to GameOver
	GameState.submit_score(score)
	var tween := create_tween()
	tween.tween_interval(0.8)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
	)

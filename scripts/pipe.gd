extends Node2D

signal scored

const SPEED := 85.0
const GAP_SIZE := 170.0

@onready var top_pipe: Sprite2D = $TopPipe
@onready var bottom_pipe: Sprite2D = $BottomPipe
@onready var top_collision: CollisionShape2D = $TopBody/TopCollision
@onready var bottom_collision: CollisionShape2D = $BottomBody/BottomCollision
@onready var score_zone: Area2D = $ScoreZone

var pipe_height: float


func _ready() -> void:
	pipe_height = top_pipe.texture.get_height()
	score_zone.body_entered.connect(_on_score_zone_entered)


func set_gap_center(y: float) -> void:
	# top pipe sits with its bottom edge at (gap_center - GAP_SIZE/2)
	top_pipe.position = Vector2(0, y - GAP_SIZE / 2.0 - pipe_height)
	bottom_pipe.position = Vector2(0, y + GAP_SIZE / 2.0)
	# Collision shapes (rectangles centered at the sprite midpoint)
	top_collision.position = Vector2(top_pipe.texture.get_width() / 2.0,
		top_pipe.position.y + pipe_height / 2.0)
	bottom_collision.position = Vector2(bottom_pipe.texture.get_width() / 2.0,
		bottom_pipe.position.y + pipe_height / 2.0)
	# Score zone covers the gap
	$ScoreZone/ScoreCollision.position = Vector2(top_pipe.texture.get_width() / 2.0, y)


func _process(delta: float) -> void:
	position.x -= SPEED * delta
	if position.x < -150:
		queue_free()


func _on_score_zone_entered(_body: Node2D) -> void:
	scored.emit()
	score_zone.set_deferred("monitoring", false)

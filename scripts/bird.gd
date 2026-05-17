extends CharacterBody2D

signal died

const GRAVITY := 700.0
const FLAP_VELOCITY := -280.0
const MAX_FALL_SPEED := 450.0
const GROUND_TOP_Y := 672.0

var frozen: bool = true
var dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flap_sound: AudioStreamPlayer = $FlapSound
@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var die_sound: AudioStreamPlayer = $DieSound


func _ready() -> void:
	sprite.play("flap")


func _physics_process(delta: float) -> void:
	if frozen or dead:
		return
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)
	rotation = clamp(velocity.y / 600.0, -0.5, 1.2)
	move_and_slide()
	if get_slide_collision_count() > 0:
		die()
	elif global_position.y > GROUND_TOP_Y:
		die()


func flap() -> void:
	if dead:
		return
	frozen = false
	velocity.y = FLAP_VELOCITY
	flap_sound.play()


func die() -> void:
	if dead:
		return
	dead = true
	hit_sound.play()
	# Play die sound shortly after hit so they don't overlap
	var tween := create_tween()
	tween.tween_interval(0.4)
	tween.tween_callback(func(): die_sound.play())
	died.emit()

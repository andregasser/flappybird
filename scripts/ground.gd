extends Node2D

const SCROLL_SPEED := 100.0

@onready var tile_a: Sprite2D = $TileA
@onready var tile_b: Sprite2D = $TileB

var tile_width: float


func _ready() -> void:
	tile_width = tile_a.texture.get_width()
	tile_b.position.x = tile_a.position.x + tile_width


func _process(delta: float) -> void:
	tile_a.position.x -= SCROLL_SPEED * delta
	tile_b.position.x -= SCROLL_SPEED * delta
	if tile_a.position.x <= -tile_width:
		tile_a.position.x = tile_b.position.x + tile_width
	if tile_b.position.x <= -tile_width:
		tile_b.position.x = tile_a.position.x + tile_width

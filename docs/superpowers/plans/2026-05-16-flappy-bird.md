# Flappy Bird Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete Flappy Bird clone in Godot 4 with classic pixel-art assets, sound effects, and a locally persisted highscore.

**Architecture:** Classical Godot scene composition — each entity (Bird, Pipe, Ground, HUD, Menus) is its own `.tscn` scene with a paired GDScript. A `GameState` autoload singleton manages cross-scene state. All inter-scene communication uses Godot signals.

**Tech Stack:** Godot 4.6.2 (stable), GDScript, classic Flappy Bird assets from `samuelcust/flappy-bird-assets`.

**Working directory:** `/Users/taagaanf/Documents/Projects/flappybird/`

> **Note on testing:** Godot has no built-in unit-test framework, and the spec explicitly relies on manual visual/timing verification. Each task therefore ends with a "Build & Verify" step (run the editor or game and confirm a specific behavior) instead of an automated test. Frequent commits are still mandatory.

---

## Task 1: Project Setup

**Files:**
- Create: `project.godot`
- Create: `.gitignore`
- Create: `icon.svg`

- [ ] **Step 1: Initialize git repo**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
git init
git config user.email "andre.gasser@protonmail.com"
git config user.name "Andre Gasser"
```

- [ ] **Step 2: Create `.gitignore`**

Create `/Users/taagaanf/Documents/Projects/flappybird/.gitignore`:

```gitignore
# Godot 4 specific
.godot/
.import/
export.cfg
export_presets.cfg

# Mono / C# (unused, but defensive)
.mono/
data_*/
mono_crash.*.json

# macOS
.DS_Store

# Editor
*.swp
*~
```

- [ ] **Step 3: Create `project.godot`**

Create `/Users/taagaanf/Documents/Projects/flappybird/project.godot`:

```ini
; Engine configuration file.
;
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="Flappy Bird"
config/features=PackedStringArray("4.6", "GL Compatibility")
config/icon="res://icon.svg"

[display]

window/size/viewport_width=432
window/size/viewport_height=768
window/stretch/mode="viewport"
window/stretch/aspect="keep"

[physics]

2d/default_gravity=0.0

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=0
```

> The `default_texture_filter=0` setting is `Nearest` — preserves crisp pixel-art without bilinear smoothing.

- [ ] **Step 4: Create a placeholder `icon.svg`**

Create `/Users/taagaanf/Documents/Projects/flappybird/icon.svg`:

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect width="128" height="128" fill="#70c5ce"/>
  <circle cx="64" cy="64" r="32" fill="#ffd83d"/>
  <circle cx="76" cy="56" r="6" fill="#ffffff"/>
  <circle cx="78" cy="56" r="3" fill="#000000"/>
</svg>
```

- [ ] **Step 5: Verify project loads in Godot**

Run:
```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 2>&1 | tail -20
```

Expected: lines like `Editor and documentation translations loaded.` and exit code 0. No errors about missing scenes (the main scene is unset for now — that's fine).

- [ ] **Step 6: Initial commit**

```bash
git add .gitignore project.godot icon.svg docs/
git commit -m "chore: initial Godot 4 project scaffold"
```

---

## Task 2: Download and Organize Assets

**Files:**
- Create: `assets/sprites/` (multiple .png files)
- Create: `assets/audio/` (multiple .ogg files)

- [ ] **Step 1: Clone the asset repo to a temp location**

```bash
cd /tmp
rm -rf flappy-bird-assets
git clone --depth 1 https://github.com/samuelcust/flappy-bird-assets.git
ls flappy-bird-assets/sprites/
ls flappy-bird-assets/audio/
```

Expected output for sprites: `0.png 1.png ... 9.png background-day.png background-night.png base.png bluebird-downflap.png ... gameover.png message.png pipe-green.png pipe-red.png redbird-... yellowbird-downflap.png yellowbird-midflap.png yellowbird-upflap.png`

Expected output for audio: `die.ogg hit.ogg point.ogg swoosh.ogg wing.ogg` (or `.wav` variants).

- [ ] **Step 2: Copy required sprites**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
mkdir -p assets/sprites assets/audio

cp /tmp/flappy-bird-assets/sprites/background-day.png   assets/sprites/
cp /tmp/flappy-bird-assets/sprites/base.png             assets/sprites/
cp /tmp/flappy-bird-assets/sprites/yellowbird-upflap.png   assets/sprites/
cp /tmp/flappy-bird-assets/sprites/yellowbird-midflap.png  assets/sprites/
cp /tmp/flappy-bird-assets/sprites/yellowbird-downflap.png assets/sprites/
cp /tmp/flappy-bird-assets/sprites/pipe-green.png       assets/sprites/
cp /tmp/flappy-bird-assets/sprites/message.png          assets/sprites/
cp /tmp/flappy-bird-assets/sprites/gameover.png         assets/sprites/

ls assets/sprites/
```

Expected: 8 .png files listed.

- [ ] **Step 3: Copy required audio**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird

# Audio in the upstream repo is .ogg
cp /tmp/flappy-bird-assets/audio/wing.ogg    assets/audio/
cp /tmp/flappy-bird-assets/audio/hit.ogg     assets/audio/
cp /tmp/flappy-bird-assets/audio/die.ogg     assets/audio/
cp /tmp/flappy-bird-assets/audio/point.ogg   assets/audio/
cp /tmp/flappy-bird-assets/audio/swoosh.ogg  assets/audio/

ls assets/audio/
```

Expected: 5 .ogg files listed.

> **Fallback if upstream uses `.wav`:** copy the `.wav` files instead and adjust the `path = ...` lines in later scene files from `.ogg` to `.wav`.

- [ ] **Step 4: Trigger Godot asset import (creates `.import` metadata)**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --import 2>&1 | tail -30
```

Expected: lines like `Importing: res://assets/sprites/yellowbird-midflap.png`, no errors. After this, every asset has a sibling `.import` file.

- [ ] **Step 5: Verify imports succeeded**

```bash
ls assets/sprites/*.import | wc -l
ls assets/audio/*.import | wc -l
```

Expected: `8` and `5` respectively.

- [ ] **Step 6: Commit**

```bash
git add assets/
git commit -m "feat(assets): add Flappy Bird sprites and audio from samuelcust/flappy-bird-assets"
```

---

## Task 3: GameState Autoload (Highscore Persistence)

**Files:**
- Create: `scripts/game_state.gd`
- Modify: `project.godot` (add `[autoload]` section)

- [ ] **Step 1: Create `scripts/game_state.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/game_state.gd`:

```gdscript
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
```

- [ ] **Step 2: Register autoload in `project.godot`**

Append the following section to `/Users/taagaanf/Documents/Projects/flappybird/project.godot`:

```ini

[autoload]

GameState="*res://scripts/game_state.gd"
```

> The leading `*` makes it a singleton autoload (accessible as `GameState` from any script).

- [ ] **Step 3: Verify autoload loads without error**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 2>&1 | tail -10
```

Expected: no `SCRIPT ERROR` lines, exit code 0.

- [ ] **Step 4: Commit**

```bash
git add scripts/game_state.gd project.godot
git commit -m "feat(state): add GameState autoload with highscore persistence"
```

---

## Task 4: Bird Scene

**Files:**
- Create: `scripts/bird.gd`
- Create: `scenes/Bird.tscn`
- Create: `scenes/bird_frames.tres` (SpriteFrames resource)

- [ ] **Step 1: Create `scripts/bird.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/bird.gd`:

```gdscript
extends CharacterBody2D

signal died

const GRAVITY := 1400.0
const FLAP_VELOCITY := -400.0
const MAX_FALL_SPEED := 700.0

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
```

- [ ] **Step 2: Create the SpriteFrames resource for the bird animation**

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/bird_frames.tres`:

```tres
[gd_resource type="SpriteFrames" load_steps=4 format=3]

[ext_resource type="Texture2D" path="res://assets/sprites/yellowbird-upflap.png" id="1_up"]
[ext_resource type="Texture2D" path="res://assets/sprites/yellowbird-midflap.png" id="2_mid"]
[ext_resource type="Texture2D" path="res://assets/sprites/yellowbird-downflap.png" id="3_down"]

[resource]
animations = [{
"frames": [{
"duration": 1.0,
"texture": ExtResource("1_up")
}, {
"duration": 1.0,
"texture": ExtResource("2_mid")
}, {
"duration": 1.0,
"texture": ExtResource("3_down")
}, {
"duration": 1.0,
"texture": ExtResource("2_mid")
}],
"loop": true,
"name": &"flap",
"speed": 10.0
}]
```

- [ ] **Step 3: Create `scenes/Bird.tscn`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/Bird.tscn`:

```tscn
[gd_scene load_steps=7 format=3]

[ext_resource type="Script" path="res://scripts/bird.gd" id="1_script"]
[ext_resource type="SpriteFrames" path="res://scenes/bird_frames.tres" id="2_frames"]
[ext_resource type="AudioStream" path="res://assets/audio/wing.ogg" id="3_wing"]
[ext_resource type="AudioStream" path="res://assets/audio/hit.ogg" id="4_hit"]
[ext_resource type="AudioStream" path="res://assets/audio/die.ogg" id="5_die"]

[sub_resource type="CircleShape2D" id="CircleShape2D_1"]
radius = 12.0

[node name="Bird" type="CharacterBody2D"]
script = ExtResource("1_script")

[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]
sprite_frames = ExtResource("2_frames")
animation = &"flap"
autoplay = "flap"

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CircleShape2D_1")

[node name="FlapSound" type="AudioStreamPlayer" parent="."]
stream = ExtResource("3_wing")

[node name="HitSound" type="AudioStreamPlayer" parent="."]
stream = ExtResource("4_hit")

[node name="DieSound" type="AudioStreamPlayer" parent="."]
stream = ExtResource("5_die")
```

- [ ] **Step 4: Verify the scene loads**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 --script - <<'EOF' 2>&1 | tail -20
extends SceneTree
func _init():
    var scene := load("res://scenes/Bird.tscn")
    if scene == null:
        print("FAIL: scene did not load")
        quit(1)
    var inst = scene.instantiate()
    print("OK: Bird scene instantiated, type=" + inst.get_class())
    quit(0)
EOF
```

Expected: `OK: Bird scene instantiated, type=CharacterBody2D` and exit code 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/bird.gd scenes/Bird.tscn scenes/bird_frames.tres
git commit -m "feat(bird): add Bird scene with physics, animation, and sounds"
```

---

## Task 5: Ground Scene

**Files:**
- Create: `scripts/ground.gd`
- Create: `scenes/Ground.tscn`

- [ ] **Step 1: Create `scripts/ground.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/ground.gd`:

```gdscript
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
```

- [ ] **Step 2: Create `scenes/Ground.tscn`**

The ground sprite is centered on its origin by default. We anchor the Ground node at y=672 (768 - 96 ≈ ground position) and the StaticBody collision spans the visible band.

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/Ground.tscn`:

```tscn
[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://scripts/ground.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/base.png" id="2_base"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_1"]
size = Vector2(432, 112)

[node name="Ground" type="Node2D"]
script = ExtResource("1_script")
position = Vector2(0, 672)

[node name="TileA" type="Sprite2D" parent="."]
texture = ExtResource("2_base")
centered = false
position = Vector2(0, 0)

[node name="TileB" type="Sprite2D" parent="."]
texture = ExtResource("2_base")
centered = false
position = Vector2(0, 0)

[node name="StaticBody2D" type="StaticBody2D" parent="."]
position = Vector2(216, 56)

[node name="CollisionShape2D" type="CollisionShape2D" parent="StaticBody2D"]
shape = SubResource("RectangleShape2D_1")
```

- [ ] **Step 3: Verify the scene loads**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 --script - <<'EOF' 2>&1 | tail -20
extends SceneTree
func _init():
    var inst = load("res://scenes/Ground.tscn").instantiate()
    print("OK: Ground instantiated, child count=" + str(inst.get_child_count()))
    quit(0)
EOF
```

Expected: `OK: Ground instantiated, child count=3` and exit code 0.

- [ ] **Step 4: Commit**

```bash
git add scripts/ground.gd scenes/Ground.tscn
git commit -m "feat(ground): add scrolling ground scene with collision"
```

---

## Task 6: Pipe Scene

**Files:**
- Create: `scripts/pipe.gd`
- Create: `scenes/Pipe.tscn`

- [ ] **Step 1: Create `scripts/pipe.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/pipe.gd`:

```gdscript
extends Node2D

signal scored

const SPEED := 100.0
const GAP_SIZE := 130.0

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
```

- [ ] **Step 2: Create `scenes/Pipe.tscn`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/Pipe.tscn`:

```tscn
[gd_scene load_steps=5 format=3]

[ext_resource type="Script" path="res://scripts/pipe.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/pipe-green.png" id="2_pipe"]

[sub_resource type="RectangleShape2D" id="RectShape_pipe"]
size = Vector2(52, 320)

[sub_resource type="RectangleShape2D" id="RectShape_score"]
size = Vector2(8, 130)

[node name="Pipe" type="Node2D"]
script = ExtResource("1_script")

[node name="TopPipe" type="Sprite2D" parent="."]
texture = ExtResource("2_pipe")
centered = false
flip_v = true

[node name="BottomPipe" type="Sprite2D" parent="."]
texture = ExtResource("2_pipe")
centered = false

[node name="TopBody" type="StaticBody2D" parent="."]

[node name="TopCollision" type="CollisionShape2D" parent="TopBody"]
shape = SubResource("RectShape_pipe")

[node name="BottomBody" type="StaticBody2D" parent="."]

[node name="BottomCollision" type="CollisionShape2D" parent="BottomBody"]
shape = SubResource("RectShape_pipe")

[node name="ScoreZone" type="Area2D" parent="."]

[node name="ScoreCollision" type="CollisionShape2D" parent="ScoreZone"]
shape = SubResource("RectShape_score")
```

- [ ] **Step 3: Verify the scene loads and `set_gap_center` runs**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 --script - <<'EOF' 2>&1 | tail -20
extends SceneTree
func _init():
    var inst = load("res://scenes/Pipe.tscn").instantiate()
    root.add_child(inst)
    inst.set_gap_center(400)
    print("OK: Pipe instantiated and set_gap_center(400) ran")
    quit(0)
EOF
```

Expected: `OK: Pipe instantiated and set_gap_center(400) ran` and no errors.

- [ ] **Step 4: Commit**

```bash
git add scripts/pipe.gd scenes/Pipe.tscn
git commit -m "feat(pipe): add Pipe scene with movement, collision, and score trigger"
```

---

## Task 7: HUD Scene

**Files:**
- Create: `scripts/hud.gd`
- Create: `scenes/HUD.tscn`

- [ ] **Step 1: Create `scripts/hud.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/hud.gd`:

```gdscript
extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var point_sound: AudioStreamPlayer = $PointSound


func set_score(value: int) -> void:
	score_label.text = str(value)
	if value > 0:
		point_sound.play()
```

- [ ] **Step 2: Create `scenes/HUD.tscn`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/HUD.tscn`:

```tscn
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://scripts/hud.gd" id="1_script"]
[ext_resource type="AudioStream" path="res://assets/audio/point.ogg" id="2_point"]

[node name="HUD" type="CanvasLayer"]
script = ExtResource("1_script")

[node name="ScoreLabel" type="Label" parent="."]
anchor_left = 0.5
anchor_right = 0.5
offset_left = -50.0
offset_top = 40.0
offset_right = 50.0
offset_bottom = 100.0
text = "0"
horizontal_alignment = 1
vertical_alignment = 1
theme_override_font_sizes/font_size = 48

[node name="PointSound" type="AudioStreamPlayer" parent="."]
stream = ExtResource("2_point")
```

- [ ] **Step 3: Verify the scene loads**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 --script - <<'EOF' 2>&1 | tail -20
extends SceneTree
func _init():
    var inst = load("res://scenes/HUD.tscn").instantiate()
    inst.set_score(7)
    print("OK: HUD label after set_score(7) = " + inst.get_node("ScoreLabel").text)
    quit(0)
EOF
```

Expected: `OK: HUD label after set_score(7) = 7`.

- [ ] **Step 4: Commit**

```bash
git add scripts/hud.gd scenes/HUD.tscn
git commit -m "feat(hud): add in-game score HUD with point sound"
```

---

## Task 8: Game Scene (Gameplay Loop)

**Files:**
- Create: `scripts/game.gd`
- Create: `scenes/Game.tscn`

- [ ] **Step 1: Create `scripts/game.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/game.gd`:

```gdscript
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
```

- [ ] **Step 2: Create `scenes/Game.tscn`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/Game.tscn`:

```tscn
[gd_scene load_steps=6 format=3]

[ext_resource type="Script" path="res://scripts/game.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/background-day.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/Bird.tscn" id="3_bird"]
[ext_resource type="PackedScene" path="res://scenes/Ground.tscn" id="4_ground"]
[ext_resource type="PackedScene" path="res://scenes/HUD.tscn" id="5_hud"]

[node name="Game" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
texture = ExtResource("2_bg")
centered = false
position = Vector2(0, 0)
scale = Vector2(1.5, 1.5)

[node name="Pipes" type="Node2D" parent="."]

[node name="Bird" parent="." instance=ExtResource("3_bird")]
position = Vector2(100, 384)

[node name="Ground" parent="." instance=ExtResource("4_ground")]

[node name="PipeSpawner" type="Timer" parent="."]
wait_time = 1.5
autostart = false

[node name="HUD" parent="." instance=ExtResource("5_hud")]
```

> The background sprite is 288×512; scaling 1.5× covers the 432×768 viewport.

- [ ] **Step 3: Set Game.tscn as the temporary main scene for end-to-end testing**

This is temporary — Task 9 will swap it for `MainMenu.tscn`.

Edit `/Users/taagaanf/Documents/Projects/flappybird/project.godot`. In the `[application]` section, add:

```ini
run/main_scene="res://scenes/Game.tscn"
```

The `[application]` section should now look like:

```ini
[application]

config/name="Flappy Bird"
config/features=PackedStringArray("4.6", "GL Compatibility")
config/icon="res://icon.svg"
run/main_scene="res://scenes/Game.tscn"
```

- [ ] **Step 4: Run the game and play-test**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot 2>&1 | tail -20
```

The game window should open. Manual checks:
1. Bird visible at left center, flapping animation runs
2. Click → bird jumps, ground starts scrolling, pipes start spawning from the right
3. Fly through a pipe gap → score in HUD goes up + point sound
4. Hit a pipe or ground → bird stops, hit sound + die sound (~0.4s apart) → after ~0.8s the game tries to load `GameOver.tscn` (will error since not yet created — that's fine, close the window)

Quit the game (Cmd+Q).

> If the bird falls through the ground, the collision rectangle in `Ground.tscn` may need to be repositioned. Open Ground.tscn in the Godot editor, select `StaticBody2D/CollisionShape2D`, and verify the rectangle covers the visible base sprite.

- [ ] **Step 5: Commit**

```bash
git add scripts/game.gd scenes/Game.tscn project.godot
git commit -m "feat(game): add main gameplay scene with state machine and pipe spawner"
```

---

## Task 9: MainMenu Scene

**Files:**
- Create: `scripts/main_menu.gd`
- Create: `scenes/MainMenu.tscn`
- Modify: `project.godot` (change `run/main_scene`)

- [ ] **Step 1: Create `scripts/main_menu.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/main_menu.gd`:

```gdscript
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
```

- [ ] **Step 2: Create `scenes/MainMenu.tscn`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/MainMenu.tscn`:

```tscn
[gd_scene load_steps=5 format=3]

[ext_resource type="Script" path="res://scripts/main_menu.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/background-day.png" id="2_bg"]
[ext_resource type="Texture2D" path="res://assets/sprites/message.png" id="3_msg"]
[ext_resource type="AudioStream" path="res://assets/audio/swoosh.ogg" id="4_swoosh"]

[node name="MainMenu" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
texture = ExtResource("2_bg")
centered = false
position = Vector2(0, 0)
scale = Vector2(1.5, 1.5)

[node name="Message" type="Sprite2D" parent="."]
texture = ExtResource("3_msg")
position = Vector2(216, 384)
scale = Vector2(1.5, 1.5)

[node name="SwooshSound" type="AudioStreamPlayer" parent="."]
stream = ExtResource("4_swoosh")
```

- [ ] **Step 3: Update `project.godot` to use MainMenu as the main scene**

In `/Users/taagaanf/Documents/Projects/flappybird/project.godot`, change:

```ini
run/main_scene="res://scenes/Game.tscn"
```

to:

```ini
run/main_scene="res://scenes/MainMenu.tscn"
```

- [ ] **Step 4: Verify scene loads and main scene change works**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 --script - <<'EOF' 2>&1 | tail -20
extends SceneTree
func _init():
    var inst = load("res://scenes/MainMenu.tscn").instantiate()
    print("OK: MainMenu instantiated, child count=" + str(inst.get_child_count()))
    quit(0)
EOF
```

Expected: `OK: MainMenu instantiated, child count=3`.

- [ ] **Step 5: Commit**

```bash
git add scripts/main_menu.gd scenes/MainMenu.tscn project.godot
git commit -m "feat(menu): add MainMenu scene with Get Ready banner"
```

---

## Task 10: GameOver Scene

**Files:**
- Create: `scripts/game_over.gd`
- Create: `scenes/GameOver.tscn`

- [ ] **Step 1: Create `scripts/game_over.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/game_over.gd`:

```gdscript
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
```

- [ ] **Step 2: Create `scenes/GameOver.tscn`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/GameOver.tscn`:

```tscn
[gd_scene load_steps=5 format=3]

[ext_resource type="Script" path="res://scripts/game_over.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/background-day.png" id="2_bg"]
[ext_resource type="Texture2D" path="res://assets/sprites/gameover.png" id="3_over"]
[ext_resource type="AudioStream" path="res://assets/audio/swoosh.ogg" id="4_swoosh"]

[node name="GameOver" type="Node2D"]
script = ExtResource("1_script")

[node name="Background" type="Sprite2D" parent="."]
texture = ExtResource("2_bg")
centered = false
position = Vector2(0, 0)
scale = Vector2(1.5, 1.5)

[node name="GameOverBanner" type="Sprite2D" parent="."]
texture = ExtResource("3_over")
position = Vector2(216, 220)
scale = Vector2(1.5, 1.5)

[node name="ScoreLabel" type="Label" parent="."]
offset_left = 116.0
offset_top = 320.0
offset_right = 316.0
offset_bottom = 360.0
text = "Score: 0"
horizontal_alignment = 1
theme_override_font_sizes/font_size = 32

[node name="BestLabel" type="Label" parent="."]
offset_left = 116.0
offset_top = 370.0
offset_right = 316.0
offset_bottom = 410.0
text = "Best: 0"
horizontal_alignment = 1
theme_override_font_sizes/font_size = 32

[node name="PlayAgainButton" type="Button" parent="."]
offset_left = 116.0
offset_top = 450.0
offset_right = 316.0
offset_bottom = 500.0
text = "Play Again"

[node name="MenuButton" type="Button" parent="."]
offset_left = 116.0
offset_top = 520.0
offset_right = 316.0
offset_bottom = 570.0
text = "Main Menu"

[node name="SwooshSound" type="AudioStreamPlayer" parent="."]
stream = ExtResource("4_swoosh")
```

- [ ] **Step 3: Verify scene loads**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 --script - <<'EOF' 2>&1 | tail -20
extends SceneTree
func _init():
    var inst = load("res://scenes/GameOver.tscn").instantiate()
    print("OK: GameOver instantiated")
    quit(0)
EOF
```

Expected: `OK: GameOver instantiated`.

- [ ] **Step 4: Commit**

```bash
git add scripts/game_over.gd scenes/GameOver.tscn
git commit -m "feat(gameover): add GameOver scene with score, highscore, and restart"
```

---

## Task 11: End-to-End Manual Verification

**Files:** none (verification only — fixes go into a follow-up commit if needed)

- [ ] **Step 1: Launch and run the full flow**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot
```

- [ ] **Step 2: Verify spec test plan, item by item**

Walk through every numbered check from the spec's Testing Plan section:

1. MainMenu shows on launch with the "Get Ready" banner
2. Click → Game scene loads, bird hovers
3. Click → bird flaps, pipes start spawning, ground scrolls
4. Fly through a pipe gap → score increments by 1, point sound plays
5. Hit a pipe → ~0.8s freeze with hit + die sounds → GameOver shows correct final score
6. First playthrough sets the highscore; second playthrough only overwrites if higher
7. Restart from GameOver ("Play Again") → fresh game, no leftover pipes
8. Quit and relaunch → previous highscore still displayed on the GameOver screen
9. Resize the window → letterboxed, gameplay still works at logical 432×768
10. All sounds: flap on each tap, point on each pipe pass, hit + die on collision, swoosh on entering MainMenu/GameOver

- [ ] **Step 3: If any check fails, fix and commit**

Example commit messages for fixes:
- `fix(pipe): correct collision rectangle position so bird can clear the gap`
- `fix(ground): scroll second tile based on first tile width, not viewport width`

- [ ] **Step 4: Final smoke commit if anything was tweaked**

If no fixes were necessary, skip this step. Otherwise:

```bash
git add -A
git commit -m "fix: address issues found during end-to-end verification"
```

- [ ] **Step 5: Print summary**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
git log --oneline
```

Expected: ~10–11 commits, one per task.

---

## Self-Review Notes

- **Spec coverage:** Project setup ✓ (T1), Assets ✓ (T2), GameState autoload + highscore ✓ (T3), Bird with physics + sounds ✓ (T4), Ground scroll + collision ✓ (T5), Pipe with movement + score trigger ✓ (T6), HUD ✓ (T7), Game state machine + spawner ✓ (T8), MainMenu ✓ (T9), GameOver ✓ (T10), end-to-end test plan ✓ (T11). Audio integration covered in T4/T7/T9/T10. Project settings (resolution, autoload, main scene) covered across T1/T3/T9.
- **Placeholder scan:** No "TBD"/"TODO"/"implement later" in the plan. Each step has either complete code or a complete shell command.
- **Type consistency:** `bird.flap()`, `bird.died` signal, `bird.frozen` field, `pipe.scored` signal, `pipe.set_gap_center(y)`, `hud.set_score(value)`, `GameState.submit_score(score)`, `GameState.get_highscore()`, `GameState.last_score` are all defined in their respective scripts and called consistently across consumers (game.gd, game_over.gd).
- **Scope:** Single implementation plan, ~10 small tasks each producing a working commit.

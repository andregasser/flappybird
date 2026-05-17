# Pipe-Collision Animal Puzzle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When the bird collides with a pipe, show an animal-knowledge multiple-choice puzzle. Up to 3 attempts to revive the bird; 3 wrong answers triggers the normal Game Over flow.

**Architecture:** Inline `PuzzleOverlay` CanvasLayer in the existing `Game.tscn` — gameplay nodes are paused in place (no scene transitions). A new `PuzzleBank` autoload owns a 15-question pool and dispenses puzzles without repeats per session. The Bird gains a `revive()` method with a 1-second invincibility flash.

**Tech Stack:** Godot 4.6.2 stable, GDScript. Builds on the existing Flappy Bird codebase.

**Working directory:** `/Users/taagaanf/Documents/Projects/flappybird/`

**Spec:** `docs/superpowers/specs/2026-05-17-pipe-puzzle-feature-design.md`

> **Note on testing:** consistent with the rest of the project, this plan uses headless scene-load verification (`godot --headless --script ...`) and a manual playtest at the end. No automated unit tests — Godot has no built-in framework and the feature is UI/timing-driven.

---

## Task 1: PuzzleBank Autoload

**Files:**
- Create: `scripts/puzzle_bank.gd`
- Modify: `project.godot` (add second autoload)

- [ ] **Step 1: Create `scripts/puzzle_bank.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/puzzle_bank.gd` with the following exact content (tabs for indentation):

```gdscript
extends Node

const POOL: Array = [
	{
		"question": "Wie viele Beine hat eine Spinne?",
		"options": ["6", "8", "10", "4"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier macht 'Muh'?",
		"options": ["Schaf", "Kuh", "Ziege", "Pferd"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier kann fliegen, ist aber kein Vogel?",
		"options": ["Eichhörnchen", "Fledermaus", "Frosch", "Eidechse"],
		"correct_index": 1,
	},
	{
		"question": "Was ist das grösste Säugetier?",
		"options": ["Elefant", "Blauwal", "Giraffe", "Eisbär"],
		"correct_index": 1,
	},
	{
		"question": "Wie schläft ein Flamingo?",
		"options": ["liegend", "auf einem Bein", "im Wasser", "fliegend"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier hat einen Höcker?",
		"options": ["Pferd", "Kamel", "Zebra", "Elefant"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier legt Eier und ist ein Säugetier?",
		"options": ["Igel", "Schnabeltier", "Maus", "Hase"],
		"correct_index": 1,
	},
	{
		"question": "Wie viele Herzen hat ein Oktopus?",
		"options": ["1", "2", "3", "8"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier wechselt seine Farbe?",
		"options": ["Frosch", "Schlange", "Chamäleon", "Eidechse"],
		"correct_index": 2,
	},
	{
		"question": "Welcher Vogel kann nicht fliegen?",
		"options": ["Adler", "Spatz", "Pinguin", "Taube"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier hat ein Geweih?",
		"options": ["Wildschwein", "Hirsch", "Wolf", "Bär"],
		"correct_index": 1,
	},
	{
		"question": "Welches Tier lebt im Polarkreis?",
		"options": ["Löwe", "Tiger", "Eisbär", "Giraffe"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier hört mit den Beinen?",
		"options": ["Schmetterling", "Käfer", "Grille", "Biene"],
		"correct_index": 2,
	},
	{
		"question": "Was frisst ein Panda hauptsächlich?",
		"options": ["Fisch", "Fleisch", "Bambus", "Insekten"],
		"correct_index": 2,
	},
	{
		"question": "Welches Tier hat die längste Zunge im Verhältnis zum Körper?",
		"options": ["Schlange", "Frosch", "Chamäleon", "Kuh"],
		"correct_index": 2,
	},
]

var remaining: Array = []


func start_round() -> void:
	remaining = POOL.duplicate()
	remaining.shuffle()


func next_puzzle() -> Dictionary:
	if remaining.is_empty():
		# Refill if exhausted (rare: ≥15 collisions in one round)
		remaining = POOL.duplicate()
		remaining.shuffle()
	return remaining.pop_back()
```

- [ ] **Step 2: Register autoload in `project.godot`**

Open `/Users/taagaanf/Documents/Projects/flappybird/project.godot` and find the `[autoload]` section. Currently it should contain:

```
[autoload]

GameState="*res://scripts/game_state.gd"
```

Change it to:

```
[autoload]

GameState="*res://scripts/game_state.gd"
PuzzleBank="*res://scripts/puzzle_bank.gd"
```

- [ ] **Step 3: Headless verification**

Run:

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
cat > /tmp/verify_puzzle_bank.gd <<'EOF'
extends SceneTree
func _init():
	var pb = root.get_node_or_null("PuzzleBank")
	if pb == null:
		print("FAIL: PuzzleBank autoload not found")
		quit(1)
	pb.start_round()
	var p1 = pb.next_puzzle()
	var p2 = pb.next_puzzle()
	if p1.has("question") and p1.has("options") and p1.has("correct_index"):
		print("OK: puzzle1 = " + p1.question)
	else:
		print("FAIL: puzzle missing fields")
		quit(1)
	if p1 != p2:
		print("OK: consecutive puzzles differ")
	else:
		print("FAIL: same puzzle twice in a row")
		quit(1)
	# Drain pool
	for i in range(20):
		var p = pb.next_puzzle()
		if not p.has("question"):
			print("FAIL: drain returned empty at i=" + str(i))
			quit(1)
	print("OK: pool refills after drain")
	quit(0)
EOF
godot --headless --path . --script /tmp/verify_puzzle_bank.gd 2>&1 | tail -10
```

Expected output:
```
OK: puzzle1 = <some question>
OK: consecutive puzzles differ
OK: pool refills after drain
```

- [ ] **Step 4: Commit**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
git add scripts/puzzle_bank.gd project.godot
git commit -m "feat(puzzle): add PuzzleBank autoload with 15-question animal pool"
```

---

## Task 2: PuzzleOverlay Scene + Script

**Files:**
- Create: `scripts/puzzle_overlay.gd`
- Create: `scenes/PuzzleOverlay.tscn`

- [ ] **Step 1: Create `scripts/puzzle_overlay.gd`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scripts/puzzle_overlay.gd` (tabs):

```gdscript
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
```

- [ ] **Step 2: Create `scenes/PuzzleOverlay.tscn`**

Create `/Users/taagaanf/Documents/Projects/flappybird/scenes/PuzzleOverlay.tscn` with this exact content:

```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/puzzle_overlay.gd" id="1_script"]

[node name="PuzzleOverlay" type="CanvasLayer"]
layer = 10
script = ExtResource("1_script")

[node name="Dim" type="ColorRect" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0, 0, 0, 0.6)
mouse_filter = 1

[node name="Panel" type="PanelContainer" parent="."]
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -180.0
offset_top = -170.0
offset_right = 180.0
offset_bottom = 170.0

[node name="Layout" type="VBoxContainer" parent="Panel"]
theme_override_constants/separation = 16

[node name="AttemptLabel" type="Label" parent="Panel/Layout"]
text = "Versuch 1/3"
horizontal_alignment = 1
theme_override_font_sizes/font_size = 20

[node name="QuestionLabel" type="Label" parent="Panel/Layout"]
text = "Frage?"
horizontal_alignment = 1
autowrap_mode = 2
theme_override_font_sizes/font_size = 24
custom_minimum_size = Vector2(340, 80)

[node name="ButtonGrid" type="GridContainer" parent="Panel/Layout"]
columns = 2
theme_override_constants/h_separation = 12
theme_override_constants/v_separation = 12

[node name="Option0" type="Button" parent="Panel/Layout/ButtonGrid"]
text = "A"
custom_minimum_size = Vector2(160, 40)

[node name="Option1" type="Button" parent="Panel/Layout/ButtonGrid"]
text = "B"
custom_minimum_size = Vector2(160, 40)

[node name="Option2" type="Button" parent="Panel/Layout/ButtonGrid"]
text = "C"
custom_minimum_size = Vector2(160, 40)

[node name="Option3" type="Button" parent="Panel/Layout/ButtonGrid"]
text = "D"
custom_minimum_size = Vector2(160, 40)
```

- [ ] **Step 3: Headless verification**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
cat > /tmp/verify_overlay.gd <<'EOF'
extends SceneTree
func _init():
	var scene := load("res://scenes/PuzzleOverlay.tscn")
	if scene == null:
		print("FAIL: scene did not load")
		quit(1)
	var inst = scene.instantiate()
	root.add_child(inst)
	await process_frame
	var puzzle = {
		"question": "Testfrage?",
		"options": ["A", "B", "C", "D"],
		"correct_index": 2,
	}
	inst.show_puzzle(puzzle, 1)
	if inst.visible:
		print("OK: overlay visible after show_puzzle")
	else:
		print("FAIL: overlay not visible")
		quit(1)
	var qlabel = inst.get_node("Panel/Layout/QuestionLabel")
	if qlabel.text == "Testfrage?":
		print("OK: question text set")
	else:
		print("FAIL: question text wrong = " + qlabel.text)
		quit(1)
	inst.hide_overlay()
	if not inst.visible:
		print("OK: hide_overlay works")
	else:
		print("FAIL: still visible after hide")
		quit(1)
	quit(0)
EOF
godot --headless --path . --script /tmp/verify_overlay.gd 2>&1 | tail -10
```

Expected:
```
OK: overlay visible after show_puzzle
OK: question text set
OK: hide_overlay works
```

- [ ] **Step 4: Commit**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
git add scripts/puzzle_overlay.gd scenes/PuzzleOverlay.tscn
git commit -m "feat(puzzle): add PuzzleOverlay scene with question UI and answer buttons"
```

---

## Task 3: Bird `revive()` + Invincibility

**Files:**
- Modify: `scripts/bird.gd`

- [ ] **Step 1: Add `revive()` and invincibility helper to `bird.gd`**

Open `/Users/taagaanf/Documents/Projects/flappybird/scripts/bird.gd`.

The current file ends with the `die()` function:

```gdscript
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

Append the following functions at the end of the file (after `die()`):

```gdscript


func revive() -> void:
	dead = false
	frozen = false
	velocity = Vector2.ZERO
	global_position.x -= 60.0
	rotation = 0.0
	_start_invincibility()


func _start_invincibility() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	var tween := create_tween().set_loops(5)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	await tween.finished
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	sprite.modulate.a = 1.0
```

(Use tabs for indentation.)

- [ ] **Step 2: Headless verification**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
cat > /tmp/verify_revive.gd <<'EOF'
extends SceneTree
func _init():
	var scene := load("res://scenes/Bird.tscn")
	var bird = scene.instantiate()
	root.add_child(bird)
	await process_frame
	bird.dead = true
	bird.velocity = Vector2(0, 500)
	bird.global_position = Vector2(200, 400)
	bird.revive()
	if not bird.dead:
		print("OK: dead flag cleared")
	else:
		print("FAIL: still dead")
		quit(1)
	if bird.velocity == Vector2.ZERO:
		print("OK: velocity reset")
	else:
		print("FAIL: velocity not zero = " + str(bird.velocity))
		quit(1)
	if bird.global_position.x == 140.0:
		print("OK: position shifted back 60px (200 -> 140)")
	else:
		print("FAIL: position wrong = " + str(bird.global_position.x))
		quit(1)
	if not bird.get_collision_layer_value(1):
		print("OK: collision layer disabled during invincibility")
	else:
		print("FAIL: collision layer still on")
		quit(1)
	quit(0)
EOF
godot --headless --path . --script /tmp/verify_revive.gd 2>&1 | tail -10
```

Expected:
```
OK: dead flag cleared
OK: velocity reset
OK: position shifted back 60px (200 -> 140)
OK: collision layer disabled during invincibility
```

- [ ] **Step 3: Commit**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
git add scripts/bird.gd
git commit -m "feat(bird): add revive() with 1s invincibility flash"
```

---

## Task 4: Game Scene Quiz State Machine

**Files:**
- Modify: `scripts/game.gd`

- [ ] **Step 1: Replace `scripts/game.gd` with the quiz-aware version**

Open `/Users/taagaanf/Documents/Projects/flappybird/scripts/game.gd` and replace the entire file with this content (tabs):

```gdscript
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
```

> **Diff highlights** for the reviewer:
> - New `QUIZ` enum value and `quiz_attempts` state field
> - `MAX_QUIZ_ATTEMPTS` const
> - `@onready var ground` and `@onready var puzzle_overlay` (new)
> - `PuzzleBank.start_round()` + `puzzle_overlay.answered` connect in `_ready`
> - `_on_pipe_scored` ignores increments outside PLAYING (prevents in-flight score from registering during QUIZ/DEAD)
> - `_on_bird_died` re-routes to QUIZ instead of DEAD
> - New: `_pause_world`, `_resume_world`, `_show_next_puzzle`, `_on_puzzle_answered`, `_trigger_game_over`
> - The old inline death sequence in `_on_bird_died` is extracted to `_trigger_game_over` (called from the 3-strikes path)

- [ ] **Step 2: Headless verification (state machine doesn't crash on load)**

Game.tscn still references `$PuzzleOverlay` which doesn't exist as a child yet (Task 5 adds it). This step will succeed because `@onready` only fails when accessed, not when the scene is just loaded as a resource. So:

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 2>&1 | grep -E "ERROR|SCRIPT" | grep -v "still in use" | grep -v "ObjectDB" || echo "Clean load"
```

Expected output: `Clean load` (no SCRIPT ERROR lines). The "no main scene" warning won't appear because MainMenu is the main scene.

- [ ] **Step 3: Commit**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
git add scripts/game.gd
git commit -m "feat(game): add QUIZ state with revival flow and 3-attempt logic"
```

---

## Task 5: Wire PuzzleOverlay into Game.tscn

**Files:**
- Modify: `scenes/Game.tscn`

- [ ] **Step 1: Add PuzzleOverlay ext_resource and node to `Game.tscn`**

Open `/Users/taagaanf/Documents/Projects/flappybird/scenes/Game.tscn`. The current header is:

```
[gd_scene load_steps=7 format=3]

[ext_resource type="Script" path="res://scripts/game.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/background-day.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/Bird.tscn" id="3_bird"]
[ext_resource type="PackedScene" path="res://scenes/Ground.tscn" id="4_ground"]
[ext_resource type="PackedScene" path="res://scenes/HUD.tscn" id="5_hud"]
[ext_resource type="AudioStream" path="res://assets/audio/2019-12-11_-_Retro_Platforming_-_David_Fesliyan.mp3" id="6_bgm"]
```

Change `load_steps=7` to `load_steps=8` and add a new `ext_resource` line for the PuzzleOverlay scene immediately after the BGM ext_resource:

```
[gd_scene load_steps=8 format=3]

[ext_resource type="Script" path="res://scripts/game.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://assets/sprites/background-day.png" id="2_bg"]
[ext_resource type="PackedScene" path="res://scenes/Bird.tscn" id="3_bird"]
[ext_resource type="PackedScene" path="res://scenes/Ground.tscn" id="4_ground"]
[ext_resource type="PackedScene" path="res://scenes/HUD.tscn" id="5_hud"]
[ext_resource type="AudioStream" path="res://assets/audio/2019-12-11_-_Retro_Platforming_-_David_Fesliyan.mp3" id="6_bgm"]
[ext_resource type="PackedScene" path="res://scenes/PuzzleOverlay.tscn" id="7_puzzle"]
```

Then at the end of the file (after the BGM node), append:

```
[node name="PuzzleOverlay" parent="." instance=ExtResource("7_puzzle")]
```

The full appended block (BGM + PuzzleOverlay) should look like:

```
[node name="BGM" type="AudioStreamPlayer" parent="."]
stream = ExtResource("6_bgm")
volume_db = -6.0

[node name="PuzzleOverlay" parent="." instance=ExtResource("7_puzzle")]
```

- [ ] **Step 2: Headless verification — Game.tscn loads cleanly**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
cat > /tmp/verify_game_scene.gd <<'EOF'
extends SceneTree
func _init():
	var scene := load("res://scenes/Game.tscn")
	if scene == null:
		print("FAIL: scene did not load")
		quit(1)
	var inst = scene.instantiate()
	root.add_child(inst)
	await process_frame
	var overlay = inst.get_node_or_null("PuzzleOverlay")
	if overlay == null:
		print("FAIL: PuzzleOverlay child missing")
		quit(1)
	if overlay.visible:
		print("FAIL: overlay should start hidden")
		quit(1)
	print("OK: Game.tscn loads with PuzzleOverlay hidden")
	quit(0)
EOF
godot --headless --path . --script /tmp/verify_game_scene.gd 2>&1 | tail -10
```

Expected:
```
OK: Game.tscn loads with PuzzleOverlay hidden
```

- [ ] **Step 3: Project-wide headless smoke test**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot --headless --quit-after 1 2>&1 | grep -E "ERROR|SCRIPT" | grep -v "still in use" | grep -v "ObjectDB" || echo "Clean load"
```

Expected: `Clean load`.

- [ ] **Step 4: Commit**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
git add scenes/Game.tscn
git commit -m "feat(game): wire PuzzleOverlay into Game scene"
```

---

## Task 6: End-to-End Manual Verification

**Files:** none (verification only — any fixes go in a follow-up commit)

- [ ] **Step 1: Headless final smoke test**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
cat > /tmp/verify_e2e.gd <<'EOF'
extends SceneTree
func _init():
	# 1. Autoloads
	var gs = root.get_node_or_null("GameState")
	var pb = root.get_node_or_null("PuzzleBank")
	if gs == null:
		print("FAIL: GameState autoload missing"); quit(1)
	if pb == null:
		print("FAIL: PuzzleBank autoload missing"); quit(1)
	print("OK: both autoloads present")
	# 2. All scenes instantiate
	var scenes = ["Bird", "Pipe", "Ground", "HUD", "Game", "MainMenu", "GameOver", "PuzzleOverlay"]
	for s in scenes:
		var inst = load("res://scenes/%s.tscn" % s).instantiate()
		print("OK: %s -> %s" % [s, inst.get_class()])
		inst.queue_free()
	# 3. PuzzleBank delivers
	pb.start_round()
	var p = pb.next_puzzle()
	if p.has("question") and p.has("options") and p.has("correct_index"):
		print("OK: PuzzleBank delivers well-formed puzzle")
	else:
		print("FAIL: puzzle malformed"); quit(1)
	print("ALL OK")
	quit(0)
EOF
godot --headless --path . --script /tmp/verify_e2e.gd 2>&1 | tail -15
```

Expected:
```
OK: both autoloads present
OK: Bird -> CharacterBody2D
OK: Pipe -> Node2D
OK: Ground -> Node2D
OK: HUD -> CanvasLayer
OK: Game -> Node2D
OK: MainMenu -> Node2D
OK: GameOver -> Node2D
OK: PuzzleOverlay -> CanvasLayer
OK: PuzzleBank delivers well-formed puzzle
ALL OK
```

- [ ] **Step 2: Launch the game and play-test the puzzle flow**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
godot
```

Walk through this checklist with the running game:

1. Game starts at MainMenu → click → Game loads
2. Fly into a pipe → puzzle overlay appears at centre with dim background, attempt label "Versuch 1/3", a question, and four buttons
3. BGM is paused, pipes are frozen
4. Click the CORRECT answer → overlay disappears, bird flashes briefly (alpha pulsing for ~1s), pipes resume, BGM resumes, gameplay continues
5. Fly into another pipe → a DIFFERENT question appears (no repeats)
6. Click a WRONG answer → label changes to "Versuch 2/3" with a new question; gameplay still paused
7. Click WRONG again → "Versuch 3/3" with a new question
8. Click WRONG a third time → overlay disappears, normal death sequence: hit + die sounds, BGM fades, ~0.8 s freeze, scene transitions to GameOver with the score that was reached BEFORE the collision
9. Play again from GameOver → fresh puzzle pool (shuffled differently)
10. (Edge case) Trigger 15+ collisions in one round → puzzle still appears every time, no crash

- [ ] **Step 3: If anything fails, fix and commit**

If a check fails, fix and commit with a descriptive message:
- `fix(puzzle): correct overlay anchoring`
- `fix(game): handle late pipe.scored signal during QUIZ state`
- `fix(bird): preserve invincibility on rapid second collision`

If everything passes, skip this step.

- [ ] **Step 4: Final history summary**

```bash
cd /Users/taagaanf/Documents/Projects/flappybird
git log --oneline -10
```

Confirm the last ~5 commits are the puzzle feature commits (Tasks 1–5 + any Task-6 fixes).

---

## Self-Review

**Spec coverage check** (each requirement → task that implements it):

- Animal multiple-choice puzzle on pipe collision → Task 4 (`_on_bird_died` → QUIZ state)
- 3 attempts before Game Over → Task 4 (`MAX_QUIZ_ATTEMPTS`, `quiz_attempts` increment logic)
- No repeat puzzles per session → Task 1 (`PuzzleBank.start_round()` + shuffled `remaining`)
- Pool refills if exhausted → Task 1 (`next_puzzle` `if remaining.is_empty()` branch)
- Question + 4 options UI → Task 2 (`PuzzleOverlay` scene structure)
- Bird revival shifts back 60 px → Task 3 (`global_position.x -= 60.0`)
- 1-second invincibility flash → Task 3 (`_start_invincibility` with 5 × 0.2 s loop)
- BGM pauses during quiz, resumes on correct → Task 4 (`bgm.stream_paused = true/false`)
- Game Over after 3 wrong → Task 4 (`_trigger_game_over` extracted from original flow)
- All 15 puzzles concrete → Task 1 (full POOL literal)
- PuzzleOverlay wired into Game.tscn → Task 5
- End-to-end manual playtest → Task 6

**Placeholder scan:** No TBD/TODO/"fix later" anywhere. Every code step contains complete, working code. Every shell command has expected output.

**Type / API consistency:**
- `PuzzleBank.start_round()` defined Task 1, called Task 4 ✓
- `PuzzleBank.next_puzzle() -> Dictionary` defined Task 1, called Task 4 ✓
- `puzzle_overlay.show_puzzle(puzzle, attempt_number)` defined Task 2, called Task 4 ✓
- `puzzle_overlay.hide_overlay()` defined Task 2, called Task 4 ✓
- `puzzle_overlay.answered(correct: bool)` signal defined Task 2, connected Task 4 ✓
- `bird.revive()` defined Task 3, called Task 4 ✓
- `bird.frozen` already exists (used in `_pause_world`) ✓
- `bgm.stream_paused` is a built-in `AudioStreamPlayer` property ✓
- `ground.set_process(false)` — `ground` is a `Node2D` so `set_process` is valid ✓

**Scope:** Single feature; ~6 tasks; each task is one logical unit and one commit. Plan is execution-ready.

# Pipe-Collision Animal Puzzle Feature — Design Spec

**Date:** 2026-05-17
**Engine:** Godot 4.6.2 (stable)
**Language:** GDScript
**Builds on:** the existing Flappy Bird implementation
(see `2026-05-16-flappy-bird-design.md`)

## Goal

When the bird collides with a pipe (or the ground), instead of an immediate
Game Over the player gets a "rescue chance" via an animal-knowledge multiple
choice puzzle. Each round of puzzles allows up to 3 attempts: a correct answer
revives the bird and lets play continue; three wrong answers trigger the
normal Game Over flow.

Puzzles are drawn from a pool so the same question never repeats inside a
single play session.

## Non-Goals (v1)

- Puzzle categories beyond animal knowledge (no math/geography/etc.)
- Audio or image puzzles (text-only multiple choice for v1)
- Difficulty progression for puzzles (random order, all the same level)
- Per-puzzle scoring bonus (puzzles are pure rescue; score is unaffected)
- Persisting puzzle stats across runs

## Architecture

### Approach

Inline Puzzle UI as a `CanvasLayer` overlay inside `Game.tscn`. The whole
gameplay state (Bird, Pipes, Ground, BGM, PipeSpawner) is *paused in place*
by halting their `_process`/`_physics_process` and stopping the spawner —
no scene transitions, no state serialization. The puzzle overlay is the
only node still actively processing input. This keeps the existing scene
graph intact and revival is a matter of un-pausing.

A new `PuzzleBank` autoload owns the pool of questions and hands out one
random unseen puzzle at a time per session.

### File Structure

```
flappybird/
├── scripts/
│   ├── puzzle_bank.gd          # NEW — autoload, owns the pool
│   ├── puzzle_overlay.gd       # NEW — controls overlay UI
│   ├── game.gd                 # MODIFIED — adds QUIZ state + revival flow
│   └── bird.gd                 # MODIFIED — adds `revive()` helper + invincibility window
├── scenes/
│   ├── PuzzleOverlay.tscn      # NEW — CanvasLayer overlay UI
│   └── Game.tscn               # MODIFIED — instances PuzzleOverlay
└── project.godot               # MODIFIED — register PuzzleBank autoload
```

### Project Settings Changes

Register the new autoload alongside `GameState`:

```
[autoload]
GameState="*res://scripts/game_state.gd"
PuzzleBank="*res://scripts/puzzle_bank.gd"
```

## Components

### `PuzzleBank` (autoload, `scripts/puzzle_bank.gd`)

State:
- `var pool: Array[Dictionary]` — full question list (constant)
- `var remaining: Array[Dictionary]` — shuffled queue for the current session

Public API:
- `start_round()` — reset `remaining` to a freshly shuffled copy of `pool`.
  Called by `Game._ready` so every new round starts with all puzzles
  available again.
- `next_puzzle() -> Dictionary` — pop the next puzzle from `remaining`.
  If `remaining` is empty (rare: player triggered ≥15 collisions in one
  round), refill it from `pool` so the player never gets stuck without a
  question.

Each puzzle is a dictionary:

```gdscript
{
  "question": "Wie viele Beine hat eine Spinne?",
  "options": ["6", "8", "10", "4"],
  "correct_index": 1
}
```

The full v1 pool (15 entries) lives at the top of `puzzle_bank.gd` as a
`const POOL := [ ... ]`. Sample contents:

1. Wie viele Beine hat eine Spinne? — 6 / **8** / 10 / 4
2. Welches Tier macht "Muh"? — Schaf / **Kuh** / Ziege / Pferd
3. Welches Tier kann fliegen, ist aber kein Vogel? — Eichhörnchen / **Fledermaus** / Frosch / Eidechse
4. Was ist das grösste Säugetier? — Elefant / **Blauwal** / Giraffe / Eisbär
5. Wie schläft ein Flamingo? — liegend / **auf einem Bein** / im Wasser / fliegend
6. Welches Tier hat einen Höcker? — Pferd / **Kamel** / Zebra / Elefant
7. Welches Tier legt Eier und ist ein Säugetier? — Igel / **Schnabeltier** / Maus / Hase
8. Wie viele Herzen hat ein Oktopus? — 1 / 2 / **3** / 8
9. Welches Tier wechselt seine Farbe? — Frosch / Schlange / **Chamäleon** / Eidechse
10. Welcher Vogel kann nicht fliegen? — Adler / Spatz / **Pinguin** / Taube
11. Welches Tier hat ein Geweih? — Wildschwein / **Hirsch** / Wolf / Bär
12. Welches Tier lebt im Polarkreis? — Löwe / Tiger / **Eisbär** / Giraffe
13. Welches Tier hört mit den Beinen? — Schmetterling / Käfer / **Grille** / Biene
14. Was frisst ein Panda hauptsächlich? — Fisch / Fleisch / **Bambus** / Insekten
15. Welches Tier hat die längste Zunge im Verhältnis zum Körper? — Schlange / Frosch / **Chamäleon** / Kuh

### `PuzzleOverlay` (`scenes/PuzzleOverlay.tscn` + `scripts/puzzle_overlay.gd`)

Root: `CanvasLayer`, `layer = 10` (above HUD), starts with `visible = false`.

Children:
- `ColorRect` `Dim` — fills viewport with `Color(0, 0, 0, 0.6)`
- `PanelContainer` `Panel` — anchored centre, ~360×340 px
  - `VBoxContainer` `Layout` with separation 16:
    - `Label` `AttemptLabel` — text `"Versuch 1/3"`, font size 20
    - `Label` `QuestionLabel` — autowrap, font size 24
    - `GridContainer` `ButtonGrid` — columns 2
      - `Button` `Option0` … `Option3` — placeholder text "A/B/C/D"

Public API of `puzzle_overlay.gd`:
- `show_puzzle(puzzle: Dictionary, attempt_number: int) -> void`
  - Sets attempt label `"Versuch N/3"`
  - Sets question text
  - Assigns each option to a button label
  - Stores `correct_index`
  - `visible = true`
- `hide_overlay() -> void` — `visible = false`

Signal:
- `answered(correct: bool)` — emitted when a button is pressed

Internal:
- Buttons are connected to `_on_option_pressed(idx)` in `_ready`
- `_on_option_pressed(idx)` emits `answered(idx == correct_index)`,
  then disables all buttons (debounce) until next `show_puzzle()`

### `bird.gd` additions

New method `revive()` — restores the bird to a playable state without
moving it back to the start. The Game scene calls this on a correct
answer:

```gdscript
func revive() -> void:
    dead = false
    velocity = Vector2.ZERO
    global_position.x -= 60  # push out of the pipe
    rotation = 0.0
    _start_invincibility()

func _start_invincibility() -> void:
    set_collision_layer_value(1, false)
    set_collision_mask_value(1, false)
    # Visual flash: alternate sprite alpha 5 times over 1s
    var tween := create_tween().set_loops(5)
    tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
    tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
    await tween.finished
    set_collision_layer_value(1, true)
    set_collision_mask_value(1, true)
```

Invincibility lasts ~1s (5 flash cycles × 0.2s each) so the bird cannot
re-collide with the same pipe immediately after revival.

### `game.gd` additions

New state enum value: `State.QUIZ`. Transitions:

- `PLAYING` → `QUIZ` — triggered by `bird.died` instead of going straight
  to `DEAD`. Pause: `bird.frozen = true`, `pipes.set_process(false)` per
  pipe, `pipe_spawner.stop()`, `bgm.stream_paused = true`, `Ground.set_process(false)`.
  Show puzzle 1 with `attempt = 1`.
- `QUIZ` (answered correctly) → `PLAYING`. Hide overlay. Resume processes.
  `bird.revive()`. Resume BGM.
- `QUIZ` (answered wrong, attempts < 3) → still `QUIZ`. Show next puzzle
  with `attempt = attempts + 1`.
- `QUIZ` (3rd wrong) → `DEAD`. Hide overlay. Run the existing death
  sequence (submit score, fade BGM, transition to GameOver).

New fields on `game.gd`:
- `var quiz_attempts: int = 0`

In `_ready`:
- `PuzzleBank.start_round()`
- Connect `puzzle_overlay.answered` to `_on_puzzle_answered`

New methods:
- `_show_next_puzzle()` — `var puzzle := PuzzleBank.next_puzzle(); puzzle_overlay.show_puzzle(puzzle, quiz_attempts + 1)`
- `_pause_world()` — bird frozen, all pipes set_process(false), spawner stop, ground set_process(false), `bgm.stream_paused = true`
- `_resume_world()` — inverse of pause
- `_on_puzzle_answered(correct: bool)`:
  - `correct` → `quiz_attempts = 0`; hide overlay; `_resume_world()`; `bird.revive()`; `state = PLAYING`
  - `not correct` → `quiz_attempts += 1`; if `quiz_attempts >= 3`: `_trigger_game_over()`; else `_show_next_puzzle()`

`_on_bird_died` is renamed conceptually: when a collision happens, instead
of going straight to DEAD it goes to QUIZ. The actual "real" Game Over
path is extracted into `_trigger_game_over()` (the existing tween + scene
change logic) so both the 3-strikes path and any future direct-die path
can call it.

### `Game.tscn` modifications

Add `PuzzleOverlay` as instance at the end:

```
[ext_resource type="PackedScene" path="res://scenes/PuzzleOverlay.tscn" id="7_puzzle"]
...
[node name="PuzzleOverlay" parent="." instance=ExtResource("7_puzzle")]
```

## Data Flow

```
Bird collides with pipe / ground
        |
        v
  bird.die() emits 'died'
        |
        v
  Game._on_bird_died():
    state = QUIZ
    quiz_attempts = 0
    _pause_world()
    _show_next_puzzle()
        |
        v
  PuzzleOverlay visible, player picks button
        |
        v
  PuzzleOverlay emits 'answered(correct)'
        |
   +----+----+
   |         |
 correct   wrong
   |         |
   v         v
 revive   attempts++
 resume     |
 PLAYING   < 3?  --yes--> next puzzle (loop)
            |
           no
            v
        _trigger_game_over() (existing flow)
```

## Error Handling & Edge Cases

- **Pool exhausted in one round (≥15 collisions):** `next_puzzle()` refills
  `remaining` from `pool`. The player never sees an empty puzzle.
- **Pipe still inside the bird after revival:** the 60-px backward shift
  combined with the 1-second invincibility window covers the worst case
  (pipe SPEED is 85 px/s — 1 s of invincibility = 85 px of pipe travel,
  more than enough for the pipe to pass).
- **BGM resumption:** `AudioStreamPlayer.stream_paused` is reversible
  without re-loading the stream, so the music continues from the same
  position.
- **Ground scrolling:** paused via `Ground.set_process(false)` for visual
  consistency with the paused pipes.
- **Rapid double-collisions in one frame:** `bird.die()` is already
  idempotent via the `dead` flag. The QUIZ transition guard
  (`if state == QUIZ: return`) inside `_on_bird_died` prevents reentry.
- **Player closes window during puzzle:** Godot's normal quit handling
  applies; no extra cleanup needed.

## Testing Plan

Manual (no automated tests; consistent with the rest of the project):

1. Launch the game, fly into a pipe → puzzle overlay appears with
   "Versuch 1/3", question, four buttons. BGM pauses, pipes freeze.
2. Click the correct answer → overlay disappears, bird flashes briefly,
   gameplay resumes, BGM resumes.
3. Fly into another pipe → a *different* question appears (not the same
   one as before).
4. Click a wrong answer → "Versuch 2/3" with a new question.
5. Click wrong twice more → standard Game Over sequence runs (hit sound,
   die sound, transition to GameOver scene).
6. Restart → first collision shows a fresh shuffled pool (pool reset on
   `_ready`).
7. Survive 15+ collisions in one run → no crash, puzzle pool refills.
8. Visual check: overlay is centred, dim background covers viewport,
   buttons are clickable.

## Resolved Decisions

- **Inline overlay vs. scene change:** inline overlay — keeps the game
  state physically alive and revival is just un-pausing.
- **Engine pause vs. manual:** manual — only a handful of nodes need
  pausing; the engine-pause + `process_mode` matrix is heavier than the
  problem warrants.
- **Pool size:** 15 puzzles is plenty for a session-no-repeat experience
  while still being trivial to maintain in code.
- **Revival mechanics:** 60-px backward shift + 1-s invincibility. Simple,
  predictable, no risk of getting stuck in a pipe.
- **Score impact:** none. Puzzles are pure rescue; the focus stays on
  flying skill.

# Flappy Bird in Godot 4 — Design Spec

**Date:** 2026-05-16
**Engine:** Godot 4.6.2 (stable)
**Language:** GDScript
**Resolution:** 432×768 (Portrait, 3× scaled from original 288×512)

## Goal

Build a faithful Flappy Bird clone using Godot 4 and GDScript, with the
classic pixel-art assets (sprites + sounds) from
https://github.com/samuelcust/flappy-bird-assets/. The first version
includes a Main Menu, the core gameplay loop with sound effects, a Game
Over screen, and a locally persisted highscore. Difficulty progression
is out of scope for v1 but the architecture should not preclude it.

## Non-Goals (v1)

- Difficulty progression (constant pipe speed and gap size)
- Online leaderboard (highscore is local-only)
- Mobile/touch-specific UI affordances (desktop-first)
- Multiple bird skins / day-night background variants

## Architecture

### Approach

Classical Godot scene composition: each conceptual entity is its own
`.tscn` scene with a paired GDScript. A small autoload singleton holds
cross-scene state (highscore). Scenes communicate via Godot signals;
no scene reaches into another's internals.

### Project Structure

```
flappybird/
├── project.godot
├── icon.svg
├── assets/
│   ├── sprites/                # from samuelcust/flappy-bird-assets
│   └── audio/                  # downloaded but unused in v1
├── scenes/
│   ├── Game.tscn               # gameplay root
│   ├── Bird.tscn
│   ├── Pipe.tscn               # one top+bottom pair + score trigger
│   ├── Ground.tscn             # endlessly scrolling ground
│   ├── HUD.tscn                # in-game score label
│   ├── MainMenu.tscn
│   └── GameOver.tscn
├── scripts/
│   ├── game.gd
│   ├── bird.gd
│   ├── pipe.gd
│   ├── ground.gd
│   ├── hud.gd
│   ├── main_menu.gd
│   ├── game_over.gd
│   └── game_state.gd           # autoload singleton
└── docs/
    └── superpowers/specs/2026-05-16-flappy-bird-design.md
```

### Project Settings

- `display/window/size/viewport_width = 432`
- `display/window/size/viewport_height = 768`
- `display/window/stretch/mode = "viewport"` (logical resolution stays
  constant on resize)
- `display/window/stretch/aspect = "keep"` (preserve 9:16 ratio with
  letterboxing)
- `physics/2d/default_gravity = 0` (we apply gravity ourselves on the
  bird so it does not affect any other body that might be added later)
- Autoload: `GameState` → `res://scripts/game_state.gd` (singleton)
- Main scene: `res://scenes/MainMenu.tscn`

## Components

### `Bird.tscn` / `bird.gd`

- Root: `CharacterBody2D`
- Children:
  - `AnimatedSprite2D` with three frames (`upflap`, `midflap`,
    `downflap`) at ~10 fps for wing flap
  - `CollisionShape2D` (CircleShape2D, radius ≈ 12 px)
  - `FlapSound` (`AudioStreamPlayer`, stream = `wing.ogg`)
  - `HitSound` (`AudioStreamPlayer`, stream = `hit.ogg`)
  - `DieSound` (`AudioStreamPlayer`, stream = `die.ogg`)
- Constants:
  - `GRAVITY = 1400.0`  (px/s²)
  - `FLAP_VELOCITY = -400.0`  (px/s)
  - `MAX_FALL_SPEED = 700.0`  (clamp downward velocity)
- Behavior:
  - `_physics_process(delta)`: `velocity.y += GRAVITY * delta`,
    clamp, `move_and_slide()`
  - `flap()`: sets `velocity.y = FLAP_VELOCITY`, plays `FlapSound`
  - On collision: plays `HitSound`, then `DieSound` after a short
    delay (~0.4s) so they don't overlap
  - Rotation: `rotation = clamp(velocity.y / 600, -0.5, 1.2)` so the
    bird tilts up on flap and noses down when falling
  - Idle mode (used in MainMenu / pre-start): a flag `frozen` skips
    physics and gravity, lets the bird hover
- Signals:
  - `died` — emitted when the bird collides with a pipe or the ground

### `Pipe.tscn` / `pipe.gd`

- Root: `Node2D`
- Children:
  - `Sprite2D` for the top pipe (sprite flipped vertically)
  - `Sprite2D` for the bottom pipe
  - One `StaticBody2D` per pipe with `CollisionShape2D` (rectangle)
  - `Area2D` named `ScoreZone` placed in the gap between the pipes;
    a `CollisionShape2D` covering the gap horizontally — the bird
    enters this area exactly once per pipe pair
- Constants:
  - `SPEED = 100.0`  (px/s, leftward)
  - `GAP_SIZE = 130.0`  (vertical px between pipes)
- Behavior:
  - `_process(delta)`: `position.x -= SPEED * delta`
  - When `position.x < -100` (off-screen left): `queue_free()`
  - When the bird enters `ScoreZone`: emit `scored`, then disable the
    zone so it cannot fire again
- Signals:
  - `scored`

### `Ground.tscn` / `ground.gd`

- Two side-by-side copies of the `base.png` sprite scrolled left in
  lockstep; when the leading copy moves fully off-screen, snap it to
  the right of the trailing copy (classic two-tile loop)
- A `StaticBody2D` with a rectangle `CollisionShape2D` spans the
  ground area so the bird collides with it
- Scroll speed matches `Pipe.SPEED` for visual consistency

### `HUD.tscn` / `hud.gd`

- A `CanvasLayer` so the HUD sits above the world
- `Label` (large font) anchored top-center showing the current score
- `PointSound` (`AudioStreamPlayer`, stream = `point.ogg`)
- Public method: `set_score(value: int)` updates the label and plays
  `PointSound`

### `Game.tscn` / `game.gd`

- Root: `Node2D`
- Children:
  - `Sprite2D` background (centered, fills the viewport)
  - `Bird` instance (positioned around x=100, y=384)
  - `Ground` instance (anchored to bottom)
  - `PipeSpawner` (`Timer`, `wait_time = 1.5`, autostart=false)
  - `HUD` (CanvasLayer)
  - `Pipes` (`Node2D` container — pipes are added as children here so
    they can be cleared en masse on restart)
- State machine (3 states, tracked by an `enum`):
  - `WAITING` — bird is idle in the center; first input transitions
    to `PLAYING` and starts the timer
  - `PLAYING` — taps call `bird.flap()`; pipes spawn; score updates
  - `DEAD` — bird is non-interactive; after a short delay (~0.8s),
    transition to `GameOver.tscn` carrying the final score
- Pipe spawning:
  - On each `Timer.timeout`: instantiate `Pipe.tscn`, place it at
    `x = viewport_width + 50`, randomize the gap center y in the
    range `[200, 568]`, connect its `scored` signal
- Input handling:
  - `_unhandled_input(event)`: any "ui_accept" press, mouse click, or
    touch triggers `flap` (or starts the game when in WAITING)

### `MainMenu.tscn` / `main_menu.gd`

- Background sprite + a static "message.png" sprite (the "Get Ready"
  banner from the asset pack)
- `SwooshSound` (`AudioStreamPlayer`, stream = `swoosh.ogg`) plays
  on scene load
- Any input transitions to `Game.tscn`
- Uses `get_tree().change_scene_to_file("res://scenes/Game.tscn")`

### `GameOver.tscn` / `game_over.gd`

- Background + "gameover.png" banner
- `SwooshSound` (`AudioStreamPlayer`, stream = `swoosh.ogg`) plays
  on scene load
- Two `Label`s: "Score: N" and "Best: M" (read from
  `GameState.get_highscore()`)
- A `Button` "Play Again" → `change_scene_to_file("res://scenes/Game.tscn")`
- A `Button` "Main Menu" → `change_scene_to_file("res://scenes/MainMenu.tscn")`
- Receives the final score via a static variable on `GameState`
  (`GameState.last_score`) set by `Game` before scene change

### `game_state.gd` (Autoload Singleton)

- `var last_score: int = 0` (transient, set on death)
- `var highscore: int = 0` (persisted)
- `_ready()`: calls `_load()`
- `submit_score(score: int)`: if `score > highscore`, update and `_save()`
- `get_highscore() -> int`
- `_save()`: writes JSON `{"highscore": N}` to
  `user://highscore.save` via `FileAccess.open(..., WRITE)`
- `_load()`: reads the file if it exists; on parse error, leaves
  highscore at 0 (silent recovery — corrupted save just resets)

## Data Flow

```
MainMenu  --click-->  Game (WAITING)
                         |
                       click
                         v
                    Game (PLAYING)
                         |
            +------------+------------+
            |                         |
       Pipe.scored               Bird.died
            |                         |
        HUD.set_score        GameState.submit_score
                                      |
                            change_scene -> GameOver
                                      |
                              Best / Score labels
                                      |
                       Play Again -> Game | Main Menu -> MainMenu
```

## Asset Mapping

From `samuelcust/flappy-bird-assets`:

| Game element       | Asset file(s)                                 |
|--------------------|-----------------------------------------------|
| Background         | `background-day.png`                          |
| Ground             | `base.png`                                    |
| Bird (3 frames)    | `yellowbird-upflap.png`, `-midflap.png`, `-downflap.png` |
| Pipe               | `pipe-green.png` (used for both top & bottom; top flipped vertically) |
| "Get Ready" banner | `message.png`                                 |
| Game Over banner   | `gameover.png`                                |
| Score digits (HUD) | use a bundled font (Godot default) for v1; sprite-based digits (`0.png`–`9.png`) deferred |
| Flap sound         | `audio/wing.ogg`                              |
| Collision (impact) | `audio/hit.ogg`                               |
| Death (after hit)  | `audio/die.ogg`                               |
| Score increment    | `audio/point.ogg`                             |
| Scene transition   | `audio/swoosh.ogg`                            |

## Error Handling & Edge Cases

- **Save file missing or corrupt**: silently treat highscore as 0 and
  overwrite on next submission
- **Window resize**: handled by `stretch/mode = viewport` + `aspect = keep`
- **Rapid taps**: each tap is one flap; no debounce — that matches the
  original game's feel
- **Bird above the screen**: not clamped — flying off the top is allowed
  (the original Flappy Bird does the same; only ground/pipes kill)
- **Multiple deaths in one frame**: `bird.died` is connected with
  `CONNECT_ONE_SHOT` semantics in `game.gd` (or guarded by a `dead` flag)
  so death transition only fires once

## Testing Plan

Manual verification (no automated tests in v1 — the gameplay is
visual/timing-based):

1. Launch project → MainMenu shows, "Get Ready" banner visible
2. Click → Game scene loads, bird hovers
3. Click → bird flaps, pipes start spawning, ground scrolls
4. Fly through a pipe gap → score increments by 1
5. Hit a pipe → death animation (~0.8s) → GameOver screen with the
   correct final score
6. First playthrough sets highscore; second playthrough only overwrites
   if higher
7. Restart from GameOver → fresh game, no leftover pipes
8. Quit and relaunch → previous highscore still displayed
9. Resize the window → letterboxed, gameplay still works at logical
   432×768
10. Sounds: flap on each tap, point on each pipe pass, hit + die on
    collision, swoosh on entering MainMenu/GameOver

## Open Decisions Resolved

- **Physics body for bird**: `CharacterBody2D` (custom gravity), not
  `RigidBody2D` — gives precise, deterministic flap behavior
- **Score trigger**: dedicated `Area2D` on each pipe rather than
  measuring x-position — robust against frame-rate variation
- **Highscore storage**: plain JSON in `user://` — simplest possible,
  no encryption needed (it's a local single-player score)
- **Sound playback**: each sound source lives on the node that owns
  the action (flap/hit/die on the Bird, point on the HUD, swoosh on
  menu/game-over scenes) — no central audio manager, since v1 has no
  volume controls or muting

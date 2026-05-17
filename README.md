# Flappy Bird with Animal Quiz

A faithful Flappy Bird clone built with **Godot 4** and **GDScript**, plus
a twist: when the bird collides with a pipe, the player gets up to **3
attempts** to save it by answering animal-knowledge quiz questions.

Built as a learning project, with full design specs and implementation
plans tracked in `docs/superpowers/`.

## Features

- **Classic Flappy Bird gameplay** — gravity, flap, scrolling pipes,
  endless ground, persistent highscore
- **Animal Quiz Rescue** — crashing into a pipe triggers a multiple-choice
  trivia question in German. Right answer revives the bird and clears the
  path ahead; three wrong answers ends the run
- **15 unique quiz questions** with no repeats within a single run
- **Looping background music** ("Retro Platforming" by David Fesliyan)
  plus the original Flappy Bird sound effects (flap, hit, die, point,
  swoosh)
- **Local highscore persistence** as JSON in Godot's `user://` directory
- **Tuned for forgiveness** — gentler gravity (700 px/s²), smaller flap
  impulse, wider pipe gap, slower scroll than the original

## Requirements

- [Godot 4.6.2](https://godotengine.org/download) (or any 4.6.x stable)
- macOS, Linux, or Windows — desktop only for now (no mobile build)

## How to Run

Clone the repository and either open it in the Godot editor or launch
straight from the command line:

```bash
git clone git@github.com:andregasser/flappybird.git
cd flappybird
godot
```

Godot will auto-import all assets on first launch.

## Controls

| Action | Input |
|---|---|
| Start game | Mouse click / Space / Enter on the menu |
| Flap | Mouse click / Space / Enter |
| Answer quiz | Click one of the four buttons |
| Restart after game over | Click "Play Again" |

## Project Structure

```
flappybird/
├── assets/
│   ├── sprites/             # Flappy Bird pixel art (8 PNGs)
│   └── audio/               # Sound effects + BGM
├── scenes/                  # .tscn scene files
│   ├── Bird.tscn            # CharacterBody2D with physics + animation
│   ├── Pipe.tscn            # Top/bottom pipe pair + score trigger
│   ├── Ground.tscn          # Scrolling base tile
│   ├── HUD.tscn             # In-game score label
│   ├── Game.tscn            # Main gameplay scene
│   ├── MainMenu.tscn        # "Get Ready" splash
│   ├── GameOver.tscn        # Score + best + restart buttons
│   └── PuzzleOverlay.tscn   # Quiz CanvasLayer
├── scripts/                 # GDScript logic
│   ├── bird.gd
│   ├── pipe.gd
│   ├── ground.gd
│   ├── hud.gd
│   ├── game.gd              # State machine (WAITING/PLAYING/QUIZ/DEAD)
│   ├── main_menu.gd
│   ├── game_over.gd
│   ├── game_state.gd        # Autoload: highscore persistence
│   └── puzzle_bank.gd       # Autoload: 15-question pool
├── docs/superpowers/        # Design specs and implementation plans
└── project.godot
```

## Architecture Highlights

- **Inline puzzle overlay**, not a scene change — gameplay state is paused
  in place (Bird `frozen`, pipes `set_process(false)`, BGM
  `stream_paused = true`), so revival is just un-pausing
- **Pool-based quiz** — `PuzzleBank` shuffles 15 questions per run and
  refills if exhausted (≥15 collisions in one round)
- **Robust revival** — when you answer correctly, all pipes to the right
  of the bird are cleared (`queue_free`), the bird gets an auto-flap, and
  a 1-second invincibility window prevents any leftover hitbox issues

## Credits

- **Sprites**: [samuelcust/flappy-bird-assets](https://github.com/samuelcust/flappy-bird-assets)
  (classic Flappy Bird pixel art)
- **Background music**: "Retro Platforming" by David Fesliyan
- **Sound effects**: from samuelcust/flappy-bird-assets (wing, hit, die,
  point, swoosh)
- **Engine**: [Godot 4](https://godotengine.org/)

## Development Notes

This project was built following a strict spec → plan → implementation
workflow. Each feature has a design document and step-by-step
implementation plan under `docs/superpowers/`:

- `specs/2026-05-16-flappy-bird-design.md` — original game design
- `plans/2026-05-16-flappy-bird.md` — original implementation plan
- `specs/2026-05-17-pipe-puzzle-feature-design.md` — quiz feature design
- `plans/2026-05-17-pipe-puzzle-feature.md` — quiz feature plan

Commits follow [Conventional Commits](https://www.conventionalcommits.org/)
(`feat`, `fix`, `tune`, `chore`, `docs`).

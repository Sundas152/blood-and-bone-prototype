# Blood & Bone

Blood & Bone is a Godot 4.7 biological-horror action dungeon-crawler prototype. The player's body is the combat system, and the current playable milestone is a completed, repeatable training-room combat loop.

## Current Status

All seven approved training-room objectives are complete. The prototype currently proves movement, weapon commitment, enemy interaction, player defeat, encounter completion, and reliable reset behavior in one repeatable room.

No new gameplay objective is active. A new milestone must begin with explicit review and approval rather than automatically extending the completed objective sequence. See [Current Prototype](docs/CURRENT_PROTOTYPE.md) for the verified operational state.

## Requirements

- [Godot 4.7](https://godotengine.org/) to open and run the project.
- Blender is optional and is needed only for asset or model work.
- A physical gamepad is optional. Gamepad mappings exist, but physical-controller validation remains pending.

## Getting Started

1. Clone the repository:

   ```sh
   git clone <repository-url>
   cd blood-and-bone-prototype
   ```

2. Open [project.godot](project.godot) in Godot 4.7.
3. Allow Godot to import the project assets.
4. Run the main project from the editor.

## Controls

| Input | Action |
| --- | --- |
| WASD or arrow keys | Move Ian |
| J or Space | Summon Veinmore when inactive; slash when active |
| K or Escape | Dismiss Veinmore |
| Left stick | Move Ian |
| South face button | Summon Veinmore or slash |
| East face button | Dismiss Veinmore |

## Verified Gameplay Loop

- Player movement with an adaptive third-person, over-the-shoulder camera foundation.
- Veinmore summon, committed slash, and dismissal.
- Three-hit skeleton training targets with automatic respawning.
- Blood-mage pursuit, telegraphed close-range attack, interruption, and defeat.
- Ian's temporary three-hit health, visible damage response, defeat, and encounter reset.
- Exit activation after blood-mage defeat.
- Exit completion followed by a complete training-room reset.

The full verification history, timings, and known technical debt are maintained in [docs/CURRENT_PROTOTYPE.md](docs/CURRENT_PROTOTYPE.md).

## Project Structure

| Path | Purpose |
| --- | --- |
| [project.godot](project.godot) | Godot project configuration, main-scene reference, and input mappings |
| [main.tscn](main.tscn) | Configured main training-room scene |
| [scenes/](scenes/) | Player, room, enemy, and supporting scenes |
| [scripts/](scripts/) | Player, camera, room, enemy, and main gameplay scripts |
| [docs/CURRENT_PROTOTYPE.md](docs/CURRENT_PROTOTYPE.md) | Verified operational-state mirror |
| [AGENTS.md](AGENTS.md) | Execution and contribution guardrails |
| [addons/godot_ai/](addons/godot_ai/) | Godot AI editor integration; protected from gameplay changes |

## Source Authority

- Notion's **“BLOOD & BONE — Winning Current State”** is the design authority. This README intentionally does not include a private workspace URL.
- [docs/CURRENT_PROTOTYPE.md](docs/CURRENT_PROTOTYPE.md) is the repository's operational-state mirror. It records verified implementation behavior without replacing canon.
- [AGENTS.md](AGENTS.md) defines execution and contribution guardrails.
- Older documents and archived concepts are reference material unless they are explicitly promoted by the project owner.

When implementation, operational documentation, and design authority disagree, report the conflict instead of silently resolving it.

## Collaboration Workflow

Before beginning work:

1. Update your local `main` branch.
2. Read this README, [AGENTS.md](AGENTS.md), and [docs/CURRENT_PROTOTYPE.md](docs/CURRENT_PROTOTYPE.md).
3. Create a focused branch, for example `partner/<short-task-name>`.
4. Do not commit directly to `main`.

Use this sequence for each contribution:

1. Inspect the relevant implementation and working-tree state.
2. Propose the smallest safe change.
3. Obtain approval.
4. Implement only the approved scope.
5. Test the affected behavior and relevant regressions.
6. Document verified results.
7. Open a pull request.

Each pull request should identify:

- Files changed.
- Behavior changed.
- Tests performed and their results.
- Known risks, limitations, or follow-up work.
- Unrelated modified or untracked files intentionally left untouched.

## Protected Scope

- Do not modify [addons/godot_ai/](addons/godot_ai/) as part of gameplay work.
- Do not perform unrelated refactoring.
- Do not invent or begin a new objective without approval.
- Do not commit generated or experimental files merely because they appear in `git status`.
- Keep changes small, testable, and reversible.

## Known Limitations

- Ian's blocky placeholder silhouette remains deferred Blender/readability work.
- No final HUD or control-prompt presentation exists.
- Blood Pressure, Adrenaline, and Bone Stability are not implemented as gameplay systems.
- Five existing player-controller warnings remain documented in [Current Prototype](docs/CURRENT_PROTOTYPE.md#known-warnings).
- Physical-gamepad validation remains pending.

## License

This repository is available under the [MIT License](LICENSE).

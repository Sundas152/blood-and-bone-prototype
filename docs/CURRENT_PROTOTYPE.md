# Blood & Bone — Current Prototype

## Purpose

This document is an operational mirror of the current Blood & Bone prototype.

It records what is implemented, what has been verified, what remains incomplete, and what objective should be addressed next. It must not invent, replace, reinterpret, or overwrite canon.

The current design authority is Notion’s **“BLOOD & BONE — Winning Current State.”**

When this document conflicts with that authority or with the implementation, report the conflict explicitly. Do not silently resolve it.

## Current Mission

Build one repeatable combat-training room.

The goal is to prove a complete, understandable, repeatable combat loop before expanding the game.

## Functional Training-Room Criteria

The training room is functional when all of the following are true:

- Ian spawns reliably.
- Movement and camera controls work.
- Veinmore can be summoned, used, and dismissed.
- Ian can attack and damage one enemy.
- One enemy can attack and damage Ian.
- Ian visibly reacts to damage.
- Ian can survive or die through understandable combat.
- The enemy can be defeated.
- The encounter can reset without restarting the project.
- Ian can reach a functional endpoint.
- The entire loop can be repeated without errors.

## Camera Perspective — Canonical Direction

Adaptive third-person over-the-shoulder with a left offset is canonical for Blood & Bone.

The current controlled behind-side camera, visible player character, and existing follow behavior are the foundation for later refinement toward that adaptive over-the-shoulder direction. Preserve this implementation; do not replace or broadly refactor it as part of unrelated training-room work.

First-person is **Dormant**. It is not the active gameplay perspective and must not be treated as a requirement or scheduled direction unless the user explicitly reactivates it.

Camera refinement remains separate from the ordered training-room objectives and should begin only when explicitly scheduled.

## Verified Features

The following behavior has been inspected or tested:

- The project opens and runs in Godot 4.7.
- The configured main scene is `res://main.tscn`.
- Ian is placed at the first room’s `PlayerSpawn`.
- Player movement operates on the X/Z plane.
- Movement includes acceleration, friction, facing rotation, procedural walking, and idle motion.
- Six named gameplay actions are configured: `move_left`, `move_right`, `move_up`, `move_down`, `attack`, and `dismiss_weapon`.
- Existing keyboard controls are preserved exactly: WASD and the arrow keys move Ian, J and Space summon or slash with Veinmore, and K and Escape dismiss Veinmore.
- Simulated runtime gamepad verification passed with left-stick X-/X+ for left/right, left-stick Y-/Y+ for forward/backward, the south face button for attack, and the east face button for dismissal. Physical-gamepad confirmation remains pending because no controller was connected during testing.
- The current camera follows Ian from a controlled behind-side perspective and preserves a visible player character as the foundation for the canonical adaptive third-person over-the-shoulder, left-offset direction.
- The current camera foundation includes smoothing, side offset, movement bob, micro-jitter, and combat shake.
- The first room has a walkable floor, walls, safety rails, lighting, fog, organic architecture, and an out-of-bounds reset.
- Veinmore can be summoned with the attack input.
- Veinmore's gameplay-evidence summon correction is complete: its configured summon duration is `1.8s`, with an observed movement lock of `1.355–1.369s`.
- Across five initial-spacing summon trials, Ian took exactly one hit in `5/5` trials, took zero double hits before control returned, and completed a safe-spacing summon without damage.
- Veinmore can perform a committed slash with windup, an active hit window, follow-through, recovery, movement lock, trail feedback, and camera feedback.
- Veinmore can be dismissed.
- Ian has temporary three-hit health with one public `take_hit()` entry point.
- `take_hit()` returns `true` when temporary health reaches zero and does not represent a death system.
- Ian responds to damage with a short directional positional recoil.
- `restore_temporary_health()` explicitly restores full temporary health for repeated testing.
- A new hit safely interrupts any active hit-reaction tween and restores `VisualRoot` to its exact cached baseline transform before beginning the next reaction.
- Non-uniform `VisualRoot` scaling was removed from the hit reaction because it distorted Veinmore's trail when damage and attack feedback overlapped.
- The three skeleton training targets accept damage.
- Each skeleton requires exactly three hits to defeat.
- Skeleton targets flash, recoil, collapse, temporarily deactivate, and automatically respawn.
- A defeated skeleton cannot take additional damage while inactive.
- Respawn restores its starting transform, health, visibility, scale, material appearance, collision, and defeat state.
- Skeleton hit squash, hit tilt, defeat rotation, and collapse scaling belong to `SkeletonModel`; the root `CharacterBody3D` retains its fixed uniform scale and positional recoil.
- Nine required defeat-and-respawn cycles passed across the three skeletons, followed by one additional gameplay-cadence cycle per skeleton.
- Every corrected skeleton cycle restored the exact root and `SkeletonModel` baseline transforms, health, visibility, materials, collision, and defeat state with zero skeleton Jolt errors.
- The blood-mage prototype can locate and approach Ian.
- The blood mage accepts Veinmore damage, reacts to hits, and can be defeated.
- The blood mage has one close-range attack with anticipation, active, recovery, and cooldown phases.
- A pale/gold telegraph and backward windup make the attack readable against the room's red environment before it becomes active.
- The active phase uses a short horizontal-range check and can damage Ian no more than once per attack.
- A sequence token invalidates the complete running attack when it is cancelled, preventing delayed timers from resuming it or applying damage.
- Veinmore hits interrupt the attack during anticipation or its active window.
- Cancellation restores `BloodMageModel` and the imported mesh's original material overlay to their exact cached baseline state.
- Successful hits, avoided hits, continuous overlap, anticipation interruption, active-window interruption, defeat during attack, and loss of Ian were verified.
- Two complete three-attack health-depletion cycles reduced Ian from three health to zero and restored cleanly between cycles.
- The blood mage's visual defeat scaling runs on `BloodMageModel` instead of its `CharacterBody3D`, preserving the collapse while eliminating the observed Jolt scaling errors.
- Ian enters defeat exactly once at zero temporary health, stops movement and combat, safely neutralizes Veinmore, and automatically reloads the current scene after a short delay.
- Scene reload restores Ian, the blood mage, all three skeleton targets, active combat state, and temporary visuals to their initial encounter state.
- Defeating the blood mage activates the existing exit with pale/gold feedback that remains active after the blood mage is removed.
- Reaching the active exit safely disables Veinmore's hitbox and trail, stops Ian, and predictably reloads the complete training encounter.
- The victory-and-reset loop completed two consecutive verification cycles without exit-triggered damage during the completion delay.
- The main scene completes a smoke launch without current-run errors.

## Current Limitations

- Ian's current blocky placeholder silhouette needs a later Blender/readability pass. It is deferred visual work, not an immediate gameplay objective.
- There is no gameplay HUD or control prompt.
- There are no gameplay signals or scene signal connections.
- Blood Pressure, Adrenaline, and Bone Stability are not implemented as gameplay systems.
- The player controller is large and contains legacy or duplicate-looking visual structures. Major refactoring is explicitly out of scope.
- The repository’s updated `addons/godot_ai/` files are unrelated to current gameplay work and must not be modified.

## Known Warnings

Godot currently reports five warnings in `scripts/player/player_controller_25d.gd`:

- `set_normal_arms_visible(is_visible)` does not use its parameter.
- Its `is_visible` parameter shadows a base-class method.
- `set_combat_rig_visible(is_visible)` does not use its parameter.
- Its `is_visible` parameter shadows a base-class method.
- `_set_arm_transition_vessels_visible(is_visible, ...)` uses a parameter name that shadows a base-class method.

These warnings predate the skeleton-respawn objective. Do not fix them as unrelated cleanup during another objective.

The locally installed command-line Godot executable reports version 4.4.1, while the connected editor and project use Godot 4.7. Use the connected Godot 4.7 editor for authoritative project validation until the executable-path mismatch is resolved.

## Ordered Implementation Objectives

1. **Repeatable skeleton targets — complete.**
2. **Add Ian’s minimal temporary damage receiver — complete.**
3. **Give the blood mage one readable attack using that damage receiver — complete.**
4. **Add Ian’s defeat and encounter-reset behavior — complete.**
5. **Add a functional room-completion condition and exit — complete.**
6. **Replace hard-coded input fallbacks with named Godot input actions — complete.**
7. **Evaluate combat before expanding Veinmore or adding enemies — current next objective.**

Only one objective should be implemented at a time, after explicit approval.

## Current Next Action

Begin Objective 7: evaluate the complete training-room combat loop before expanding Veinmore or adding enemies.

## Explicitly Out of Scope

Do not add or expand:

- Additional levels or room expansion.
- More enemy types.
- Bosses.
- Story sequences.
- Inventory and loot.
- Progression trees.
- Full Blood Pressure, Adrenaline, and Stability systems.
- Additional Veinmore forms.
- Final models, textures, effects, or art polish.
- Major player-controller refactoring.

Also avoid:

- General-purpose architecture introduced before it is needed.
- Multiple attacks before one attack is readable and fun.
- Additional combat resources before the basic exchange works.
- Refactoring unrelated code while implementing an objective.
- Expanding systems that have not proven themselves fun.
- Treating visual polish as more important than gameplay readability.

Placeholder assets and temporary prototype values are acceptable.

## Changelog

### 2026-09-11 — Skeleton visual-transform ownership correction

Affected file:

- `scripts/enemies/enemy_test.gd`

Changes:

- Cached `SkeletonModel` and its complete baseline `Transform3D`.
- Moved hit squash, hit tilt, defeat rotation, and collapse scaling from the root physics body to `SkeletonModel`.
- Kept the root `CharacterBody3D` at its fixed uniform scale while preserving positional recoil.
- Restored both the root starting transform and exact visual-child baseline during respawn.

Validation:

- Three required defeat-and-respawn cycles passed for each of the three skeletons, for nine required cycles total.
- One additional gameplay-cadence cycle passed for every skeleton.
- Three-hit health, flash, recoil, collapse, disappearance, defeated-hit rejection, the `1.5s` respawn delay, visibility, collision, materials, and exact transform restoration remained functional.
- Zero skeleton Jolt errors occurred across the corrected cycles.
- Full movement, Veinmore, blood-mage, player-defeat, camera, exit, and two-cycle training-room reset regressions passed.

### 2026-09-11 — Named Godot input actions

Affected files:

- `project.godot`
- `scripts/player/player_controller_25d.gd`

Changes:

- Added `move_left`, `move_right`, `move_up`, `move_down`, `attack`, and `dismiss_weapon`.
- Preserved WASD, arrow-key, J, Space, K, and Escape controls using the named actions.
- Replaced the player controller's hard-coded keyboard fallbacks and removed its gameplay reliance on `ui_accept` and `ui_cancel` without modifying the built-in UI actions.
- Added minimal left-stick movement, south-button attack, and east-button dismissal mappings.

Validation:

- Godot 4.7 parsed `project.godot` and launched the main scene without current-run errors.
- Keyboard movement, normalized diagonals, summon, slash, dismissal, held-input suppression, combat locks, and complete training-room regressions passed.
- Simulated runtime testing confirmed the gamepad axis signs, face-button mappings, and movement deadzone.
- Physical-gamepad confirmation remains pending because no gamepad hardware was connected.

### 2026-09-11 — Veinmore summon gameplay-evidence correction

Affected file:

- `scripts/player/player_controller_25d.gd`

Changes:

- Reduced the exported default `summon_duration` from `2.8s` to `1.8s` without restructuring the summon tween or changing its movement lock, vulnerability, or interruption behavior.

Validation:

- The observed movement-lock duration was `1.355–1.369s`.
- Ian took exactly one hit in `5/5` initial-spacing trials, with zero double hits before control returned.
- Safe-spacing summoning completed without damage.
- Defeat during summoning and two complete victory/reset loops passed.
- Movement, slash, dismissal, camera, enemy attack, defeat, and exit behavior remained functional.
- No new project runtime errors or Jolt errors were observed; the five existing player-script warnings remain.

### 2026-09-11 — Functional training-room completion and exit

Affected file:

- `scripts/rooms/first_room_bounds.gd`

Changes:

- Made the blood mage's defeat the persistent completion condition for the current encounter.
- Added inactive and pale/gold active feedback to the existing exit using a safe runtime material override and guide-light changes.
- Added a reachable horizontal exit check, one-shot completion guard, explicit Veinmore hitbox/trail cleanup, player lock, and delayed scene reload.
- Preserved the existing out-of-bounds reset behavior.

Validation:

- Two complete victory-and-reset cycles passed.
- Skeleton defeats and the blood mage's first two hits did not activate the exit; the blood mage's third hit did.
- Exit activation persisted after the blood mage was removed.
- No damage occurred during either completion delay, and only one reset timer was created per completion.
- Reload restored Ian, the blood mage, all skeleton targets, and the inactive exit to baseline.
- Ian's defeat reset, out-of-bounds reset, and camera behavior remained functional.
- Existing skeleton Jolt scaling errors remained and were not caused by this objective.

### 2026-09-10 — Ian defeat and encounter reset

Affected file:

- `scripts/player/player_controller_25d.gd`

Changes:

- Added a one-shot defeat state when temporary health first reaches zero.
- Stopped movement and Veinmore combat, used a position-and-rotation-only placeholder collapse, and reloaded the current scene after an exported delay.
- Added guards preventing frozen player-bound callbacks from reactivating combat before reload.

Validation:

- Defeat during summon, slash windup, active window, recovery, and dismissal safely neutralized Veinmore.
- Two complete defeat-and-reload cycles restored all encounter participants to baseline.
- Repeated damage during defeat did not create another reset timer.
- Movement, summon, slash, dismissal, blood-mage damage, and camera behavior remained functional.

### 2026-09-10 — Blood mage readable close-range attack

Affected file:

- `scripts/enemies/blood_mage_static_test.gd`

Changes:

- Added one close-range attack with 0.55-second anticipation, a 0.12-second active window, 0.45-second recovery, and 0.75-second cooldown.
- Added a pale/gold telegraph, backward anticipation, short forward model lunge, and visible recovery.
- Added horizontal-range detection and a per-attack hit flag set before calling Ian's `take_hit()`.
- Added sequence-token cancellation with validity checks after every awaited timer.
- Cancelled attacks when interrupted by Veinmore, recoiling, defeated, inactive, or when Ian is lost.
- Cached and exactly restored the `BloodMageModel` transform and imported mesh overlay after completion or cancellation.
- Moved visual defeat scaling from the physics body to `BloodMageModel`, preserving defeat behavior without non-uniformly scaling the `CharacterBody3D`.

Validation:

- Successful and avoided attacks passed.
- Continuous overlap produced exactly one damage event per attack.
- Interruption during anticipation and before damage in the active window invalidated the sequence and prevented delayed damage.
- Defeat during an attack cancelled the sequence, preserved the collapse and removal behavior, and did not damage Ian.
- Losing Ian during an attack cancelled the sequence and restored the cached model and overlay state.
- Three attacks reduced Ian from three health to zero correctly.
- Health restoration and a second complete three-attack depletion cycle passed.
- Blood-mage pursuit, stopping distance, recoil, health, Veinmore damage, and defeat behavior remained functional.
- Player movement, Veinmore summon, slash, dismissal, and camera behavior remained functional.
- Clean reruns produced no new warnings, runtime errors, or Jolt scaling errors.

Known unrelated warnings:

- Five existing visibility-parameter warnings remain in `scripts/player/player_controller_25d.gd`.

### 2026-09-09 — Ian's minimal temporary damage receiver

Affected file:

- `scripts/player/player_controller_25d.gd`

Changes:

- Added temporary three-hit health and the public `take_hit(damage, hit_direction)` entry point.
- Added a short directional positional recoil localized to `VisualRoot`.
- Added `restore_temporary_health()` for repeated testing.
- Made overlapping reactions stop safely and restore the exact cached baseline transform before restarting.
- Removed non-uniform `VisualRoot` scaling after verification showed that it distorted Veinmore's expanding slash trail when attack and damage feedback overlapped.

Validation:

- An idle hit produced positional recoil while leaving the baseline transform basis unchanged.
- A hit during Veinmore's expanding trail remained readable without a full-screen or oversized red obstruction.
- Three hits returned `false`, `false`, and `true`, with temporary health reaching zero on the third hit.
- Two complete three-hit-and-restore cycles passed.
- Both cycles restored three health and the exact cached baseline transform.
- Movement, Veinmore summon, slash, dismissal, and camera behavior remained functional.
- No new warnings or runtime errors were introduced.

Known unrelated warnings:

- Five existing visibility-parameter warnings remain in `scripts/player/player_controller_25d.gd`.

### 2026-09-09 — Repeatable skeleton targets

Affected file:

- `scripts/enemies/enemy_test.gd`

Changes:

- Added an exported respawn delay.
- Replaced permanent removal with temporary deactivation.
- Restored starting transform, three-hit health, scale, visibility, materials, collision, velocity, and defeat state on respawn.
- Prevented additional damage while defeated.

Validation:

- Two complete defeat-and-respawn cycles passed.
- Each cycle required exactly three hits.
- Additional hits during defeat did not reduce health.
- Both cycles restored transform, visibility, material, collision, and three health.
- `git diff --check` passed.
- Godot 4.7 main-scene smoke launch passed without current-run errors.

Known unrelated warnings:

- Five existing visibility-parameter warnings remain in `scripts/player/player_controller_25d.gd`.

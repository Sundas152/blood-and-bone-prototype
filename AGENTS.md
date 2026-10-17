# Blood & Bone — Codex Project Instructions

## Prime Directive

Work in small, controlled, reversible steps.

Do not make large, destructive, or project-wide changes unless explicitly approved.

Before editing, inspect the relevant files/scenes and state the intended change.

---

## Allowed Actions

Codex may:

- Modify only files directly related to the current task.
- Create small prototype scripts or scenes when asked.
- Improve scripts, combat behavior, movement, camera, animation, or visuals when scoped.
- Add small placeholder systems when clearly requested.
- Explain what it is changing before making changes.
- Ask before making large or structural changes.

---

## Forbidden Actions Unless Explicitly Approved

Do **not**:

- Delete files.
- Rename major files, scenes, folders, or nodes.
- Modify save systems.
- Modify export settings.
- Install dependencies or packages.
- Run destructive terminal commands.
- Access files outside this project.
- Rewrite entire systems.
- Convert the game to pure 2D.
- Switch the main game to first-person.
- Add major progression systems early.
- Use external assets unless approved.

---

## Before Making Changes

Before editing, Codex should:

1. Inspect the relevant project files/scenes.
2. State what files/scenes/scripts it plans to modify.
3. Keep the plan small and focused.
4. Ask if the change could affect architecture, project settings, existing scenes, or major systems.

---

## After Making Changes

After editing, Codex should report:

- Files changed.
- Scenes changed.
- Scripts changed.
- What was done.
- How to test the change.
- Any risks or placeholder parts.

---

# Project Identity

Blood & Bone is a Godot 4.7 2.5D/3D biological horror-action dungeon crawler.

The player’s body is the combat system.

The game should feel:

- physical
- biological
- risky
- unstable
- oppressive
- slightly uncomfortable
- powerful but not safe

Avoid:

- generic fantasy
- clean magic
- generic sci-fi
- safe arcade feel
- overly clean modern visuals
- clean, safe, predictable mechanics
- traditional mana/stamina systems
- expanding systems too early

---

# Current Phase

## Phase 3.5 — 2.5D Combat Slice Prototype

The current goal is to refine one playable slice before expanding.

Current priorities:

1. Movement feel.
2. Behind-side camera readability.
3. PS1 / early-console horror-action presentation.
4. Veinmore summon and slash.
5. Enemy hit reactions.
6. First-room readability and atmosphere.

Do **not** focus on yet:

- first-person main gameplay
- full encounter loop
- regulation phase
- reward/altar system
- inventory
- skill trees
- crafting
- save/load
- progression
- multiple weapons
- complex enemy AI
- large story systems

---

# Technical Direction

Use:

- Godot 4.7-compatible GDScript.
- 3D scenes for the main game foundation.
- 2.5D gameplay structure.
- Controlled behind-side camera.
- Player movement on the X/Z plane.
- Simple, readable node structures.
- Small, testable changes.

The game should remain:

- 3D in world structure.
- 2.5D in gameplay readability.
- Player-visible.
- Camera-controlled.
- Combat-readable.

---

# Folder / Organization Rules

Prefer organized folders such as:

- `res://scenes/`
- `res://scenes/player/`
- `res://scenes/rooms/`
- `res://scenes/enemies/`
- `res://scripts/`
- `res://scripts/player/`
- `res://scripts/weapons/`
- `res://scripts/enemies/`
- `res://materials/`

Use clear names for nodes, scripts, and scenes.

Avoid messy one-off naming.

---

# Core Systems To Preserve

Long-term systems:

- **Blood Pressure** = risk and power.
- **Adrenaline** = momentum and rhythm.
- **Bone Stability** = control and structural integrity.

Do not fully build these systems yet unless asked.

For now, simple placeholder hooks are allowed, such as:

- printing `blood_pressure` after attacks
- simple pressure gain values
- simple enemy reactions
- simple hit feedback
- temporary debug values

---

# Combat Identity

Combat should not feel like clean HP trading.

It should read through:

- commitment
- interruption
- collapse
- exposure
- recovery delay
- instability
- heavy impact
- bodily strain

If combat feels clean, safe, or predictable, it is wrong.

If combat feels powerful, risky, and slightly out of control, it is closer.

Movement allowed:

- lunges
- bursts
- recoil
- extension

Movement not allowed:

- teleportation
- blinking
- instant reposition

Enemies should eventually:

- disrupt player systems
- affect pressure, adrenaline, or bone stability
- force decisions under stress
- not just deal damage

---

# Veinmore

Veinmore is a massive weapon pulled from the player’s own arm, made of veins and hardened blood.

It should feel:

- heavy
- biological
- violent
- costly
- risky
- like an extension of the player’s body
- not like a normal sword

## Veinmore Summon

The summon should:

- be activated by `J` or the attack input
- look like the player is pulling the weapon from their arm
- feel like extracting a living blade from the body
- materialize over time
- last no longer than 4 seconds
- create a strong biological extraction feeling

## Veinmore Slash

The slash should have:

- windup
- active hit phase
- follow-through
- recovery
- crimson / iridescent trail
- clear enemy reaction
- no attack spam

The swing should feel committed, heavy, and risky.

---

# Visual Style

Aim for intentional PS1 / early-console horror-action style.

This means:

- low-poly but not plain cubes
- low-resolution feel
- fog
- darkness
- limited palette
- strong silhouettes
- readable shapes
- moody lighting
- blood vessels
- bone ribs
- marrow-like forms
- vascular strands
- organic architecture

Avoid:

- raw blocky placeholder look
- shiny plastic materials
- overly clean modern surfaces
- unreadable clutter
- generic dungeon visuals

The room should feel grown from a body, not built by humans.

---

# Current Scope Lock

Do not add yet:

- inventory
- skill trees
- weapon altars
- crafting
- save/load
- dialogue
- progression
- multiple weapons
- complex enemy AI
- large story systems

Current focus only:

- movement
- camera
- Veinmore
- enemy hit reaction
- PS1 presentation
- first room readability

---

# Startup Behavior

At the start of a session, Codex should:

1. Inspect the project.
2. Summarize current player, camera, room, Veinmore, and enemy setup.
3. Do not edit until the requested task is clear.
4. Prefer a short plan before modifying files.
5. Keep all work scoped to the current project directory.

---

# Day 2 Immediate Priority

The next work session should focus on refinement, not expansion.

Priority order:

1. Make visuals feel like intentional PS1 horror, not raw blocky shapes.
2. Improve movement and walking animation readability.
3. Improve behind-side camera readability.
4. Refine Veinmore summon and slash.
5. Improve crimson slash trail.
6. Improve enemy hit reactions.
7. Keep the first room readable and atmospheric.

---

# Persistent Execution Guardrails

Before proposing gameplay changes, read `docs/CURRENT_PROTOTYPE.md`.

`docs/CURRENT_PROTOTYPE.md` is an operational mirror of the current project state. It does not invent, replace, or overwrite Blood & Bone canon. The current design authority is Notion’s **“BLOOD & BONE — Winning Current State.”**

When working on this project:

1. Inspect and report the relevant implementation before editing.
2. Work on one explicitly approved objective at a time.
3. Make the smallest testable change that advances that objective.
4. Avoid unrelated refactoring.
5. Do not expand systems that have not proven themselves fun.
6. Do not modify anything under `addons/godot_ai/`.
7. Do not stage, commit, push, pull, discard, delete, or otherwise remove changes without the user’s explicit approval.
8. Report conflicts between documentation and implementation instead of silently resolving them.
9. Placeholder assets are acceptable during prototype development.
10. Gameplay readability outranks visual polish.

Do not treat an operational note as permission to broaden scope. When documentation, implementation, and design authority disagree, report the conflict and follow any documented temporary operational exception. Ask for direction before making a consequential change, but do not allow a documented non-blocking exception to halt unrelated approved work.

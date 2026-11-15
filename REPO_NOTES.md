# Repo Notes: S3T-dev/CosmoCrisis

## Repository
- GitHub: https://github.com/S3T-dev/CosmoCrisis
- Repo ID: 1457524217
- No root `README.md` was present during review.

## Language composition
- C++: 98.3%
- Python: 1.7%

The GitHub language percentages reflect tracked source files and do not represent the full Godot project footprint. Scenes, GDScript, shaders, assets, and editor metadata are not captured in the same way as C++ source files, so the repo is best understood as a hybrid native + content project.

## Project overview
This repository is a Godot 4.7 prototype/game project built around a native C++ GDExtension. The gameplay and simulation logic are split between native C++ classes under `src/` and the Godot project content under `game/`.

## Repository layout
- `SConstruct` — root build entry point. It sets `ARGUMENTS["api_version"]` to `4.7`, loads `godot-cpp/SConstruct`, compiles the C++ sources from `src/*.cpp`, and emits a shared library into `game/bin/`.
- `extension_api.json` — generated Godot extension API metadata for the target engine version.
- `src/` — native C++ GDExtension sources. Key classes include `ShipTelemetry`, `PlayerController`, `Interactable`, `EclssTerminal`, and `HullBreachPoint`; `register_types.cpp` registers the extension with Godot.
- `game/project.godot` — project configuration. The project name is `Prototipe`, the startup scene is `run/main_scene="uid://5obrr453us73"`, and the autoload is `ShipTelemetryGlobal="*uid://cxs7bhejye52s"`.
- `game/scenes/` — Godot scenes, including the main gameplay and interactive environment content.
- `game/scripts/` — GDScript support scripts for gameplay, UI, and scene/controller behavior.
- `game/shaders/`, `game/shatl/`, and `game/ui/` — additional project content folders for visual effects, assets, and UI support.
- `game/bin/orbital_crisis.gdextension` — the GDExtension manifest that points Godot to the built binary and declares platform-specific targets.

## Build and runtime notes
- Build from the repository root with SCons.
- The build expects a local `godot-cpp/` checkout at the repo root, and the project `.gitignore` excludes that directory.
- The generated shared library is written into `game/bin/` and then loaded by Godot through `game/bin/orbital_crisis.gdextension`.
- The project targets Godot `4.7` and uses the Jolt Physics engine.
- `game/project.godot` confirms `config/features=PackedStringArray("4.7", "Forward Plus")` and `physics/common/physics_ticks_per_second=120`.
- The extension manifest declares Linux and Windows x86_64 targets; no macOS entry was identified in the checked-in metadata.
- `game/project.godot` uses a UID-based startup scene (`uid://5obrr453us73`), so the actual scene resource should be validated in the project before assuming a generic `main.tscn` path.
- The project is not a standalone engine or library repo; it is a content + native-plugin project intended to run inside Godot.

## Working assumptions and cautions
- C++ handles native gameplay systems, extension registration, and engine-facing logic.
- GDScript and scenes define the Godot content layer, UI, and gameplay flow.
- This appears to be a prototype or game-project repo rather than a full production engine integration; runtime validation remains the primary source of truth.
- No obvious automated test suite or CI workflow was identified during the root inspection, so local build + editor validation is the most practical verification path.
- The codebase includes generated extension API metadata (`extension_api.json`), which may be large and should not be edited casually.

## Suggested workflow
1. Confirm the configured startup-scene UID and trace the resource it resolves to in the Godot project.
2. Review the relevant scene and GDScript before adjusting native C++ behavior that drives gameplay.
3. Ensure a compatible `godot-cpp` checkout is present and version-matched to the target Godot `4.7` API.
4. Run a clean SCons build and verify the resulting binary path against `game/bin/orbital_crisis.gdextension`.
5. Open the Godot project and exercise the affected gameplay path; add a focused validation workflow as the project grows.

## Follow-up checklist
- [x] Confirm repo identity and metadata.
- [x] Confirm language composition.
- [x] Inspect root/build layout and Godot project configuration.
- [x] Confirm extension/native source layout and key classes.
- [ ] Validate the startup-scene UID against the actual scene resource in the project.
- [ ] Confirm `godot-cpp` prerequisites and platform-target configuration.
- [ ] Determine whether automated tests or a repeatable validation workflow should be added.

## Short memory cue
Godot 4.7 + SCons-built `godot-cpp` GDExtension; native C++ logic under `src/`, the actual game content under `game/`, startup behavior controlled by `game/project.godot`, and runtime loading managed through `game/bin/orbital_crisis.gdextension`.

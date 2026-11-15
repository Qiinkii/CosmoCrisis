# Repo Notes: S3T-dev/CosmoCrisis

## Repository
- GitHub: https://github.com/S3T-dev/CosmoCrisis
- Repo ID: 1457524217
- No root `README.md` was present during review.

## Language composition
- C++: 98.3%
- Python: 1.7%

The language percentage reflects the GitHub repo stats for tracked source files. It does not represent the full Godot project footprint, because scenes, GDScript, shaders, assets, and `.gdextension` metadata are also part of the project and not counted in the same way by GitHub's language breakdown.

## Project overview
This repository is a Godot 4.7 prototype/game project with a native C++ GDExtension. The gameplay logic is split between C++ native classes and Godot scene/GDScript content.

## Repository layout
- `SConstruct` — root SCons build entry point. It sets the Godot API version to `4.7`, loads `godot-cpp/SConstruct`, compiles `src/*.cpp`, and emits the shared library under `game/bin/`.
- `extension_api.json` — Godot extension API metadata generated for the Godot version used by the native module.
- `src/` — native C++ extension sources. Key classes include `ShipTelemetry`, `PlayerController`, `Interactable`, `EclssTerminal`, and `HullBreachPoint`; `register_types.cpp` registers the extension classes with Godot.
- `game/project.godot` — project configuration. The project name is `Prototipe`, `run/main_scene` is set to `uid://5obrr453us73`, and the autoload `ShipTelemetryGlobal` is registered via UID.
- `game/scenes/` — Godot scenes, including `main.tscn`, `player.tscn`, `ship.tscn`, `hull_breach.tscn`, `ship_telemetry.tscn`, `Terminal.tscn`, and `BulkheadDoor.tscn`.
- `game/scripts/` — GDScript support scripts for gameplay/UI behavior and system logic.
- `game/shaders/`, `game/shatl/`, and `game/ui/` — visual/shader/content folders that complement the main gameplay scenes.
- `game/bin/orbital_crisis.gdextension` — the GDExtension manifest that loads the compiled native library and declares platform-specific targets.

## Build and runtime notes
- Build from the repository root with SCons.
- The build expects a local `godot-cpp/` checkout to be available in the repo root, and the project `.gitignore` excludes that directory.
- The generated library is written to `game/bin/` and is then loaded by Godot through `game/bin/orbital_crisis.gdextension`.
- The project targets Godot `4.7` and uses Jolt Physics.
- The manifest includes Linux and Windows x86_64 targets; no macOS support was identified in the checked-in extension metadata.
- `game/project.godot` sets the startup scene by UID; verify the UID before assuming the scene path is the one shown in a generic `main.tscn` file.

## Working assumptions and cautions
- C++ is responsible for native gameplay features and registration with Godot.
- GDScript and scenes define the project layer, UI, and gameplay flow.
- This is a prototype/project repo rather than a full production engine integration; scene behavior should be validated through the Godot editor and runtime.
- No obvious automated test suite or CI configuration was found in the root inspection, so building and running the project remain the primary validation paths.

## Suggested workflow
1. Confirm the configured startup-scene UID and trace the resource it resolves to.
2. Review the relevant scene and GDScript alongside the matching native C++ class before modifying gameplay behavior.
3. Ensure the correct `godot-cpp` source/API version is available and then run a clean SCons build.
4. Verify the built binary path and platform-specific file name against the `.gdextension` manifest.
5. Open the Godot project and exercise the affected gameplay path; add focused validation or tests if the behavior becomes complex.

## Follow-up checklist
- [x] Confirm repo identity and metadata.
- [x] Confirm language composition.
- [x] Inspect root/build layout and Godot project configuration.
- [x] Confirm extension/native source layout and key classes.
- [ ] Validate the startup-scene UID against the actual scene resource in the project.
- [ ] Confirm `godot-cpp` prerequisites and platform-target configuration.
- [ ] Determine whether automated tests or a repeatable validation workflow should be added.

## Short memory cue
Godot 4.7 + SCons-built `godot-cpp` GDExtension; native C++ logic under `src/`, Godot content under `game/`, and startup behavior controlled by `game/project.godot` and the extension manifest under `game/bin/`.

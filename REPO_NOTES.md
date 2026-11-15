# Repo Notes: S3T-dev/CosmoCrisis

## Repository
- GitHub: https://github.com/S3T-dev/CosmoCrisis
- Repo ID: 1457524217

## Language composition
- C++: 98.3%
- Python: 1.7%

This repository is overwhelmingly C++-based, with a very small Python footprint. The project structure and build files indicate this is a Godot-based native game/simulation extension rather than a standard C++ desktop app.

## Repository layout
- Top-level files:
  - `SConstruct` builds a shared library using `godot-cpp` and compiles `src/*.cpp`
  - `extension_api.json` suggests a Godot extension API metadata file
  - `game/` contains the Godot project files and gameplay assets
  - `src/` contains the C++ extension implementation and core gameplay logic
- `game/project.godot` identifies a Godot 4.7 project with:
  - config/name="Prototipe"
  - main scene set to a scene in the game project
  - autoloaded `ShipTelemetryGlobal`
  - physics engine set to Jolt Physics
- `src/` contains likely gameplay systems such as:
  - `player_controller.*`
  - `ship_telemetry.*`
  - `interactable.*`
  - `hull_breach_point.*`
  - `eclss_terminal.*`
  - registration hooks in `register_types.*`

## Build / runtime model
- Build uses SCons (`SConstruct`), not CMake.
- It compiles a shared library artifact into `game/bin/orbital_crisis...`
- The native library is integrated with a Godot project through `godot-cpp` and API version `4.7`.
- This strongly suggests a Godot custom module / extension for gameplay logic, likely a 3D space/simulation game.

## Working assumptions
- Primary development language is C++.
- Build/test workflow is driven by SCons and Godot project configuration.
- The game logic is split between Godot scenes/scripts and a native C++ extension layer.
- Python files may be helper scripts, tooling, or small build/data support tasks.
- The project is likely a 3D game or simulation prototype, not a traditional engine library.

## Personal notes
- Start by checking the Godot project files in `game/` and the main scene entry point.
- Review `SConstruct` and the generated library path to confirm the native build target.
- Inspect the C++ registration layer (`register_types.*`) and major gameplay classes in `src/`.
- Check Godot scenes/scripts for gameplay flow and serialized objects before making changes.
- Verify whether there are tests or validation scripts beyond the Godot project runtime.

## Follow-up checklist
- [x] Inspect root layout
- [x] Read README / setup docs
- [x] Locate build system files
- [x] Find main C++ entry points
- [ ] Check test coverage or validation scripts
- [ ] Review any Python helper scripts

## Short memory cue
Godot 4.7 + SCons + godot-cpp native extension; C++ gameplay layer under `src/` with Godot project in `game/`; confirm build target and main scene first.

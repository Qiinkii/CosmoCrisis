# Repo Notes: S3T-dev/CosmoCrisis

## Repository
- GitHub: https://github.com/S3T-dev/CosmoCrisis
- Repo ID: 1457524217
- No root `README.md` was present when these notes were reviewed.

## Language composition
- C++: 98.3%
- Python: 1.7%

The project is a Godot game with a C++ GDExtension and Godot-native project content (scenes, GDScript, shaders, and assets). The supplied language breakdown reports only C++ and Python; it does not represent the full range of Godot project files.

## Repository layout
- `SConstruct` — SCons build entry point. Sets the default Godot API version to `4.7`, loads `godot-cpp/SConstruct`, compiles `src/*.cpp`, and writes the shared library under `game/bin/` with platform suffixes.
- `extension_api.json` — Godot extension API metadata.
- `src/` — Native extension sources. The classes include `ShipTelemetry`, `Interactable`, `PlayerController`, `EclssTerminal`, and `HullBreachPoint`; `register_types.cpp` registers them at scene initialization.
- `game/project.godot` — Godot project settings. Project name is `Prototipe`; project features identify Godot `4.7` and Forward Plus. It configures `ShipTelemetryGlobal` as an autoload, Jolt Physics, 120 physics ticks per second, and a main scene by UID.
- `game/scenes/` — Godot scenes, including `main.tscn`, `player.tscn`, `ship.tscn`, `hull_breach.tscn`, `ship_telemetry.tscn`, and interaction/UI scenes.
- `game/scripts/` — GDScript gameplay/UI support, including bulkhead door, engineering zone, HUD, and hypercapnia effects scripts.
- `game/shaders/`, `game/shatl/`, and `game/ui/` — Shader, ship/model, and UI content.
- `game/bin/orbital_crisis.gdextension` — GDExtension manifest. It declares the `orbital_crisis_init` entry point and library paths for Linux and Windows x86_64 debug/release builds. Its compatibility minimum is Godot 4.2; the SCons API version default is 4.7.

## Build and runtime
- Build with SCons from the repository root; the build script expects `godot-cpp/` to be present. The root `.gitignore` ignores that directory, so ensure it is provisioned locally (for example, as a submodule or checkout) before building.
- The build compiles all top-level `src/*.cpp` files into a shared library at `game/bin/orbital_crisis...`.
- Godot loads the native library through `game/bin/orbital_crisis.gdextension`. The manifest names Linux and Windows x86_64 targets; do not assume macOS or other architectures are configured.
- `game/project.godot` selects the startup scene by UID. Confirm which scene owns that UID before assuming `game/scenes/main.tscn` is the configured entry scene.
- The project ignores Godot editor cache, SCons intermediates, native build outputs, and `godot-cpp/`. The `game/bin/` directory contains the manifest and checked-in `.a` files; these are not the runtime `.so`/`.dll` paths declared by the manifest.

## Working assumptions and cautions
- C++ implements registered native gameplay classes; Godot scenes and GDScript provide the game/project layer.
- The project settings and assets suggest a 3D spacecraft/simulation prototype, but verify behavior in scenes/scripts before relying on that interpretation.
- The main scene UID and the visible `main.tscn` UID differ, so resolve the UID rather than presuming they are the same scene.
- No test suite or automated validation command was identified in the inspected root/build/project files. Treat a successful native build and opening/running the Godot project as separate checks.

## Suggested workflow
1. Check the configured main-scene UID and trace its scene resource.
2. Review the relevant scene and GDScript alongside the C++ class before changing gameplay behavior.
3. Ensure the matching `godot-cpp` version/API metadata is available, then build with SCons.
4. Verify the generated library path and platform-specific filename against `game/bin/orbital_crisis.gdextension`.
5. Open/run the Godot project and exercise the affected gameplay path; add focused tests or validation if appropriate.

## Follow-up checklist
- [x] Inspect root layout and build configuration.
- [x] Inspect Godot project settings, extension manifest, and native registration.
- [x] Confirm language composition.
- [ ] Resolve the configured main-scene UID.
- [ ] Identify/add automated tests or a repeatable validation workflow.
- [ ] Confirm the required `godot-cpp` source/version and build prerequisites.

## Short memory cue
Godot 4.7 project + SCons-built `godot-cpp` GDExtension; native gameplay classes are under `src/`, Godot content under `game/`. Check the startup-scene UID and platform library manifest before building or changing entry-scene behavior.

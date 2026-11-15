# Repo Notes: S3T-dev/CosmoCrisis

## Repository
- GitHub: https://github.com/S3T-dev/CosmoCrisis
- Repo ID: 1457524217
- Working branch: `main`
- No root `README.md` was present during review.

## Language composition
- C++: 78.1%
- GDScript: 18.1%
- GDShader: 3.1%
- Python: 0.7%

The GitHub language percentages reflect tracked source files and do not represent the full Godot project footprint. Scenes, GDScript, shaders, assets, editor metadata, generated content, localization files, and UI scenes are part of the actual shipped game experience and may not be reflected precisely in GitHub's language summary.

## Project overview
This repository is a Godot 4.x prototype/game project centered on a native C++ GDExtension. The gameplay and simulation logic are split between native C++ code under `src/` and the Godot project content under `game/`. The project includes a main menu, settings flow, HUD, mission success/fail overlays, and a native telemetry layer used by the gameplay logic.

## Repository layout
- `SConstruct` — root build entry point. It sets the target Godot API version, loads `godot-cpp/SConstruct`, compiles native sources, and emits a shared library into `game/bin/`.
- `extension_api.json` — generated Godot extension API metadata for the engine version being targeted.
- `src/` — native C++ GDExtension sources. Key classes include `ShipTelemetry`, `PlayerController`, `Interactable`, `EclssTerminal`, and `HullBreachPoint`.
- `game/project.godot` — project configuration and startup metadata for the Godot project.
- `game/localization/` — project localization data and locale JSON entries.
- `game/scenes/` — gameplay and interactive environment scenes.
- `game/scripts/` — GDScript support scripts for gameplay, UI, settings, localization, and scene/controller behavior.
- `game/shaders/` and `game/ui/` — visual and interface content used by the project.
- `game/bin/orbital_crisis.gdextension` — the extension manifest that points Godot to the built binary and declares platform-specific targets.

## Localization status
- A localization system was added using a JSON-backed locale parser in `game/scripts/localization.gd`.
- Locale data lives in `game/localization/locales.json` and currently supports Ukrainian and English.
- The project defaults to Ukrainian (`uk`) while allowing runtime language switching from the main menu settings.
- The HUD, settings labels, main menu text, death screen, and mission-complete screen are wired to use localized strings without changing the underlying Godot architecture.
- The localization logic is intentionally lightweight and stays within the existing project pattern rather than introducing a larger framework redesign.

## Build and runtime notes
- Build from the repository root using SCons.
- The build expects a local `godot-cpp/` checkout at the repo root, and the project `.gitignore` excludes that directory.
- The generated shared library is written into `game/bin/` and loaded by Godot through `game/bin/orbital_crisis.gdextension`.
- The project targets Godot `4.7` and uses the Jolt Physics engine.
- `game/project.godot` confirms `config/features=PackedStringArray("4.7", "Forward Plus")` and a project physics tick rate of `120`.
- The extension manifest declares Linux and Windows x86_64 targets; no macOS entry was identified in the checked-in metadata.
- The project is not a standalone engine or library repo; it is a content + native-plugin project intended to run inside Godot.

## Working assumptions and cautions
- C++ handles native gameplay systems, extension registration, and engine-facing logic.
- GDScript and scenes define the Godot content layer, UI, settings flow, and gameplay presentation.
- This appears to be a prototype or game-project repository rather than a full production engine integration; runtime validation remains the primary source of truth.
- No obvious automated test suite or CI workflow was identified during the root inspection, so local build + editor validation is still the practical verification path.
- The codebase includes generated extension API metadata (`extension_api.json`), which may be large and should not be edited casually.
- The GitHub language summary is useful for rough composition understanding, but it does not capture the full Godot project footprint accurately.
- The project config and locale files must remain valid Godot-readable syntax; malformed project configuration can block the game from loading before any gameplay code executes.

## Suggested workflow
1. Confirm the configured startup-scene UID and trace the resource it resolves to in the Godot project.
2. Review the relevant scene and GDScript before adjusting native C++ behavior that drives gameplay.
3. Ensure a compatible `godot-cpp` checkout is present and version-matched to the target Godot `4.7` API.
4. Run a clean SCons build and verify the resulting binary path against `game/bin/orbital_crisis.gdextension`.
5. Open the Godot project and exercise the affected gameplay path, including the localization toggle from the settings menu.
6. Add a focused validation workflow as the project grows.

## Follow-up checklist
- [x] Confirm repo identity and metadata.
- [x] Confirm language composition.
- [x] Inspect root/build layout and Godot project configuration.
- [x] Confirm extension/native source layout and key classes.
- [x] Add JSON-backed localization support for Ukrainian and English.
- [x] Restore valid project config and keep the existing Godot architecture intact.
- [ ] Validate the startup-scene UID against the actual scene resource in the project.
- [ ] Confirm `godot-cpp` prerequisites and platform-target configuration.
- [ ] Determine whether automated tests or a repeatable validation workflow should be added.

## Short memory cue
Godot 4.7 + SCons-built `godot-cpp` GDExtension; native C++ logic under `src/`, the actual game content under `game/`, startup behavior controlled by `game/project.godot`, and runtime localization handled by JSON-backed locale data with Ukrainian as the default language.

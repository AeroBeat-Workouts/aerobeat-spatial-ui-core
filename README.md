# AeroBeat Spatial UI Core

This package is the shared **helper layer** for AeroBeat spatial/world UI adapters.

It exists to support repos like `aerobeat-spatial-ui-mouse` with reusable spatial-surface and provider-side utilities without turning this repo into a second contract owner.

## Current product truth

This repo is intentionally scoped to **spatial UI helper infrastructure** only:

- reusable helper-layer building blocks for spatial/world UI providers
- shared target-resolution and surface-oriented utility code for future spatial adapters
- shared helper-policy scaffolding for hover/capture behavior on spatial surfaces
- package/testbed scaffolding for the new `aerobeat-spatial-ui-*` family

This repo does **not** own or redefine:

- the canonical UI interaction contract
- input event taxonomy or bus semantics
- native 2D bridge behavior
- concrete mouse/touch/XR provider behavior

Those concerns stay in their owning repos. In particular, the canonical UI interaction contract remains in `aerobeat-input-core`.

## Phase 2 shared helper slice

The first real extraction from the hybrid proof now lives here as a thin reusable helper layer:

- `src/helpers/surfaces/aero_spatial_surface_descriptor.gd` — authored-surface metadata and panel-UV → authored-space mapping helpers
- `src/helpers/providers/aero_spatial_rect_target_resolver.gd` — generic rect-based target lookup against `aerobeat-ui-core` target specs
- `src/helpers/providers/aero_spatial_projection_helper.gd` — neutral projected-hit shaping and projected-data assembly from already-known hits
- `src/helpers/policies/aero_spatial_hover_capture_policy.gd` — shared hover/capture state bookkeeping helpers

This slice is intentionally narrow. It gives `aerobeat-spatial-ui-mouse` a real shared helper layer to build on next while leaving contract ownership, native 2D behavior, and concrete provider publishing outside this repo.

## 📋 Repository Details

- **Type:** Spatial UI Helper Layer
- **License:** **Mozilla Public License 2.0 (MPL 2.0)**
- **Current baseline dependencies:**
  - `gut` (repo-local validation)
- **Planned downstream consumers:**
  - `aerobeat-spatial-ui-mouse`
  - future `aerobeat-spatial-ui-touch` / `aerobeat-spatial-ui-xr` style adapter repos

## GodotEnv development flow

This repo uses the AeroBeat GodotEnv package convention.

- Canonical dev/test manifest: `.testbed/addons.jsonc`
- Installed dev/test addons: `.testbed/addons/`
- GodotEnv cache: `.testbed/.addons/`
- Hidden workbench project: `.testbed/project.godot`
- Repo-local unit tests: `.testbed/tests/`

The repo root remains the package/published boundary for downstream consumers. Day-to-day development, debugging, and validation happen from the hidden `.testbed/` workbench using the pinned OpenClaw toolchain: Godot `4.6.2 stable standard`.

### Restore dev/test dependencies

From the repo root:

```bash
cd .testbed
godotenv addons install
```

That restores this repo's current dev/test manifest into `.testbed/addons/`.

### Open the workbench

From the repo root:

```bash
godot --editor --path .testbed
```

Use this `.testbed/` project as the canonical direct-development and bugfinding surface for spatial-helper-layer work.

### Import smoke check

From the repo root:

```bash
godot --headless --path .testbed --import
```

### Run unit tests

From the repo root:

```bash
godot --headless --path .testbed --script addons/gut/gut_cmdln.gd \
  -gdir=res://tests \
  -ginclude_subdirs \
  -gexit
```

### Validation notes

- `.testbed/addons.jsonc` is the committed dev/test dependency contract.
- The current Phase 0 baseline intentionally pins only the repo-local test dependency needed for validation: GUT `main`.
- Repo-local unit tests live under `.testbed/tests/`.
- The current package shape is consumed from the repo root (`subfolder: "/"`) for downstream installs.
- To catch installed-addon path regressions, stage the repo into the workbench as if it were a downstream addon before import/test, then run both the normal GUT suite and the installed-addon smoke script against that staged package:

```bash
rm -rf .testbed/addons/aerobeat-spatial-ui-core
mkdir -p .testbed/addons/aerobeat-spatial-ui-core
tar \
  --exclude=.git \
  --exclude=.godot \
  --exclude=.beads \
  --exclude=.dolt \
  --exclude=.testbed/.addons \
  --exclude=.testbed/.godot \
  --exclude=.testbed/addons \
  -cf - . | tar -xf - -C .testbed/addons/aerobeat-spatial-ui-core
godot --headless --path .testbed --import
godot --headless --path .testbed --script addons/gut/gut_cmdln.gd \
  -gdir=res://tests \
  -ginclude_subdirs \
  -gexit
godot --headless --path .testbed --script res://scripts/validate_installed_addon_paths.gd
```

- The CI workflow, the GUT suite, and the installed-addon smoke script all use that staged package flow so `res://addons/aerobeat-spatial-ui-core/...` runtime loading is verified in-repo.
- Keep the repo description truthful: this package is a shared spatial helper layer, not a concrete provider and not a contract-definition repo.

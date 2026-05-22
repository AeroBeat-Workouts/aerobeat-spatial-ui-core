# Phase 1 Boundary Freeze

This repo is the shared **helper layer** for AeroBeat spatial/world UI adapters.

## What this repo is allowed to own

Phase 1 freezes `aerobeat-spatial-ui-core` as the home of **spatial helper infrastructure only**:

- projected-surface helper scaffolding
- target-resolution helper scaffolding
- provider-side utility scaffolding shared by future spatial adapters
- hover/capture helper policy scaffolding for spatial surfaces
- package structure and test coverage that make this ownership explicit

## What this repo is not allowed to own

This repo must not become a second copy of `aerobeat-input-core` and must not absorb concrete adapter behavior.

It does **not** own:

- canonical contract event types
- the interaction bus
- event/source/surface/phase taxonomy
- native 2D bridge logic
- concrete mouse-provider behavior
- concrete touch/XR-provider behavior

Those concerns stay in their owning repos:

- `aerobeat-input-core` owns the canonical interaction contract and native 2D bridge path
- `aerobeat-spatial-ui-mouse` owns concrete desktop mouse spatial-provider behavior
- future adapter repos own their concrete touch/XR/provider behavior

## Why helper runtime classes exist here

The helper runtime classes in this repo are intentionally narrow. They encode where shared spatial helper code belongs without taking over the contract, detection model, or concrete provider semantics.

## Phase 2 first real extraction now living here

The first real shared extraction from the hybrid proof stays within the helper-layer boundary:

- `AeroSpatialSurfaceDescriptor` now owns reusable authored-surface metadata and panel-UV → authored-space mapping helpers.
- `AeroSpatialRectTargetResolver` now owns generic rect-based target resolution against target specs exported by `aerobeat-ui-core` consumer bindings.
- `AeroSpatialProjectionHelper` now owns neutral projected-hit shaping and adapter-ready projected-data assembly from already-known surface hits.
- `AeroSpatialHoverCapturePolicy` now owns generic hover/capture state bookkeeping helpers without publishing canonical contract phases itself.

These helpers are intentionally reusable across future spatial provider lanes. They do **not** perform world-hit acquisition, raycasts, native 2D bridging, event publication, or canonical contract definition.

If future work needs canonical event types, a native 2D bridge, or desktop mouse behavior, that work belongs in another repo and should not be added here.

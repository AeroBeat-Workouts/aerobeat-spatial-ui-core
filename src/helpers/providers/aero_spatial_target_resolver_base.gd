@tool
extends RefCounted
class_name AeroSpatialTargetResolverBase

const TARGET_RESOLUTION_RESULT_SCRIPT = preload("res://../src/helpers/surfaces/aero_spatial_target_resolution_result.gd")

## Base helper for spatial/world surface target-resolution utilities.
##
## Concrete provider repos may subclass or wrap this helper to perform
## their own hit-testing and target mapping. This repo intentionally stops
## at helper scaffolding and does not implement concrete mouse behavior.

func resolve_target(_surface, _world_hit):
	push_warning("AeroSpatialTargetResolverBase.resolve_target() is helper scaffolding only. Implement concrete behavior in a provider repo.")
	return TARGET_RESOLUTION_RESULT_SCRIPT.new()

@tool
extends RefCounted
class_name AeroSpatialProjectionHelper

## Shared projection helper scaffolding for spatial adapter repos.
##
## This class may eventually hold reusable math and coordinate conversion
## helpers that are independent of any one concrete provider. For Phase 1 it
## exists to pin the ownership boundary in code without shipping behavior.

func project_world_hit_to_surface(_surface, _world_hit) -> Vector2:
	push_warning("AeroSpatialProjectionHelper.project_world_hit_to_surface() is a placeholder. Concrete provider behavior must live outside aerobeat-spatial-ui-core.")
	return Vector2.ZERO

@tool
extends "res://../src/helpers/providers/aero_spatial_target_resolver_base.gd"
class_name AeroSpatialRectTargetResolver

## Shared helper resolver that maps projected authored-space points onto the
## target specs exported by Aero UI consumer bindings.
##
## This helper does not perform world hit acquisition. It only resolves a
## projected authored-space point against already-known target rect metadata.

func resolve_target(surface, projected_hit):
	if surface == null:
		return build_empty_result()

	var result = build_empty_result(surface.surface_id)
	var hit: Dictionary = projected_hit if projected_hit is Dictionary else {}
	var surface_position: Vector2 = hit.get(
		"authored_viewport_position",
		hit.get("surface_position", hit.get("viewport_position", Vector2.ZERO))
	)
	var authored_uv: Vector2 = hit.get(
		"authored_uv",
		hit.get("surface_normalized_position", hit.get("uv", Vector2(-1.0, -1.0)))
	)
	var panel_uv: Vector2 = hit.get("panel_uv", hit.get("uv", Vector2.ZERO))

	result.surface_position = surface_position
	result.surface_normalized_position = authored_uv
	result.authored_uv = authored_uv
	result.panel_uv = panel_uv
	result.raw_metadata = {
		"resolution_mode": "rect_target_specs",
	}

	for spec_variant in surface.duplicate_target_specs():
		if not (spec_variant is Dictionary):
			continue
		var spec: Dictionary = spec_variant
		var rect: Rect2 = spec.get("rect", Rect2())
		var normalized_rect: Rect2 = surface.normalize_surface_rect(rect)
		var matched := false
		if normalized_rect.size.x > 0.0 and normalized_rect.size.y > 0.0 and normalized_rect.has_point(authored_uv):
			matched = true
		elif rect.has_point(surface_position):
			matched = true
		if not matched:
			continue

		result.target_path = spec.get("target_path", NodePath())
		result.target_spec = spec.duplicate(true)
		result.hit_is_valid = result.target_path != NodePath()
		result.raw_metadata["matched_target_key"] = str(spec.get("target_key", ""))
		result.raw_metadata["matched_target_label"] = str(spec.get("target_name", ""))
		return result

	return result

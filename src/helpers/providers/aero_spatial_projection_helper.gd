@tool
extends RefCounted
class_name AeroSpatialProjectionHelper

## Shared projection/mapping helpers for spatial adapter repos.
##
## These helpers stay at the neutral helper layer: they transform panel-space
## UVs and already-known hit information into authored-surface coordinates and
## adapter-ready projected-data dictionaries. They do not perform raycasts,
## define canonical contract semantics, or publish events.

func project_world_hit_to_surface(surface, projected_hit) -> Vector2:
	if surface == null:
		return Vector2.ZERO
	var hit: Dictionary = projected_hit if projected_hit is Dictionary else {}
	if hit.has("panel_uv"):
		return surface.panel_uv_to_surface_position(hit.get("panel_uv", Vector2.ZERO))
	if hit.has("uv"):
		return surface.panel_uv_to_surface_position(hit.get("uv", Vector2.ZERO))
	return Vector2.ZERO

func build_surface_hit(surface, panel_uv: Vector2, extras: Dictionary = {}) -> Dictionary:
	if surface == null or not surface.is_configured() or not surface.has_panel_uv(panel_uv):
		return {
			"hit": false,
			"panel_uv": panel_uv,
			"screen_position": extras.get("screen_position", Vector2.ZERO),
			"world_direction": extras.get("world_direction", Vector3.ZERO),
		}

	var authored_uv: Vector2 = surface.panel_uv_to_authored_uv(panel_uv)
	var authored_viewport_position: Vector2 = surface.authored_uv_to_surface_position(authored_uv)
	return {
		"hit": true,
		"screen_position": extras.get("screen_position", Vector2.ZERO),
		"viewport_position": panel_uv * surface.surface_pixel_size,
		"uv": panel_uv,
		"panel_uv": panel_uv,
		"authored_viewport_position": authored_viewport_position,
		"authored_uv": authored_uv,
		"local_hit": extras.get("local_hit", Vector3.ZERO),
		"world_position": extras.get("world_position", Vector3.ZERO),
		"world_normal": extras.get("world_normal", Vector3.ZERO),
		"world_direction": extras.get("world_direction", Vector3.ZERO),
		"surface_size": extras.get("surface_size", surface.metadata.get("surface_size", Vector2.ZERO)),
		"raw_metadata": (extras.get("raw_metadata", {}) as Dictionary).duplicate(true),
	}

func build_projected_data(
	surface,
	hit: Dictionary,
	previous_projected: Dictionary = {},
	explicit_target_path: NodePath = NodePath(),
	live_target_path: NodePath = NodePath(),
	extra_raw_metadata: Dictionary = {}
) -> Dictionary:
	var projected_data: Dictionary = previous_projected.duplicate(true)
	var has_hit: bool = bool(hit.get("hit", false))
	var target_path := explicit_target_path
	if target_path == NodePath() and hit.has("target_path"):
		target_path = hit.get("target_path", NodePath())
	if target_path != NodePath():
		projected_data["target_path"] = target_path

	projected_data["screen_position"] = hit.get("screen_position", projected_data.get("screen_position", Vector2.ZERO))
	if has_hit:
		projected_data["surface_normalized_position"] = hit.get("authored_uv", hit.get("surface_normalized_position", hit.get("uv", Vector2.ZERO)))
		projected_data["surface_position"] = hit.get("authored_viewport_position", hit.get("surface_position", hit.get("viewport_position", Vector2.ZERO)))
		projected_data["world_position"] = hit.get("world_position", Vector3.ZERO)
		projected_data["world_normal"] = hit.get("world_normal", Vector3.ZERO)
		projected_data["world_direction"] = hit.get("world_direction", Vector3.ZERO)

		var raw_metadata: Dictionary = {}
		if hit.has("raw_metadata") and hit["raw_metadata"] is Dictionary:
			raw_metadata = (hit["raw_metadata"] as Dictionary).duplicate(true)
		raw_metadata["panel_uv"] = hit.get("panel_uv", hit.get("uv", Vector2.ZERO))
		raw_metadata["authored_uv"] = hit.get("authored_uv", hit.get("uv", Vector2.ZERO))
		raw_metadata["panel_viewport_position"] = hit.get("viewport_position", Vector2.ZERO)
		raw_metadata["authored_viewport_position"] = hit.get("authored_viewport_position", hit.get("viewport_position", Vector2.ZERO))
		raw_metadata["live_target_path"] = str(live_target_path)
		raw_metadata["published_target_path"] = str(target_path)
		if surface != null:
			raw_metadata["glass_rect"] = surface.authored_rect_normalized
			raw_metadata["target_resolution"] = str(surface.metadata.get("target_resolution", raw_metadata.get("target_resolution", "")))
			raw_metadata["host_surface"] = str(surface.metadata.get("host_surface", raw_metadata.get("host_surface", "")))
		for key in extra_raw_metadata.keys():
			raw_metadata[key] = extra_raw_metadata[key]
		projected_data["raw_metadata"] = raw_metadata
	else:
		if not projected_data.has("surface_normalized_position"):
			projected_data["surface_normalized_position"] = Vector2.ZERO
		if not projected_data.has("surface_position"):
			projected_data["surface_position"] = Vector2.ZERO
		if not projected_data.has("world_position"):
			projected_data["world_position"] = Vector3.ZERO
		if not projected_data.has("world_normal"):
			projected_data["world_normal"] = Vector3.ZERO
		projected_data["world_direction"] = hit.get("world_direction", projected_data.get("world_direction", Vector3.ZERO))
		var raw_metadata: Dictionary = (projected_data.get("raw_metadata", {}) as Dictionary).duplicate(true)
		raw_metadata["off_surface_continuation"] = true
		raw_metadata["live_target_path"] = str(live_target_path)
		raw_metadata["published_target_path"] = str(target_path)
		for key in extra_raw_metadata.keys():
			raw_metadata[key] = extra_raw_metadata[key]
		projected_data["raw_metadata"] = raw_metadata
	return projected_data

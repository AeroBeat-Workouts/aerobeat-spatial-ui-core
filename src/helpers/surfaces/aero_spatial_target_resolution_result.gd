@tool
extends RefCounted
class_name AeroSpatialTargetResolutionResult

## Neutral helper record for projected target-resolution output.
##
## This remains helper-layer-only data. It intentionally does not define
## canonical interaction events, phases, or bus semantics.

var surface_id: StringName = &""
var target_path: NodePath = NodePath()
var target_spec: Dictionary = {}
var surface_position: Vector2 = Vector2.ZERO
var surface_normalized_position: Vector2 = Vector2.ZERO
var panel_uv: Vector2 = Vector2.ZERO
var authored_uv: Vector2 = Vector2.ZERO
var hit_is_valid := false
var raw_metadata: Dictionary = {}

func clear() -> void:
	surface_id = &""
	target_path = NodePath()
	target_spec = {}
	surface_position = Vector2.ZERO
	surface_normalized_position = Vector2.ZERO
	panel_uv = Vector2.ZERO
	authored_uv = Vector2.ZERO
	hit_is_valid = false
	raw_metadata = {}

func to_dictionary() -> Dictionary:
	return {
		"surface_id": surface_id,
		"target_path": target_path,
		"target_spec": target_spec.duplicate(true),
		"surface_position": surface_position,
		"surface_normalized_position": surface_normalized_position,
		"panel_uv": panel_uv,
		"authored_uv": authored_uv,
		"hit_is_valid": hit_is_valid,
		"raw_metadata": raw_metadata.duplicate(true),
	}

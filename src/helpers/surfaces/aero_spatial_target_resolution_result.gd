@tool
extends RefCounted
class_name AeroSpatialTargetResolutionResult

## Helper-layer-only placeholder for projected target resolution output.
##
## This remains a neutral helper record. It intentionally does not define
## canonical interaction events, phases, or bus semantics.

var surface_id: StringName = &""
var target_path: NodePath = NodePath()
var local_position: Vector2 = Vector2.ZERO
var hit_is_valid := false

func clear() -> void:
	surface_id = &""
	target_path = NodePath()
	local_position = Vector2.ZERO
	hit_is_valid = false

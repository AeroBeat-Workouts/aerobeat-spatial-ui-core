@tool
extends RefCounted
class_name AeroSpatialSurfaceDescriptor

## Helper-layer-only placeholder describing a spatial UI surface boundary.
##
## This class exists to make the repo's ownership concrete:
## spatial adapters may share surface metadata and helper conventions here,
## but canonical interaction event types do not belong in this repo.

var surface_id: StringName = &""
var surface_path: NodePath = NodePath()
var viewport_path: NodePath = NodePath()
var metadata := {}

func is_configured() -> bool:
	return not surface_id.is_empty() and not surface_path.is_empty()

@tool
extends RefCounted
class_name AeroSpatialSurfaceDescriptor

## Shared helper-layer descriptor for a projected spatial UI surface.
##
## This record owns only neutral surface metadata and authored-space mapping
## helpers. It intentionally does not define canonical interaction events,
## phases, or bus semantics.

var surface_id: StringName = &""
var surface_path: NodePath = NodePath()
var viewport_path: NodePath = NodePath()
var surface_pixel_size: Vector2 = Vector2.ZERO
var authored_rect_normalized := Rect2(0.0, 0.0, 1.0, 1.0)
var target_specs: Array = []
var metadata := {}

func configure(config: Dictionary) -> AeroSpatialSurfaceDescriptor:
	surface_id = StringName(config.get("surface_id", surface_id))
	surface_path = config.get("surface_path", surface_path)
	viewport_path = config.get("viewport_path", viewport_path)
	surface_pixel_size = config.get("surface_pixel_size", surface_pixel_size)
	authored_rect_normalized = config.get("authored_rect_normalized", authored_rect_normalized)
	target_specs = (config.get("target_specs", target_specs) as Array).duplicate(true)
	metadata = (config.get("metadata", metadata) as Dictionary).duplicate(true)
	return self

func is_configured() -> bool:
	return not surface_id.is_empty() and surface_pixel_size.x > 0.0 and surface_pixel_size.y > 0.0

func duplicate_target_specs() -> Array:
	return target_specs.duplicate(true)

func has_panel_uv(panel_uv: Vector2) -> bool:
	return panel_uv.x >= 0.0 and panel_uv.x <= 1.0 and panel_uv.y >= 0.0 and panel_uv.y <= 1.0

func clamp_panel_uv(panel_uv: Vector2) -> Vector2:
	return Vector2(clampf(panel_uv.x, 0.0, 1.0), clampf(panel_uv.y, 0.0, 1.0))

func panel_uv_to_authored_uv(panel_uv: Vector2) -> Vector2:
	return authored_rect_normalized.position + (panel_uv * authored_rect_normalized.size)

func authored_uv_to_surface_position(authored_uv: Vector2) -> Vector2:
	return Vector2(authored_uv.x * surface_pixel_size.x, authored_uv.y * surface_pixel_size.y)

func panel_uv_to_surface_position(panel_uv: Vector2) -> Vector2:
	return authored_uv_to_surface_position(panel_uv_to_authored_uv(panel_uv))

func normalize_surface_rect(rect: Rect2) -> Rect2:
	if surface_pixel_size.x <= 0.0 or surface_pixel_size.y <= 0.0:
		return Rect2()
	return Rect2(rect.position / surface_pixel_size, rect.size / surface_pixel_size)

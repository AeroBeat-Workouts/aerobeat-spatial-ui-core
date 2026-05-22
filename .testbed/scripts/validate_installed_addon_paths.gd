extends SceneTree

const INSTALLED_PACKAGE_ROOT := "res://addons/aerobeat-spatial-ui-core"
const INSTALLED_MANIFEST_SCRIPT_PATH := INSTALLED_PACKAGE_ROOT + "/src/helpers/aero_spatial_ui_core_manifest.gd"
const INSTALLED_SURFACE_DESCRIPTOR_SCRIPT_PATH := INSTALLED_PACKAGE_ROOT + "/src/helpers/surfaces/aero_spatial_surface_descriptor.gd"
const INSTALLED_TARGET_RESULT_SCRIPT_PATH := INSTALLED_PACKAGE_ROOT + "/src/helpers/surfaces/aero_spatial_target_resolution_result.gd"
const INSTALLED_TARGET_RESOLVER_BASE_SCRIPT_PATH := INSTALLED_PACKAGE_ROOT + "/src/helpers/providers/aero_spatial_target_resolver_base.gd"
const INSTALLED_RECT_TARGET_RESOLVER_SCRIPT_PATH := INSTALLED_PACKAGE_ROOT + "/src/helpers/providers/aero_spatial_rect_target_resolver.gd"
const INSTALLED_PROJECTION_HELPER_SCRIPT_PATH := INSTALLED_PACKAGE_ROOT + "/src/helpers/providers/aero_spatial_projection_helper.gd"
const INSTALLED_HOVER_CAPTURE_POLICY_SCRIPT_PATH := INSTALLED_PACKAGE_ROOT + "/src/helpers/policies/aero_spatial_hover_capture_policy.gd"

func _init() -> void:
	var failures: Array[String] = []
	var installed_script_paths := [
		INSTALLED_MANIFEST_SCRIPT_PATH,
		INSTALLED_SURFACE_DESCRIPTOR_SCRIPT_PATH,
		INSTALLED_TARGET_RESULT_SCRIPT_PATH,
		INSTALLED_TARGET_RESOLVER_BASE_SCRIPT_PATH,
		INSTALLED_RECT_TARGET_RESOLVER_SCRIPT_PATH,
		INSTALLED_PROJECTION_HELPER_SCRIPT_PATH,
		INSTALLED_HOVER_CAPTURE_POLICY_SCRIPT_PATH,
	]

	for script_path in installed_script_paths:
		if not ResourceLoader.exists(script_path):
			failures.append("missing installed addon script: %s" % script_path)
			continue
		var script = load(script_path)
		if script == null:
			failures.append("failed to load installed addon script: %s" % script_path)

	if failures.is_empty():
		var surface = load(INSTALLED_SURFACE_DESCRIPTOR_SCRIPT_PATH).new().configure({
			"surface_id": &"installed_surface",
			"surface_pixel_size": Vector2(1000.0, 800.0),
			"target_specs": [
				{
					"target_key": "primary_action",
					"target_name": "Primary Action",
					"target_path": NodePath("PreviewCenter/PrimaryActionButton"),
					"rect": Rect2(350.0, 300.0, 220.0, 120.0),
				}
			],
		})
		var installed_resolver = load(INSTALLED_RECT_TARGET_RESOLVER_SCRIPT_PATH).new()
		var installed_result = installed_resolver.resolve_target(surface, {
			"authored_viewport_position": Vector2(460.0, 360.0),
			"authored_uv": Vector2(0.46, 0.45),
			"viewport_position": Vector2(600.0, 400.0),
			"uv": Vector2(0.6, 0.5),
			"panel_uv": Vector2(0.6, 0.5),
		})

		if installed_result == null:
			failures.append("installed addon rect resolver returned null")
		elif not installed_result.hit_is_valid:
			failures.append("installed addon rect resolver did not report a valid hit")
		elif installed_result.target_path != NodePath("PreviewCenter/PrimaryActionButton"):
			failures.append("installed addon rect resolver returned unexpected target path: %s" % installed_result.target_path)

	if failures.is_empty():
		print("Installed-addon package smoke passed for aerobeat-spatial-ui-core")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)

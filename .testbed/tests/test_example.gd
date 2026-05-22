extends GutTest

const MANIFEST_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/aero_spatial_ui_core_manifest.gd")
const SURFACE_DESCRIPTOR_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_surface_descriptor.gd")
const TARGET_RESULT_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_target_resolution_result.gd")
const TARGET_RESOLVER_BASE_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_target_resolver_base.gd")
const RECT_TARGET_RESOLVER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_rect_target_resolver.gd")
const PROJECTION_HELPER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")
const HOVER_CAPTURE_POLICY_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/policies/aero_spatial_hover_capture_policy.gd")

func before_all():
	gut.p("Starting Spatial UI Core Tests...")

func after_all():
	gut.p("Finished Spatial UI Core Tests.")

func test_plugin_manifest_structure():
	var manifest_path = "res://../plugin.cfg"
	assert_true(FileAccess.file_exists(manifest_path), "plugin.cfg should exist at the repo root")

	var config = ConfigFile.new()
	assert_eq(config.load(manifest_path), OK, "plugin.cfg should load")
	assert_eq(config.get_value("plugin", "name", ""), "AeroBeat Spatial UI Core", "plugin name should match the package identity")
	assert_true(config.get_value("plugin", "description", "") != "", "plugin description should be set")

func test_phase_1_manifest_locks_helper_layer_boundary():
	var summary := MANIFEST_SCRIPT.ownership_summary()

	assert_eq(summary.get("repo_role"), "helper_layer_only")
	assert_eq(summary.get("contract_owner_repo"), "aerobeat-input-core")
	assert_false(summary.get("owns_contract_types", true))
	assert_false(summary.get("owns_native_2d_bridge", true))
	assert_false(summary.get("owns_event_taxonomy", true))
	assert_false(summary.get("owns_concrete_mouse_provider", true))
	assert_eq(summary.get("concrete_mouse_provider_repo"), "aerobeat-spatial-ui-mouse")

func test_phase_boundary_docs_state_phase_2_shared_helper_scope_explicitly():
	var docs_path := "res://../docs/phase-1-boundary-freeze.md"
	assert_true(FileAccess.file_exists(docs_path), "Phase boundary doc should exist")

	var contents := FileAccess.get_file_as_string(docs_path)
	assert_string_contains(contents, "helper layer")
	assert_string_contains(contents, "canonical contract event types")
	assert_string_contains(contents, "native 2D bridge")
	assert_string_contains(contents, "AeroSpatialRectTargetResolver")
	assert_string_contains(contents, "AeroSpatialProjectionHelper")
	assert_string_contains(contents, "AeroSpatialHoverCapturePolicy")

func test_surface_descriptor_maps_panel_uv_into_authored_space():
	var surface = SURFACE_DESCRIPTOR_SCRIPT.new().configure({
		"surface_id": &"hybrid_glass_panel",
		"surface_pixel_size": Vector2(1000.0, 800.0),
		"authored_rect_normalized": Rect2(0.1, 0.2, 0.6, 0.5),
	})

	assert_true(surface.is_configured(), "configured surface descriptor should report ready")
	assert_eq(surface.panel_uv_to_authored_uv(Vector2(0.5, 0.5)), Vector2(0.4, 0.45))
	assert_eq(surface.panel_uv_to_surface_position(Vector2(0.5, 0.5)), Vector2(400.0, 360.0))
	assert_eq(surface.normalize_surface_rect(Rect2(100.0, 80.0, 200.0, 120.0)), Rect2(0.1, 0.1, 0.2, 0.15))

func test_rect_target_resolver_prefers_authored_space_target_lookup():
	var surface = SURFACE_DESCRIPTOR_SCRIPT.new().configure({
		"surface_id": &"hybrid_glass_panel",
		"surface_pixel_size": Vector2(1000.0, 800.0),
		"authored_rect_normalized": Rect2(0.1, 0.2, 0.6, 0.5),
		"target_specs": [
			{
				"target_key": "primary_action",
				"target_name": "Primary Action",
				"target_path": NodePath("PreviewCenter/PrimaryActionButton"),
				"rect": Rect2(350.0, 300.0, 220.0, 120.0),
			}
		],
	})
	var resolver = RECT_TARGET_RESOLVER_SCRIPT.new()
	var hit := {
		"authored_viewport_position": Vector2(460.0, 360.0),
		"authored_uv": Vector2(0.46, 0.45),
		"viewport_position": Vector2(600.0, 400.0),
		"uv": Vector2(0.6, 0.5),
		"panel_uv": Vector2(0.6, 0.5),
	}

	var result = resolver.resolve_target(surface, hit)
	assert_true(result.hit_is_valid, "resolver should match authored-space target specs")
	assert_eq(result.target_path, NodePath("PreviewCenter/PrimaryActionButton"))
	assert_eq(result.surface_position, Vector2(460.0, 360.0))
	assert_eq(result.surface_normalized_position, Vector2(0.46, 0.45))
	assert_eq(result.raw_metadata.get("resolution_mode"), "rect_target_specs")

func test_projection_helper_builds_adapter_ready_projected_data_without_contract_ownership():
	var surface = SURFACE_DESCRIPTOR_SCRIPT.new().configure({
		"surface_id": &"hybrid_glass_panel",
		"surface_pixel_size": Vector2(1000.0, 800.0),
		"authored_rect_normalized": Rect2(0.1, 0.2, 0.6, 0.5),
		"metadata": {
			"target_resolution": "rect_target_specs",
			"host_surface": "PanelInputSurface",
		}
	})
	var projection = PROJECTION_HELPER_SCRIPT.new()
	var hit := projection.build_surface_hit(surface, Vector2(0.6, 0.5), {
		"screen_position": Vector2(900.0, 540.0),
		"world_position": Vector3(1.0, 2.0, 3.0),
		"world_normal": Vector3(0.0, 0.0, 1.0),
		"world_direction": Vector3(0.1, -0.2, -1.0),
	})
	var projected_data := projection.build_projected_data(
		surface,
		hit,
		{},
		NodePath("PreviewCenter/PrimaryActionButton"),
		NodePath("PreviewCenter/PrimaryActionButton"),
		{"hover_target_path": "PreviewCenter/PrimaryActionButton"}
	)

	assert_true(hit.get("hit", false), "surface hit helper should shape a valid authored hit")
	assert_eq(hit.get("authored_uv"), Vector2(0.46, 0.45))
	assert_eq(hit.get("authored_viewport_position"), Vector2(460.0, 360.0))
	assert_eq(projected_data.get("target_path"), NodePath("PreviewCenter/PrimaryActionButton"))
	assert_eq(projected_data.get("surface_normalized_position"), Vector2(0.46, 0.45))
	assert_eq(projected_data.get("surface_position"), Vector2(460.0, 360.0))
	assert_eq(projected_data.get("world_position"), Vector3(1.0, 2.0, 3.0))
	assert_eq(projected_data.get("raw_metadata", {}).get("target_resolution"), "rect_target_specs")
	assert_eq(projected_data.get("raw_metadata", {}).get("host_surface"), "PanelInputSurface")
	assert_eq(projected_data.get("raw_metadata", {}).get("published_target_path"), "PreviewCenter/PrimaryActionButton")

func test_projection_helper_marks_off_surface_continuation_without_resetting_previous_coordinates():
	var surface = SURFACE_DESCRIPTOR_SCRIPT.new().configure({
		"surface_id": &"hybrid_glass_panel",
		"surface_pixel_size": Vector2(1000.0, 800.0),
	})
	var projection = PROJECTION_HELPER_SCRIPT.new()
	var previous_projected := {
		"surface_normalized_position": Vector2(0.46, 0.45),
		"surface_position": Vector2(460.0, 360.0),
		"world_position": Vector3(1.0, 2.0, 3.0),
		"world_normal": Vector3(0.0, 0.0, 1.0),
		"raw_metadata": {"target_resolution": "rect_target_specs"},
	}
	var projected_data := projection.build_projected_data(surface, {
		"hit": false,
		"screen_position": Vector2(1200.0, 720.0),
		"world_direction": Vector3(0.0, 0.0, -1.0),
	}, previous_projected, NodePath(), NodePath())

	assert_eq(projected_data.get("surface_normalized_position"), Vector2(0.46, 0.45))
	assert_eq(projected_data.get("surface_position"), Vector2(460.0, 360.0))
	assert_eq(projected_data.get("raw_metadata", {}).get("off_surface_continuation"), true)

func test_hover_capture_policy_tracks_reusable_owner_state_without_emitting_contract_phases():
	var policy = HOVER_CAPTURE_POLICY_SCRIPT.new()
	var state := policy.build_pointer_state()
	var hover_transition: Dictionary = policy.update_hover_target(state, NodePath("PreviewCenter/PrimaryActionButton"))
	var capture_snapshot: Dictionary = policy.begin_capture(state, NodePath("PreviewCenter/PrimaryActionButton"))
	var published_target := policy.resolve_published_target_path(state, NodePath("PreviewCenter/OtherButton"))
	var release_snapshot: Dictionary = policy.release_capture(state)

	assert_eq(hover_transition.get("entered_target_path"), NodePath("PreviewCenter/PrimaryActionButton"))
	assert_eq(capture_snapshot.get("capture_target_path"), NodePath("PreviewCenter/PrimaryActionButton"))
	assert_eq(published_target, NodePath("PreviewCenter/PrimaryActionButton"))
	assert_eq(release_snapshot.get("previous_capture_target_path"), NodePath("PreviewCenter/PrimaryActionButton"))
	assert_false(policy.describe_boundary().get("owns_contract_types", true))

func test_placeholder_runtime_scaffolding_stays_within_boundary_after_real_helper_extraction():
	var result = TARGET_RESULT_SCRIPT.new()
	var resolver = TARGET_RESOLVER_BASE_SCRIPT.new()
	var resolution_result = resolver.call("resolve_target", null, {})

	assert_false(result.hit_is_valid, "fresh target-resolution result should not pretend a hit already exists")
	assert_eq(resolution_result.surface_id, &"", "base resolver should still stay generic")

extends GutTest

const MANIFEST_SCRIPT := preload("res://../src/helpers/aero_spatial_ui_core_manifest.gd")
const SURFACE_DESCRIPTOR_SCRIPT := preload("res://../src/helpers/surfaces/aero_spatial_surface_descriptor.gd")
const TARGET_RESULT_SCRIPT := preload("res://../src/helpers/surfaces/aero_spatial_target_resolution_result.gd")
const TARGET_RESOLVER_BASE_SCRIPT := preload("res://../src/helpers/providers/aero_spatial_target_resolver_base.gd")
const PROJECTION_HELPER_SCRIPT := preload("res://../src/helpers/providers/aero_spatial_projection_helper.gd")
const HOVER_CAPTURE_POLICY_SCRIPT := preload("res://../src/helpers/policies/aero_spatial_hover_capture_policy.gd")

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

func test_phase_1_docs_state_the_boundary_explicitly():
	var docs_path := "res://../docs/phase-1-boundary-freeze.md"
	assert_true(FileAccess.file_exists(docs_path), "Phase 1 boundary doc should exist")

	var contents := FileAccess.get_file_as_string(docs_path)
	assert_string_contains(contents, "helper layer")
	assert_string_contains(contents, "canonical contract event types")
	assert_string_contains(contents, "native 2D bridge")
	assert_string_contains(contents, "concrete mouse-provider behavior")

func test_placeholder_runtime_scaffolding_is_present_without_concrete_provider_behavior():
	var surface = SURFACE_DESCRIPTOR_SCRIPT.new()
	var result = TARGET_RESULT_SCRIPT.new()
	var resolver = TARGET_RESOLVER_BASE_SCRIPT.new()
	var projection = PROJECTION_HELPER_SCRIPT.new()
	var policy = HOVER_CAPTURE_POLICY_SCRIPT.new()

	assert_false(surface.is_configured(), "Fresh helper descriptor should start unconfigured")
	assert_false(result.hit_is_valid, "Fresh target-resolution result should not pretend a hit already exists")

	var resolution_result = resolver.call("resolve_target", surface, null)
	assert_eq(resolution_result.hit_is_valid, false, "Base resolver should remain a placeholder")

	var projected_position = projection.call("project_world_hit_to_surface", surface, null)
	assert_eq(projected_position, Vector2.ZERO, "Projection helper should remain a placeholder")

	var boundary := policy.describe_boundary()
	assert_eq(boundary.get("repo_role"), "helper_layer_only")
	assert_false(boundary.get("owns_contract_types", true))
	assert_false(boundary.get("owns_native_2d_bridge", true))
	assert_false(boundary.get("owns_concrete_mouse_behavior", true))

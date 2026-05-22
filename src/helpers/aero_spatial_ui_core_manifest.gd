@tool
extends RefCounted
class_name AeroSpatialUiCoreManifest

const REPO_ROLE := "helper_layer_only"
const CONTRACT_OWNER_REPO := "aerobeat-input-core"
const CONCRETE_MOUSE_PROVIDER_REPO := "aerobeat-spatial-ui-mouse"

static func ownership_summary() -> Dictionary:
	return {
		"repo_role": REPO_ROLE,
		"contract_owner_repo": CONTRACT_OWNER_REPO,
		"owns_contract_types": false,
		"owns_native_2d_bridge": false,
		"owns_event_taxonomy": false,
		"owns_concrete_mouse_provider": false,
		"concrete_mouse_provider_repo": CONCRETE_MOUSE_PROVIDER_REPO,
	}

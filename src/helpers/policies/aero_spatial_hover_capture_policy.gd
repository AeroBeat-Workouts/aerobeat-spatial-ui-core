@tool
extends RefCounted
class_name AeroSpatialHoverCapturePolicy

## Shared helper-policy scaffold for spatial hover/capture rules.
##
## This class may eventually hold reusable policy helpers shared by multiple
## spatial providers. It intentionally does not define canonical contract
## semantics or concrete device-specific behavior.

func describe_boundary() -> Dictionary:
	return {
		"repo_role": "helper_layer_only",
		"owns_contract_types": false,
		"owns_native_2d_bridge": false,
		"owns_concrete_mouse_behavior": false,
	}

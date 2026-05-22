@tool
extends RefCounted
class_name AeroSpatialHoverCapturePolicy

## Shared helper-policy logic for neutral spatial hover/capture state.
##
## This class does not publish contract events. It only manages reusable owner
## bookkeeping so provider repos can apply the same hover/capture continuity
## rules without re-copying low-level state transitions.

func describe_boundary() -> Dictionary:
	return {
		"repo_role": "helper_layer_only",
		"owns_contract_types": false,
		"owns_native_2d_bridge": false,
		"owns_concrete_mouse_behavior": false,
	}

func build_pointer_state() -> Dictionary:
	return {
		"hover_target_path": NodePath(),
		"capture_target_path": NodePath(),
		"hover_active": false,
		"capture_active": false,
	}

func update_hover_target(state: Dictionary, next_target_path: NodePath) -> Dictionary:
	var previous_target_path: NodePath = state.get("hover_target_path", NodePath())
	var changed := previous_target_path != next_target_path
	state["hover_target_path"] = next_target_path
	state["hover_active"] = next_target_path != NodePath()
	return {
		"changed": changed,
		"previous_target_path": previous_target_path,
		"next_target_path": next_target_path,
		"exited_target_path": previous_target_path if changed else NodePath(),
		"entered_target_path": next_target_path if changed else NodePath(),
	}

func begin_capture(state: Dictionary, owner_target_path: NodePath) -> Dictionary:
	state["capture_target_path"] = owner_target_path
	state["capture_active"] = owner_target_path != NodePath()
	return {
		"capture_target_path": owner_target_path,
		"capture_active": bool(state["capture_active"]),
	}

func release_capture(state: Dictionary) -> Dictionary:
	var previous_target_path: NodePath = state.get("capture_target_path", NodePath())
	state["capture_target_path"] = NodePath()
	state["capture_active"] = false
	return {
		"previous_capture_target_path": previous_target_path,
		"capture_active": false,
	}

func resolve_published_target_path(state: Dictionary, live_target_path: NodePath) -> NodePath:
	var capture_target_path: NodePath = state.get("capture_target_path", NodePath())
	if bool(state.get("capture_active", false)) and capture_target_path != NodePath():
		return capture_target_path
	return live_target_path

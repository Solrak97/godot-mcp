extends RefCounted
## API handlers for Godot MCP HTTP endpoints.
## Uses EditorInterface for all editor operations.

const LOG_DEFAULT_TAIL := 200
const LOG_PATH := "user://logs/godot.log"

var _editor_interface: EditorInterface

func _init(editor_interface: EditorInterface = null) -> void:
	_editor_interface = editor_interface

func handle(method: String, path: String, query: Dictionary, body: String) -> Variant:
	if path == "/run" and method == "POST":
		return _handle_run()
	if path == "/stop" and method == "POST":
		return _handle_stop()
	if path == "/log" and method == "GET":
		var tail: int = int(query.get("tail", LOG_DEFAULT_TAIL))
		return _handle_log(tail)
	if path == "/errors" and method == "GET":
		return _handle_errors()
	if path == "/scene_tree" and method == "GET":
		var scene: String = query.get("scene", "current")
		return _handle_scene_tree(scene)
	if path == "/selected" and method == "GET":
		return _handle_selected()
	if path == "/node/properties" and method == "GET":
		var node_path: String = query.get("path", "")
		return _handle_node_properties(node_path)
	if path == "/node/property" and method == "POST":
		return _handle_set_node_property(body)
	if path == "/open_scenes" and method == "GET":
		return _handle_open_scenes()
	if path == "/current_scene" and method == "GET":
		return _handle_current_scene()
	return null  # 404

func _handle_run() -> Dictionary:
	if not _editor_interface:
		return {"error": "EditorInterface not available"}
	_editor_interface.play_main_scene()
	return {"ok": true, "message": "Playing main scene"}

func _handle_stop() -> Dictionary:
	if not _editor_interface:
		return {"error": "EditorInterface not available"}
	_editor_interface.stop_playing_scene()
	return {"ok": true, "message": "Stopped"}

func _handle_log(tail: int) -> Dictionary:
	tail = clampi(tail, 1, 10000)
	var log_file := _get_log_path()
	if not FileAccess.file_exists(log_file):
		return {"lines": [], "message": "Log file not found"}
	var file := FileAccess.open(log_file, FileAccess.READ)
	if not file:
		return {"lines": [], "error": "Could not open log file"}
	var all_lines: PackedStringArray = []
	while not file.eof_reached():
		all_lines.append(file.get_line())
	file.close()
	var start := maxi(0, all_lines.size() - tail)
	var lines: Array = []
	for i in range(start, all_lines.size()):
		lines.append(all_lines[i])
	return {"lines": lines}

func _handle_errors() -> Dictionary:
	var log_file := _get_log_path()
	if not FileAccess.file_exists(log_file):
		return {"errors": []}
	var file := FileAccess.open(log_file, FileAccess.READ)
	if not file:
		return {"errors": []}
	var errors: Array = []
	while not file.eof_reached():
		var line: String = file.get_line()
		if line.to_lower().contains("error") or line.contains("ERROR"):
			var parsed := _parse_error_line(line)
			errors.append(parsed)
	file.close()
	# Return last N errors
	var recent := errors.slice(-50)
	return {"errors": recent}

func _parse_error_line(line: String) -> Dictionary:
	# Try to extract file:line and message
	var result := {"raw": line, "file": "", "line": 0, "message": line}
	# Godot format: "res://path/script.gd:42: message"
	var regex := RegEx.new()
	regex.compile("^(.+):(\\d+):\\s*(.*)$")
	var m := regex.search(line)
	if m:
		result.file = m.get_string(1).strip_edges()
		result.line = int(m.get_string(2))
		result.message = m.get_string(3).strip_edges()
	return result

func _handle_scene_tree(scene_param: String) -> Dictionary:
	if not _editor_interface:
		return {"error": "EditorInterface not available"}
	var root: Node = _editor_interface.get_edited_scene_root()
	if not root:
		return {"nodes": [], "error": "No scene open"}
	if scene_param != "current" and scene_param != "":
		# Could open scene by path - for Phase 1 we only support current
		pass
	var nodes: Array = []
	_collect_scene_tree(root, "", nodes)
	return {"nodes": nodes, "root_path": root.get_path()}

func _collect_scene_tree(node: Node, base_path: String, out: Array) -> void:
	var path: String = base_path + "/" + node.name if base_path else node.name
	out.append({"path": path, "type": node.get_class()})
	for i in range(node.get_child_count()):
		_collect_scene_tree(node.get_child(i), path, out)

func _handle_selected() -> Dictionary:
	if not _editor_interface:
		return {"paths": [], "error": "EditorInterface not available"}
	var selection := _editor_interface.get_selection()
	if not selection:
		return {"paths": []}
	var nodes: Array = selection.get_selected_nodes()
	var paths: Array = []
	for node in nodes:
		if is_instance_valid(node):
			paths.append(node.get_path())
	return {"paths": paths}

func _handle_node_properties(node_path: String) -> Dictionary:
	if node_path.is_empty():
		return {"error": "path query required"}
	if not _editor_interface:
		return {"error": "EditorInterface not available"}
	var root: Node = _editor_interface.get_edited_scene_root()
	if not root:
		return {"error": "No scene open"}
	var node: Node = root.get_node_or_null(node_path)
	if not node:
		return {"error": "Node not found: %s" % node_path}
	var props: Array = []
	var script_attached := ""
	for i in range(node.get_property_list().size()):
		var pinfo: Dictionary = node.get_property_list()[i]
		var name_str: String = pinfo.name
		if name_str.begins_with("_"):
			continue
		var usage: int = pinfo.get("usage", 0)
		if usage & (PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		var val = node.get(name_str)
		var type_name: String = _variant_type_name(pinfo.type)
		props.append({"name": name_str, "type": type_name, "value": _variant_to_json(val)})
	if node.get_script():
		script_attached = node.get_script().resource_path
	return {"path": node_path, "type": node.get_class(), "properties": props, "script": script_attached}

func _handle_set_node_property(body: String) -> Dictionary:
	var data := JSON.parse_string(body)
	if not data or not data is Dictionary:
		return {"error": "Invalid JSON body"}
	var path_param: String = data.get("path", "")
	var prop: String = data.get("property", "")
	var value = data.get("value")
	if path_param.is_empty() or prop.is_empty():
		return {"error": "path, property, and value required"}
	if not _editor_interface:
		return {"error": "EditorInterface not available"}
	var root: Node = _editor_interface.get_edited_scene_root()
	if not root:
		return {"error": "No scene open"}
	var node: Node = root.get_node_or_null(path_param)
	if not node:
		return {"error": "Node not found: %s" % path_param}
	# Use EditorUndoRedo for proper undo support
	var undo: UndoRedo = _editor_interface.get_editor_undo_redo()
	undo.create_action("MCP: Set %s.%s" % [path_param, prop])
	undo.add_do_property(node, prop, _json_to_variant(value, node.get(prop)))
	undo.add_undo_property(node, prop, node.get(prop))
	undo.commit_action()
	return {"ok": true, "path": path_param, "property": prop}

func _handle_open_scenes() -> Dictionary:
	if not _editor_interface:
		return {"paths": [], "error": "EditorInterface not available"}
	var paths: PackedStringArray = _editor_interface.get_open_scenes()
	return {"paths": Array(paths)}

func _handle_current_scene() -> Dictionary:
	if not _editor_interface:
		return {"path": "", "error": "EditorInterface not available"}
	var root: Node = _editor_interface.get_edited_scene_root()
	if not root:
		return {"path": ""}
	return {"path": root.scene_file_path if root.scene_file_path else ""}

func _get_log_path() -> String:
	# user://logs/godot.log expands to {user_data_dir}/logs/godot.log
	return OS.get_user_data_dir().path_join("logs").path_join("godot.log")

func _variant_type_name(t: Variant.Type) -> String:
	match t:
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "String"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR3: return "Vector3"
		TYPE_COLOR: return "Color"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_OBJECT: return "Object"
		_: return "unknown"

func _variant_to_json(v: Variant) -> Variant:
	if v == null:
		return null
	if v is Vector2:
		return {"x": v.x, "y": v.y}
	if v is Vector3:
		return {"x": v.x, "y": v.y, "z": v.z}
	if v is Color:
		return {"r": v.r, "g": v.g, "b": v.b, "a": v.a}
	if v is NodePath:
		return str(v)
	if v is Object:
		return str(v)
	return v

func _json_to_variant(j: Variant, current: Variant) -> Variant:
	if j == null:
		return current
	if current is Vector2 and j is Dictionary:
		return Vector2(j.get("x", 0), j.get("y", 0))
	if current is Vector3 and j is Dictionary:
		return Vector3(j.get("x", 0), j.get("y", 0), j.get("z", 0))
	if current is Color and j is Dictionary:
		return Color(j.get("r", 1), j.get("g", 1), j.get("b", 1), j.get("a", 1))
	if current is NodePath and j is String:
		return NodePath(j)
	return j

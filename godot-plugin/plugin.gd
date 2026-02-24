@tool
extends EditorPlugin
## Godot MCP - HTTP API for Cursor integration.
## Exposes run, stop, logs, scene inspection, and node editing.

const DEFAULT_PORT := 4242

var _http_server: RefCounted
var _api_handlers: RefCounted

func _enter_tree() -> void:
	var port: int = _get_port()
	var ApiHandlersScript := preload("res://godot-plugin/api_handlers.gd")
	var HttpServerScript := preload("res://godot-plugin/http_server.gd")
	_api_handlers = ApiHandlersScript.new(get_editor_interface())
	_http_server = HttpServerScript.new(port, _api_handlers)
	if not _http_server.start():
		push_error("Godot MCP: Failed to start HTTP server on port %d" % port)
		return

func _exit_tree() -> void:
	if _http_server:
		_http_server.stop()
		_http_server = null

func _process(_delta: float) -> void:
	if _http_server:
		_http_server.poll()

func _get_port() -> int:
	var settings := get_editor_interface().get_editor_settings()
	if settings.has_setting("godot_mcp/port"):
		return settings.get_setting("godot_mcp/port")
	settings.set_setting("godot_mcp/port", DEFAULT_PORT)
	return DEFAULT_PORT

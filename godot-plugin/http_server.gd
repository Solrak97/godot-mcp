extends RefCounted
## Minimal HTTP server using TCPServer.
## Handles GET/POST with query params and JSON body parsing.

const DEFAULT_PORT := 4242

var _server: TCPServer
var _port: int = DEFAULT_PORT
var _handlers: RefCounted
var _peers: Array[StreamPeerTCP] = []
var _peer_buffers: Dictionary = {}  # peer.get_instance_id() -> buffer string

func _init(port: int = DEFAULT_PORT, handlers: RefCounted = null) -> void:
	_port = port
	_handlers = handlers

func start() -> bool:
	_server = TCPServer.new()
	var err := _server.listen(_port, "127.0.0.1")
	if err != OK:
		push_error("Godot MCP: Failed to bind to port %d: %s" % [_port, error_string(err)])
		return false
	print("Godot MCP: HTTP server listening on http://127.0.0.1:%d" % _port)
	return true

func stop() -> void:
	for peer in _peers:
		peer.disconnect_from_host()
	_peers.clear()
	_peer_buffers.clear()
	if _server:
		_server.stop()
		_server = null

func poll() -> void:
	if not _server:
		return
	# Accept new connections
	while _server.is_connection_available():
		var peer: StreamPeerTCP = _server.take_connection()
		if peer:
			_peers.append(peer)
	# Process existing peers
	var to_remove: Array[int] = []
	for i in range(_peers.size() - 1, -1, -1):
		var peer: StreamPeerTCP = _peers[i]
		if peer.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			var available := peer.get_available_bytes()
			if available > 0:
				var data: PackedByteArray = peer.get_data(available)[1]
				var pid := peer.get_instance_id()
				if not _peer_buffers.has(pid):
					_peer_buffers[pid] = ""
				_peer_buffers[pid] += data.get_string_from_utf8()
				var result := _try_handle_request(peer, _peer_buffers[pid])
				if result.complete:
					_peer_buffers.erase(pid)
					peer.disconnect_from_host()
					to_remove.append(i)
				else:
					_peer_buffers[pid] = result.buffer
		else:
			_peer_buffers.erase(peer.get_instance_id())
			to_remove.append(i)
	for i in to_remove:
		_peers.remove_at(i)

func _try_handle_request(peer: StreamPeerTCP, buffer: String) -> Dictionary:
	# Returns {complete: bool, buffer: str}
	# Look for \r\n\r\n (end of headers)
	var header_end := buffer.find("\r\n\r\n")
	if header_end < 0:
		return {complete = false, buffer = buffer}
	var headers_str: String = buffer.substr(0, header_end)
	var body_start: int = header_end + 4
	var body_str: String = ""
	# Parse Content-Length for body
	var content_length := 0
	var lines := headers_str.split("\r\n")
	for line in lines:
		if line.to_lower().begins_with("content-length:"):
			content_length = int(line.substr(14).strip_edges())
			break
	if content_length > 0:
		if buffer.length() < body_start + content_length:
			return {complete = false, buffer = buffer}
		body_str = buffer.substr(body_start, content_length)
	# Parse request line
	var request_line: String = lines[0]
	var parts := request_line.split(" ")
	if parts.size() < 2:
		_send_response(peer, 400, "{}")
		return true
	var method: String = parts[0]
	var path_and_query: String = parts[1]
	var path: String = path_and_query
	var query: Dictionary = {}
	var qidx := path_and_query.find("?")
	if qidx >= 0:
		path = path_and_query.substr(0, qidx)
		var query_str: String = path_and_query.substr(qidx + 1)
		for pair in query_str.split("&"):
			var kv := pair.split("=", true, 1)
			if kv.size() == 2:
				query[kv[0]] = kv[1].uri_decode()
	# Route
	var response: Dictionary = {"error": "Not found"}
	var status := 404
	if _handlers:
		var result = _handlers.handle(method, path, query, body_str)
		if result is Dictionary:
			if result.has("status"):
				status = result.status
				response = result.get("body", {})
			else:
				status = 200
				response = result
	_send_response(peer, status, JSON.stringify(response))
	return {complete = true, buffer = ""}

func _send_response(peer: StreamPeerTCP, status: int, body: String) -> void:
	var status_text := "OK" if status == 200 else "Bad Request" if status == 400 else "Not Found"
	var response := "HTTP/1.1 %d %s\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s" % [status, status_text, body.utf8_buffer().size(), body]
	peer.put_data(response.to_utf8_buffer())

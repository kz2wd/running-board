extends Node
class_name ConnectedClient

var client_name: String
var client_id: int
var is_ready: bool

signal on_name_change
signal on_ready_change

func change_name(new_name: String):
	client_name = new_name
	on_name_change.emit()
	
func change_ready_status(new_status: bool):
	is_ready = new_status
	on_ready_change.emit()

static func create(id: int, c_name: String, _is_ready: bool = true) -> ConnectedClient:
	var c = ConnectedClient.new()
	c.client_id = id
	c.client_name = c_name
	c.is_ready = _is_ready
	return c

# --- Serialization helpers ---
func to_dict() -> Dictionary:
	return {
		"id": client_id,
		"name": client_name,
		"is_ready": is_ready
	}

static func from_dict(data: Dictionary) -> ConnectedClient:
	return ConnectedClient.create(data["id"], data["name"], data["is_ready"])

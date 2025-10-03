extends Node
class_name ConnectedClient

var client_name: String
var client_id: int

signal on_name_change

func change_name(new_name: String):
	client_name = new_name
	on_name_change.emit()

static func create(id: int, c_name: String) -> ConnectedClient:
	var c = ConnectedClient.new()
	c.client_id = id
	c.client_name = c_name
	return c

# --- Serialization helpers ---
func to_dict() -> Dictionary:
	return {
		"id": client_id,
		"name": client_name,
	}

static func from_dict(data: Dictionary) -> ConnectedClient:
	return ConnectedClient.create(data["id"], data["name"])

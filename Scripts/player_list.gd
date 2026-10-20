class_name PlayerElement extends RefCounted


enum PLAYER_TYPE{
	REAL,
	IA
}
var id:int
var type:PLAYER_TYPE
var name:String

func to_dict() -> Dictionary:
	return {"id": id, "type": type, "name": name}

static func from_dict(data: Dictionary) -> PlayerElement:
	var element := PlayerElement.new()
	element.id = data.id
	element.type = data.type
	element.name = data.name
	return element

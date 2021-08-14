extends Node

class_name DictionaryHelper

static func pushObjectToDictionary(dictionary: Dictionary, body: Node, bodyId)->Dictionary:
	var id
	
	if bodyId != null:
		id= bodyId
	else :
		id = body.get_instance_id()
	
	var isObjectExists: = dictionary.has(id)
	if not isObjectExists:
		dictionary[id] = body
	return dictionary

static func removeObjectFromDictionary(dictionary: Dictionary, body: Node, bodyId)->Dictionary:
	var id
	
	if bodyId != null:
		id= bodyId
	else :
		id = body.get_instance_id()
	
	var isObjectExists: = dictionary.has(id)
	if isObjectExists:
		dictionary.erase(id)
	return dictionary

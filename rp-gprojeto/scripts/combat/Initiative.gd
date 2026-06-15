extends Node2D
class_name Initiative

class NodeInitiative:
	var _nome:String
	var nome:String:
		get: return self.get_nome()
		set(new): self.set_nome(new)
	var _value:float
	var value:float:
		get: return self.get_value()
		set(new): self.set_value(new)
	var next:NodeInitiative
	var prev:NodeInitiative
	var dict_key:String
	func _init(nome_:String, value_ini:float, next_p:NodeInitiative=null, prev_p:NodeInitiative=null) -> void:
		nome = nome_
		dict_key = nome_
		value = value_ini
		next = next_p
		prev = prev_p
	func get_nome() -> String:
		return _nome
	func set_nome(new:String) -> void:
		_nome = new.strip_edges().left(15)
	func get_value() -> float:
		return _value
	func set_value(new:float) -> void:
		_value = max(new, 1.0)
	func set_free() -> void:
		next=null
		prev=null
class CharacterNode extends NodeInitiative:
	var character:BaseCharacter
	func _init(Character:BaseCharacter, value_ini:float, next_p:NodeInitiative=null, prev_p:NodeInitiative=null) -> void:
		super(Character.first_name, value_ini, next_p, prev_p)
		character = Character
	func set_free() -> void:
		next=null
		prev=null
		character=null
class TimeNode extends NodeInitiative:
	var time:int
	func _init(nome_:String, value_ini:float, inic_time:int=0, next_p:NodeInitiative=null, prev_p:NodeInitiative=null) -> void:
		super(nome_, value_ini, next_p, prev_p)
		time = inic_time
	func set_value(new:float) -> void:
		_value=new

var point:NodeInitiative
var aux_point:NodeInitiative
var last:NodeInitiative
var dict_nodes:Dictionary[String, NodeInitiative]
var dict_character:Dictionary
var node_count:int = 0
var _duplicate:Dictionary[String, int]
func _init(main_character:Playable, npcs:Array[BaseCharacter]) -> void:
	dict_nodes["round_time"] = TimeNode.new("round_time", 0.0, 1)
	point = dict_nodes["round_time"]
	last = dict_nodes["round_time"]
	last.next=last
	last.prev=last
	node_count+=1
	var character:Array[BaseCharacter] = npcs
	character.append(main_character)
	for x in character:
		dict_nodes[x.first_name] = CharacterNode.new(x, x.initiative())
		self.add_node(dict_nodes[x.first_name])
		node_count+=1
	self.sort_initiative()
func add_node(node:NodeInitiative) -> void:
	aux_point=last
	if dict_nodes.size() == 1:
		aux_point.next = node
		node.next = aux_point
		aux_point.prev = node
		node.prev = aux_point
	else:
		while aux_point.next.value > node.value and aux_point.next!=last:
			aux_point=aux_point.next
		var temp := aux_point.next
		node.next = temp
		node.prev = aux_point
		aux_point.next = node
		temp.prev = node
func remove_node(node:NodeInitiative) -> void:
	aux_point=last.next
	if last==node or dict_nodes.size()==1:
		push_warning("Não pode remover o nó auxiliar")
		return
	elif dict_nodes.size()==2:
		var temp:=last.next
		last.next=last
		last.prev=last
		dict_nodes.erase(temp.dict_key)
		temp.set_free()
		temp.free()
		node_count-=1
		return
	while aux_point!=node and aux_point!=last:
		aux_point=aux_point.next
	if aux_point == node:
		var temp_prev := aux_point.prev
		var temp_next := aux_point.next
		temp_prev.next = temp_next
		temp_next.prev = temp_prev
		dict_nodes.erase(aux_point.dict_key)
		aux_point.set_free()
		aux_point.free()
		node_count-=1
	else:
		print("A iniciativo %s não foi encontrada", node.nome)
func sort_initiative() -> void:
	var swapper:bool = true
	while swapper:
		swapper = false
		aux_point=last.next
		while aux_point!=last and aux_point.next!=last:
			if aux_point.value<aux_point.next.value:
				var temp_prev = aux_point.prev
				var temp_target = aux_point.next
				var temp_next = aux_point.next.next
				aux_point.next=temp_next
				aux_point.prev=temp_target
				temp_target.next=aux_point
				temp_target.prev=temp_prev
				temp_prev.next=temp_target
				temp_next.prev=aux_point
				swapper=true
			else:
				aux_point=aux_point.next
func next()->void:
	point=point.next
	if point==last:
		last.time+=1
		point=point.next
func prev()->void:
	if point.prev==last:
		return
	point=point.prev
func get_current()->NodeInitiative: return point
func get_by_name(nome:String)->NodeInitiative:
	return dict_nodes[nome] if dict_nodes.has(nome) else null
func add_to_dic(new:NodeInitiative)->void:
	var key:String = new.nome
	if key == last.dict_key:
		push_warning("Error, Node não pode ter o mesmo nome do sentinela")
		return
	if dict_nodes.has(key):
		if not _duplicate.has(key):
			_duplicate[key]=0
		_duplicate[key]+=1
		key = "%s_%d" % [new.nome, _duplicate[new.nome]]
		new.dict_key=key
	dict_nodes[key] = new

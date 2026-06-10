# MissionManager.gd
# Vive dentro do Game (autoload), igual ao inventário, para sobreviver à troca de mapa. 
#Controla quais missões estão ativas, avança conforme a escolha do jogador 
#e entrega a recompensa no fim (usando o inventário).

class_name MissionManager
extends RefCounted

signal missao_iniciada(id)
signal missao_atualizada(id)
signal missao_concluida(id)

var inventory: Inventory          # definido pelo Game, usado para dar recompensa
var missoes: Dictionary = {}      # id -> Mission (todas que já foram iniciadas)
var foco: String = ""             # missão em foco no menu

# Gatilho de iniciar
func iniciar(id: String) -> bool:
	if missoes.has(id):
		return false
	var m := MissionDatabase.get_mission(id)
	if m == null:
		push_warning("Missão desconhecida: " + id)
		return false
	# valida o RNF de profundidade (algoritmo DFS com limite de 20 níveis)
	if not MissionTree.valida(m):
		push_warning("Missão '%s' passa da profundidade máxima de 20." % id)
		return false
	m.iniciar()
	missoes[id] = m
	foco = id
	missao_iniciada.emit(id)
	return true

# Avança a missão pela escolha do jogador 
func escolher(id: String, indice: int) -> void:
	var m: Mission = missoes.get(id)
	if m == null or m.concluida:
		return
	if not m.escolher(indice):
		return
	if m.concluida:
		_concluir(m)
	else:
		missao_atualizada.emit(id)

# Avanço AUTOMÁTICO pelo mundo 
# Para missões lineares: segue sempre a 1ª escolha disponível, passo a passo,
# até chegar num nó final — aí conclui e entrega a recompensa. É o que um
# gatilho do mundo chama quando o jogador chega na saída/zona, sem clicar nada.
func avancar(id: String) -> void:
	var m: Mission = missoes.get(id)
	if m == null or m.concluida:
		return
	var seguranca: int = 0       # trava contra loop (caso alguém crie um ciclo)
	while not m.concluida and not m.escolhas().is_empty() and seguranca < 64:
		if not m.escolher(0):
			break
		seguranca += 1
	if m.concluida:
		_concluir(m)
	else:
		missao_atualizada.emit(id)

# Gatilho de concluir direto (sem escolha) 
func concluir(id: String) -> void:
	var m: Mission = missoes.get(id)
	if m == null or m.concluida:
		return
	m.concluida = true
	_concluir(m)

func _concluir(m: Mission) -> void:
	# entrega a recompensa (RF-14c) usando o inventário
	var r: Dictionary = m.recompensa()
	if inventory != null:
		if r.has("moedas"):
			inventory.add_coins(int(r["moedas"]))
		for it in r.get("itens", []):
			var item = ItemDatabase.get_item(it.get("id", ""))
			if item != null:
				inventory.add_item(item, int(it.get("qtd", 1)))
	missao_concluida.emit(m.id)

func objetivo_atual(id: String) -> String:
	var m: Mission = missoes.get(id)
	return m.objetivo() if m != null else ""

func lista() -> Array:
	return missoes.values()

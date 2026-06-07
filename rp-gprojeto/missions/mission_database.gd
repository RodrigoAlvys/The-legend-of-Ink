# MissionDatabase.gd
# Missões de exemplo, criadas em código (igual ao ItemDatabase).
# "despertar" é linear; "gosma" tem uma ramificação (escolha do jogador).

class_name MissionDatabase
extends RefCounted

static func get_mission(id: String) -> Mission:
	match id:
		"despertar":
			return _despertar()
		"gosma":
			return _gosma()
	return null

static func todas_ids() -> Array:
	return ["despertar", "gosma"]

# Missão LINEAR 
static func _despertar() -> Mission:
	var m := Mission.new()
	m.id = "despertar"
	m.titulo = "O Despertar de Ink"
	m.no_inicial = "inicio"
	m.auto = true               # avança sozinha quando o jogador chega na saída
	m.nos = {
		"inicio": {
			"descricao": "Você acorda sem memória numa terra manchada de gosma preta.",
			"objetivo": "Levante-se e procure uma saída.",
			"escolhas": [ {"texto": "Procurar a saída", "proximo": "saida"} ],
			"fim": false,
		},
		"saida": {
			"descricao": "Uma fenda na parede deixa passar um fio de luz.",
			"objetivo": "Atravesse a fenda.",
			"escolhas": [ {"texto": "Atravessar", "proximo": "fim"} ],
			"fim": false,
		},
		"fim": {
			"descricao": "Você sai para o mundo aberto. A jornada começa.",
			"objetivo": "Missão concluída.",
			"escolhas": [],
			"fim": true,
			"recompensa": { "moedas": 20, "itens": [ {"id": "potion_s", "qtd": 1} ] },
		},
	}
	return m

# Missão COM RAMIFICAÇÃO 
static func _gosma() -> Mission:
	var m := Mission.new()
	m.id = "gosma"
	m.titulo = "A Gosma Misteriosa"
	m.no_inicial = "encontro"
	m.nos = {
		"encontro": {
			"descricao": "Um slime de gosma preta bloqueia o caminho.",
			"objetivo": "Decida o que fazer.",
			"escolhas": [
				{"texto": "Enfrentar o slime", "proximo": "lutar"},
				{"texto": "Fugir e avisar o aldeão", "proximo": "avisar"},
			],
			"fim": false,
		},
		"lutar": {
			"descricao": "Você encara a gosma de frente.",
			"objetivo": "Derrote o slime.",
			"escolhas": [ {"texto": "Vencer a luta", "proximo": "fim_luta"} ],
			"fim": false,
		},
		"fim_luta": {
			"descricao": "O slime se desfaz no chão. Você se sente mais forte.",
			"objetivo": "Missão concluída pela força.",
			"escolhas": [],
			"fim": true,
			"recompensa": { "moedas": 30, "itens": [ {"id": "sword_rusty", "qtd": 1} ] },
		},
		"avisar": {
			"descricao": "Você corre até o aldeão e conta sobre a gosma.",
			"objetivo": "Missão concluída pela cautela.",
			"escolhas": [],
			"fim": true,
			"recompensa": { "moedas": 15, "itens": [ {"id": "map_fragment", "qtd": 1} ] },
		},
	}
	return m

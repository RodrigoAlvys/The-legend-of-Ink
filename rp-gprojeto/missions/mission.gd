# Mission.gd
# Uma missão é uma ÁRVORE de nós (etapas). Cada nó tem descrição, objetivo,
# escolhas (ramificações) e, se for um nó final, uma recompensa.
# Esta classe guarda a definição da árvore + o estado atual (em que nó está).
class_name Mission
extends RefCounted

var id: String = ""
var titulo: String = ""
var nos: Dictionary = {}          # id_do_no -> dicionário do nó
var no_inicial: String = ""
var auto: bool = false            # true = avança sozinha pelo mundo (sem clicar no menu)

# estado em tempo de jogo
var no_atual_id: String = ""
var iniciada: bool = false
var concluida: bool = false

# Estrutura de cada nó (dicionário):
# {
#   "descricao": String,
#   "objetivo": String,
#   "escolhas": [ {"texto": String, "proximo": String}, ... ],   # vazio = sem ação
#   "fim": bool,                                                  # nó final?
#   "recompensa": { "moedas": int, "itens": [ {"id": String, "qtd": int} ] }
# }

func iniciar() -> void:
	no_atual_id = no_inicial
	iniciada = true
	concluida = false

func no_atual() -> Dictionary:
	return nos.get(no_atual_id, {})

func descricao() -> String:
	return no_atual().get("descricao", "")

func objetivo() -> String:
	return no_atual().get("objetivo", "")

func escolhas() -> Array:
	return no_atual().get("escolhas", [])

func eh_fim() -> bool:
	return no_atual().get("fim", false)

func recompensa() -> Dictionary:
	return no_atual().get("recompensa", {})

# Avança pela escolha de índice i. Retorna true se mudou de nó.
func escolher(i: int) -> bool:
	var ops: Array = escolhas()
	if i < 0 or i >= ops.size():
		return false
	var prox: String = ops[i].get("proximo", "")
	if not nos.has(prox):
		return false
	no_atual_id = prox
	if eh_fim():
		concluida = true
	return true

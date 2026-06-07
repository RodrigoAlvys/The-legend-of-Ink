# MissionTree.gd
# Segundo problema computacional desta US: BUSCA EM ÁRVORE/GRAFO (DFS).
#
# A árvore de uma missão é percorrida com uma busca em profundidade (DFS),
# controlando o nível atual e detectando ciclos (um nó não pode aparecer duas
# vezes no mesmo caminho). Isso atende ao RNF: "limite de profundidade
# até 20", a árvore não pode descer além de 20 níveis.
# Complexidade: O(V + E) sobre os nós e escolhas alcançáveis.

class_name MissionTree
extends RefCounted

const LIMITE_PADRAO: int = 20

# Profundidade máxima alcançável a partir do nó inicial.
static func profundidade_maxima(m: Mission) -> int:
	return _dfs(m, m.no_inicial, {}, 1)

# true se a árvore da missão respeita o limite de profundidade.
static func valida(m: Mission, limite: int = LIMITE_PADRAO) -> bool:
	return profundidade_maxima(m) <= limite

static func _dfs(m: Mission, no_id: String, caminho: Dictionary, prof: int) -> int:
	if not m.nos.has(no_id):
		return prof - 1
	if caminho.has(no_id):
		return prof - 1            # ciclo neste caminho: não desce de novo
	if prof > LIMITE_PADRAO:
		return prof                # estourou o limite: para de descer
	caminho[no_id] = true
	var maior: int = prof
	for escolha in m.nos[no_id].get("escolhas", []):
		# duplica o caminho para cada ramo (permite "diamantes", barra ciclos)
		var d: int = _dfs(m, escolha.get("proximo", ""), caminho.duplicate(), prof + 1)
		if d > maior:
			maior = d
	return maior

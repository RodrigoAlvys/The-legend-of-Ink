# Shop.gd
# Lógica da loja (US-10). Trabalha com um "carrinho": o jogador escolhe o que
# comprar e o que vender, vê o montante final (o que vai gastar/ganhar) e só no
# botão Confirmar a transação acontece de verdade — atualizando moedas e itens.
class_name Shop
extends RefCounted

const RAZAO_VENDA: float = 0.5   # a loja paga metade do valor ao comprar de você

var inventory: Inventory
var estoque: Array = []          # ids dos itens que o mercador vende

# carrinho: id do item -> quantidade
var compras: Dictionary = {}
var vendas: Dictionary = {}

# ---------------- preços ----------------
func preco_compra(item: Item) -> int:
	return item.value

func preco_venda(item: Item) -> int:
	return int(floor(item.value * RAZAO_VENDA))

# ---------------- carrinho ----------------
func add_compra(id: String) -> void:
	compras[id] = int(compras.get(id, 0)) + 1

func tira_compra(id: String) -> void:
	if compras.has(id):
		compras[id] -= 1
		if compras[id] <= 0:
			compras.erase(id)

# Só vende item que o jogador tem e que não seja de missão; respeita a quantidade.
func add_venda(id: String) -> void:
	var item := ItemDatabase.get_item(id)
	if item == null or item.type == Item.Type.QUEST:
		return
	var tem: int = inventory.get_count(item)
	if int(vendas.get(id, 0)) < tem:
		vendas[id] = int(vendas.get(id, 0)) + 1

func tira_venda(id: String) -> void:
	if vendas.has(id):
		vendas[id] -= 1
		if vendas[id] <= 0:
			vendas.erase(id)

func limpar() -> void:
	compras.clear()
	vendas.clear()

# ---------------- balanço (RF-10c) ----------------
func custo_compras() -> int:
	var total: int = 0
	for id in compras:
		total += preco_compra(ItemDatabase.get_item(id)) * compras[id]
	return total

func ganho_vendas() -> int:
	var total: int = 0
	for id in vendas:
		total += preco_venda(ItemDatabase.get_item(id)) * vendas[id]
	return total

# Montante final: quanto as moedas mudam no fim (vendas entram, compras saem).
func montante() -> int:
	return ganho_vendas() - custo_compras()

func moedas_apos() -> int:
	return inventory.coins + montante()

# ---------------- validação ----------------
func tem_moedas() -> bool:
	return moedas_apos() >= 0

# Conta quantos slots o inventário usaria depois da transação (compras ocupam,
# vendas liberam), respeitando empilháveis. Nega a compra se não couber.
func cabe_no_inventario() -> bool:
	var bolsa: Dictionary = {}   # id -> {item, count}
	for s in inventory.slots:
		var it: Item = s["item"]
		var atual: int = int(bolsa[it.id]["count"]) if bolsa.has(it.id) else 0
		bolsa[it.id] = {"item": it, "count": atual + int(s["count"])}
	for id in vendas:
		if bolsa.has(id):
			bolsa[id]["count"] -= vendas[id]
			if bolsa[id]["count"] <= 0:
				bolsa.erase(id)
	for id in compras:
		var it := ItemDatabase.get_item(id)
		var atual: int = int(bolsa[id]["count"]) if bolsa.has(id) else 0
		bolsa[id] = {"item": it, "count": atual + compras[id]}
	var usados: int = 0
	for id in bolsa:
		var it: Item = bolsa[id]["item"]
		usados += 1 if it.stackable else int(bolsa[id]["count"])
	return usados <= Inventory.MAX_SLOTS

func pode_confirmar() -> bool:
	if compras.is_empty() and vendas.is_empty():
		return false
	return tem_moedas() and cabe_no_inventario()

# ---------------- finalizar (RF-10a / RF-10b / RF-10f) ----------------
# Aplica tudo de uma vez: vende (libera espaço + ganha moedas), depois compra.
func confirmar() -> bool:
	if not pode_confirmar():
		return false
	for id in vendas:
		var item := ItemDatabase.get_item(id)
		for i in range(vendas[id]):       # 1 a 1 (cobre item não-empilhável em vários slots)
			inventory.remove_item(item, 1)
		inventory.add_coins(preco_venda(item) * vendas[id])
	for id in compras:
		var item := ItemDatabase.get_item(id)
		inventory.add_coins(-preco_compra(item) * compras[id])
		inventory.add_item(item, compras[id])
	limpar()
	return true

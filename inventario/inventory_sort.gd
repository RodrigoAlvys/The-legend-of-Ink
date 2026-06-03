# InventorySort.gd
# ORDENAÇÃO (Quicksort).
#
# Quicksort in-place, com escolha de pivô por "mediana de três" para evitar o
# pior caso O(n^2) em listas já ordenadas ou inversas. Para o tamanho de um
# inventário (dezenas de itens) o tempo é praticamente instantâneo, atendendo
# ao RNF "pior caso do organizador < 1s".
#
# Complexidade: O(n log n) no caso médio; O(n^2) no pior caso teórico.
class_name InventorySort
extends RefCounted

enum Criteria { NAME, TYPE, VALUE_ASC, VALUE_DESC }

# Ordena o array de slots IN-PLACE (slots é passado por referência).
static func sort_slots(slots: Array, criteria: int) -> void:
	if slots.size() <= 1:
		return
	var less: Callable = _comparator(criteria)
	_quicksort(slots, 0, slots.size() - 1, less)

# Retorna um comparador "a vem antes de b".
static func _comparator(criteria: int) -> Callable:
	match criteria:
		Criteria.NAME:
			return func(a, b):
				return InventorySort._name(a) < InventorySort._name(b)
		Criteria.TYPE:
			return func(a, b):
				if InventorySort._type(a) == InventorySort._type(b):
					return InventorySort._name(a) < InventorySort._name(b)
				return InventorySort._type(a) < InventorySort._type(b)
		Criteria.VALUE_ASC:
			return func(a, b):
				if InventorySort._value(a) == InventorySort._value(b):
					return InventorySort._name(a) < InventorySort._name(b)
				return InventorySort._value(a) < InventorySort._value(b)
		Criteria.VALUE_DESC:
			return func(a, b):
				if InventorySort._value(a) == InventorySort._value(b):
					return InventorySort._name(a) < InventorySort._name(b)
				return InventorySort._value(a) > InventorySort._value(b)
	return func(a, b):
		return false

static func _name(slot) -> String:
	return str(slot["item"].name).to_lower()

static func _type(slot) -> int:
	return int(slot["item"].type)

static func _value(slot) -> int:
	return int(slot["item"].value)

static func _quicksort(arr: Array, lo: int, hi: int, less: Callable) -> void:
	while lo < hi:
		var p: int = _partition(arr, lo, hi, less)
		# Recursa primeiro no lado menor para limitar a profundidade da pilha.
		if p - lo < hi - p:
			_quicksort(arr, lo, p - 1, less)
			lo = p + 1
		else:
			_quicksort(arr, p + 1, hi, less)
			hi = p - 1

static func _partition(arr: Array, lo: int, hi: int, less: Callable) -> int:
	var mid: int = (lo + hi) >> 1
	_median_of_three(arr, lo, mid, hi, less)   # coloca a mediana em 'hi' como pivô
	var pivot = arr[hi]
	var i: int = lo - 1
	for j in range(lo, hi):
		if less.call(arr[j], pivot):
			i += 1
			_swap(arr, i, j)
	_swap(arr, i + 1, hi)
	return i + 1

static func _median_of_three(arr: Array, lo: int, mid: int, hi: int, less: Callable) -> void:
	if less.call(arr[mid], arr[lo]):
		_swap(arr, lo, mid)
	if less.call(arr[hi], arr[lo]):
		_swap(arr, lo, hi)
	if less.call(arr[hi], arr[mid]):
		_swap(arr, mid, hi)
	_swap(arr, mid, hi)   # move a mediana para a posição do pivô (hi)

static func _swap(arr: Array, i: int, j: int) -> void:
	var tmp = arr[i]
	arr[i] = arr[j]
	arr[j] = tmp

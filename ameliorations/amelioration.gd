extends Resource
class_name Amelioration

@export var id: String
@export var nom: String
@export var cout_de_base: int
@export var multiplicateur_cout: float
@export var bonus_de_base: float

func cout_pour_lvl(lvl: int) -> float:
	return cout_de_base * pow(multiplicateur_cout, float(lvl))

func bonus_pour_lvl(lvl: int) -> float:
	return bonus_de_base * float(lvl)

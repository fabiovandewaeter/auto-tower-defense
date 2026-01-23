extends Resource
class_name Amelioration

@export var id: String
@export var nom: String
@export var cout_de_base: int
@export var multiplicateur_cout: float
@export var bonus_de_base: float
var lvl_actuel: int

# getters
func cout_pour_lvl(lvl: int) -> float:
	return cout_de_base * pow(multiplicateur_cout, float(lvl))
	
func cout_pour_lvl_actuel() -> float:
	return cout_pour_lvl(lvl_actuel)

func bonus_pour_lvl(lvl: int) -> float:
	return bonus_de_base * float(lvl)

func bonus_pour_lvl_actuel(lvl: int) -> float:
	return bonus_pour_lvl(lvl_actuel)

func acheter():
	lvl_actuel += 1

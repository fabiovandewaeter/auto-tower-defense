extends Resource
class_name Amelioration

@export var id: String
@export var nom: String
@export var cout_de_base: int
# 1.2 pour +20%
@export var pourcentage_cout_par_lvl: float
@export var bonus_de_base: float
@export var pourcentage_bonus_par_lvl: float
@export var debloquee: bool = false
@export var lvl_actuel: int = 0

func cout_pour_lvl(lvl: int) -> int:
	if lvl == 1:
		return cout_de_base
	return cout_de_base * pow(pourcentage_cout_par_lvl, lvl - 1)

func cout_pour_lvl_actuel() -> int:
	return cout_pour_lvl(lvl_actuel)

func bonus_pour_lvl(lvl: int) -> float:
	return bonus_de_base * pow(pourcentage_bonus_par_lvl, lvl - 1)

func bonus_pour_lvl_actuel() -> float:
	return bonus_pour_lvl(lvl_actuel)

func acheter():
	lvl_actuel += 1
	debloquee = true

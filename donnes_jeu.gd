extends Node

signal update_points()

var nombre_mobs: int = 0
var points: int = 0
var ameliorations := {}

enum AMELIORATION {CAC, LASER}

func _ready():
	ameliorations[AMELIORATION.CAC] = preload("res://ameliorations/cac.tres")
	ameliorations[AMELIORATION.CAC].debloquee = true
	ameliorations[AMELIORATION.LASER] = preload("res://ameliorations/laser.tres")
	ameliorations[AMELIORATION.LASER].bonus_de_base = 1000

func amelioration_pour(id: AMELIORATION) -> Amelioration:
	return ameliorations[id]

func peut_acheter(amelioration: Amelioration) -> bool:
	var cout = amelioration.cout_pour_lvl_actuel()
	return points >= cout

func acheter(amelioration: Amelioration):
	var cout = amelioration.cout_pour_lvl_actuel()
	if points >= cout:
		points -= cout
		print(str(cout) + " " + str(points) + "lvl: "+ str(amelioration.lvl_actuel))
		amelioration.acheter()
		print(str(amelioration.cout_pour_lvl_actuel()) + " " + str(points) + "lvl: "+ str(amelioration.lvl_actuel))

func mort_mob(mob):
	nombre_mobs -= 1
	points += mob.points_recompense()
	update_points.emit()

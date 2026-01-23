extends Node

signal update_points()
signal stats_updated(nouveau)

var nombre_mobs: int = 0
var points: int = 0

var degats_cac: float = 10.0

func peut_acheter(amelioration: Amelioration) -> bool:
	var cout = amelioration.cout_pour_lvl_actuel()
	return points >= cout

func acheter(amelioration):
	var cout = amelioration.cout_pour_lvl_actuel()
	print(str(cout) + " " + str(points))
	if points >= cout:
		amelioration.acheter()
		points -= cout

func mort_mob(mob):
	nombre_mobs -= 1
	points += mob.points_recompense()
	update_points.emit()

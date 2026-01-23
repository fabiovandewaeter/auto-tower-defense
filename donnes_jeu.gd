# donnes_jeu.gd
extends Node

signal update_points()
signal update_vague()
signal update_ameliorations()

var nombre_mobs: int = 0
var nombre_mobs_tues: int = 0
var points: int = 0
var vague_actuelle: int = 1
var ameliorations := {}

enum AMELIORATION {CAC, LASER}

func _ready():
	ameliorations[AMELIORATION.CAC] = preload("res://ameliorations/cac.tres")
	ameliorations[AMELIORATION.LASER] = preload("res://ameliorations/laser.tres")

func amelioration_pour(id: AMELIORATION) -> Amelioration:
	return ameliorations[id]

func peut_acheter(amelioration: Amelioration) -> bool:
	var cout = amelioration.cout_pour_lvl_actuel()
	return points >= cout

func acheter(amelioration: Amelioration):
	var cout = amelioration.cout_pour_lvl_actuel()
	if points >= cout:
		points -= cout
		amelioration.acheter()
		update_ameliorations.emit()

func mort_mob(mob):
	const PASSAGE_VAGUE: int = 300
	
	nombre_mobs -= 1
	nombre_mobs_tues += 1
	points += mob.recompense_points
	if nombre_mobs_tues % PASSAGE_VAGUE == 0:
		vague_actuelle += 1
		update_vague.emit()
	update_points.emit()

extends Node2D

const LIMITE_NOMBRE_MOBS = 10000

func spawn_mob():
	const MOB = preload("res://mob.tscn")
	
	var new_mob = MOB.instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	new_mob.cible = %Joueur
	new_mob.died.connect(_on_mob_died)
	add_child(new_mob)
	
	DonnesJeu.nombre_mobs += 1
	update_score()

func _on_spawn_mob_timeout() -> void:
	if DonnesJeu.nombre_mobs < LIMITE_NOMBRE_MOBS:
		spawn_mob()

func _on_mob_died(mob):
	DonnesJeu.nombre_mobs -= 1
	var points = mob.points_recompense()
	DonnesJeu.points += points
	update_score()

func update_score():
	%Score.text = str(DonnesJeu.points)+"/"+str(DonnesJeu.nombre_mobs)

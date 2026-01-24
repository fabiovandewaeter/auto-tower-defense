# jeu.gd
extends Node2D

const LIMITE_NOMBRE_MOBS = 200

func spawn_mob():
	const MOB = preload("res://mob.tscn")
	
	var new_mob = MOB.instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	new_mob.cible = %Joueur
	new_mob.set_lvl(DonnesJeu.vague_actuelle)
	new_mob.died.connect(_on_mob_died)
	add_child(new_mob)
	
	DonnesJeu.nombre_mobs += 1

func _on_spawn_mob_timeout() -> void:
	if DonnesJeu.nombre_mobs < LIMITE_NOMBRE_MOBS:
		for i in range(10):
			spawn_mob()

func _on_mob_died(mob):
	DonnesJeu.mort_mob(mob)

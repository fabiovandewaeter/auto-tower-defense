extends StaticBody2D

@export var degats_cac: int = 10.0
@export var cooldown: float = 1.0

func _on_cooldown_ca_c_timeout() -> void:
	var ennemis_proches = %HurtBox.get_overlapping_bodies()
	for body in ennemis_proches:
		if body.is_in_group("mobs") and body.has_method("take_damage"):
			# call_deferred pour éviter problèmes si take_damage fait un queue_free je crois ???
			body.call_deferred("take_damage", degats_cac)

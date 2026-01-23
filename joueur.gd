# joueur.gd
extends StaticBody2D

@export var cooldown: float = 1.0

@onready var amelioration_cac: Amelioration = DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.CAC)
@onready var amelioration_laser: Amelioration = DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.LASER)

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

# attaque au cac
func _on_cooldown_ca_c_timeout() -> void:
	_creer_onde_de_choc()
	
	var ennemis_proches = %HurtBox.get_overlapping_bodies()
	for body in ennemis_proches:
		if body.is_in_group("mobs") and body.has_method("take_damage"):
			# call_deferred pour éviter problèmes si take_damage fait un queue_free je crois ???
			body.call_deferred("take_damage", amelioration_cac.bonus_pour_lvl_actuel())

func _creer_onde_de_choc():
	# On cherche la CollisionShape pour connaître la taille exacte
	# ATTENTION : Assure-toi que ta CollisionShape2D est bien un enfant direct de %HurtBox
	var shape_node = %HurtBox.get_node_or_null("CollisionShape2D")
	if not shape_node or not shape_node.shape is CircleShape2D:
		push_warning("CollisionShape introuvable ou n'est pas un cercle !")
		return

	var rayon = shape_node.shape.radius
	
	# Création du polygone (le cercle visuel)
	var onde = Polygon2D.new()
	onde.color = Color(1, 0.2, 0.2, 0.5) # Rouge semi-transparent
	
	# On dessine le cercle mathématiquement
	var points = PackedVector2Array()
	var nombre_segments = 32 # Plus c'est haut, plus c'est lisse
	for i in range(nombre_segments + 1):
		var angle = i * TAU / nombre_segments
		var point = Vector2(cos(angle), sin(angle)) * rayon
		points.append(point)
	
	onde.polygon = points
	add_child(onde)
	
	# Animation : L'onde part de tout petit, grandit et disparait
	onde.scale = Vector2(0.1, 0.1) # Commence petit
	
	var tween = create_tween()
	tween.set_parallel(true) # Exécuter en même temps
	tween.tween_property(onde, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT) # Grandit
	tween.tween_property(onde, "modulate:a", 0.0, 0.2) # Devient transparent
	
	# Nettoyage à la fin
	tween.chain().tween_callback(onde.queue_free)

func _on_cooldown_laser_timeout() -> void:
	if amelioration_laser.debloquee:
		tirer_laser()

func tirer_laser():
	var mobs = get_tree().get_nodes_in_group("mobs")
	if mobs.is_empty():
		return
	
	var idx = rng.randi_range(0, mobs.size() - 1)
	var cible = mobs[idx]
	var amelioration = DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.LASER)
	if not cible or not cible.is_inside_tree():
		return
	_tirer_laser_vers_position(cible.global_position)

func _tirer_laser_vers_position(target_pos: Vector2):
	# 1. CALCUL DE LA TRAJECTOIRE
	# On calcule la direction vers la cible
	var direction = (target_pos - global_position).normalized()
	# On crée un point très loin (hors de l'écran) dans cette direction
	var bout_du_laser = global_position + (direction * 2000) 

	# 2. VISUEL (Le Rayon)
	# On crée un Line2D à la volée pour l'effet visuel
	var ligne = Line2D.new()
	ligne.width = 10 # Épaisseur du laser
	ligne.default_color = Color.CYAN # Couleur du laser
	# Les points sont en local, donc on part de 0,0 vers la destination relative
	ligne.add_point(Vector2.ZERO) 
	ligne.add_point(to_local(bout_du_laser)) 
	add_child(ligne)
	
	# Petit effet pour faire disparaître le laser doucement
	var tween = create_tween()
	tween.tween_property(ligne, "modulate:a", 0.0, 0.2) # Disparait en 0.2 sec
	tween.tween_callback(ligne.queue_free) # On supprime la node après

	# 3. DÉGÂTS (La logique "Railgun")
	var damage = DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.LASER).bonus_pour_lvl_actuel()
	
	# On récupère tous les mobs
	var mobs = get_tree().get_nodes_in_group("mobs")
	
	for mob in mobs:
		if not is_instance_valid(mob): continue
		
		# C'est ici la magie : On regarde si le mob est proche de la ligne de tir
		# Geometry2D nous donne le point sur le segment le plus proche du mob
		var point_proche = Geometry2D.get_closest_point_to_segment(
			mob.global_position, 
			global_position, 
			bout_du_laser
		)
		
		# Si la distance entre le mob et ce point est courte (ex: 30 pixels), il est touché
		if mob.global_position.distance_to(point_proche) < 30.0:
			if mob.has_method("take_damage"):
				mob.take_damage(damage)

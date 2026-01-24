# joueur.gd
extends StaticBody2D

@export var cooldown: float = 1.0

@onready var amelioration_cac: Amelioration = DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.CAC)
@onready var amelioration_laser: Amelioration = DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.LASER)
@onready var amelioration_explosion_random: Amelioration = DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.EXPLOSION_RANDOM)
@onready var animated_sprite_idle = $Node2D/AnimatedSprite2D
@onready var animated_explosion_random = $Node2D/ExplosionRandom

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	animated_sprite_idle.play()

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
	tween.set_parallel(false) # Exécuter en même temps
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

func _on_cooldown_explosion_random_timeout() -> void:
	if amelioration_explosion_random.debloquee:
		lancer_explosion_random()

func lancer_explosion_random():
	var mobs = get_tree().get_nodes_in_group("mobs")
	if mobs.is_empty():
		return
	
	var idx = rng.randi_range(0, mobs.size() - 1)
	var cible = mobs[idx]
	var amelioration = DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.EXPLOSION_RANDOM)
	if not cible or not cible.is_inside_tree():
		return
	_lancer_explosion_random_a_position(cible.global_position)

func _lancer_explosion_random_a_position(position: Vector2):
	# --- VISUEL : on duplique la node animated_explosion_random et la place à la position cible ---
	# On clone la node pour pouvoir la jouer librement dans la scène
	var explosion = animated_explosion_random.duplicate() # duplicate preserves frames et animations
	explosion.visible = true
	# Assure-toi que l'explosion n'a pas de parent problématique ; on l'ajoute à la scène courante
	var root_scene = get_tree().get_current_scene()
	if root_scene:
		root_scene.add_child(explosion)
	else:
		add_child(explosion) # fallback

	# Place l'explosion à la position voulue (global)
	explosion.global_position = position

	# Choisir une animation aléatoire si plusieurs animations sont définies dans le SpriteFrames
	var anims = []
	# Récupère les noms d'animations si possible
	if explosion.sprite_frames:
		anims = explosion.sprite_frames.get_animation_names()
	
	if anims.size() > 0:
		var idx = rng.randi_range(0, anims.size() - 1)
		var anim_name = anims[idx]
		# joue l'animation choisie
		explosion.play(anim_name)
	else:
		# s'il n'y a pas d'animations listées, on joue l'animation par défaut
		explosion.play()

	# On connecte la fin de l'animation pour supprimer la node proprement
	# AnimatedSprite2D émet "animation_finished"
	# Utilisation de Callable pour robustesse (Godot 4 style)
	if explosion.has_signal("animation_finished"):
		explosion.connect("animation_finished", Callable(explosion, "queue_free"))
	else:
		# fallback : détruit après 0.8s si pas de signal
		var t = create_tween()
		t.tween_interval(0.8).tween_callback(explosion.queue_free)

	# --- DÉGÂTS : on applique aux mobs proches ---
	var damage = amelioration_explosion_random.bonus_pour_lvl_actuel() if amelioration_explosion_random else 0

	var mobs = get_tree().get_nodes_in_group("mobs")
	for mob in mobs:
		if not is_instance_valid(mob):
			continue
		var dist = mob.global_position.distance_to(position)
		var explosion_radius: float = 200.0 # rayon de l'explosion en pixels (modifiable)

		if dist <= explosion_radius:
			# on applique les dégâts
			if mob.has_method("take_damage"):
				# call_deferred au cas où take_damage ferait un queue_free immédiat
				mob.call_deferred("take_damage", damage)
			# (optionnel) tu peux aussi appliquer un knockback ici si tu veux

	# (optionnel) jouer un petit effet sonore ici si tu as un AudioStreamPlayer2D

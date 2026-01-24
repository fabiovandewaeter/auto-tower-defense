extends Label

func _ready():
	DonnesJeu.update_vague.connect(_on_update_vague)
	text = "Wave: " +  str(DonnesJeu.vague_actuelle)

func _on_update_vague():
	text = "Wave: " + str(DonnesJeu.vague_actuelle) + " Degats: " + str(DonnesJeu.amelioration_pour(DonnesJeu.AMELIORATION.CAC).bonus_pour_lvl_actuel())

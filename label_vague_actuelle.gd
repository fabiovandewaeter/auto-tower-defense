extends Label

func _ready():
	DonnesJeu.update_vague.connect(_on_update_vague)
	text = "Wave: " +  str(DonnesJeu.vague_actuelle)

func _on_update_vague():
	text = "Wave: " + str(DonnesJeu.vague_actuelle)

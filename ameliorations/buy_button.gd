extends Button

func update_affichage(amelioration):
	text = "Buy (" + str(amelioration.cout_pour_lvl_actuel()) + " gold)"
	if DonnesJeu.peut_acheter(amelioration):
		disabled = false
	else:
		disabled = true

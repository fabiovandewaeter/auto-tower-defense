extends Button

func update_affichage(amelioration):
	text = amelioration.nom + " (" + str(amelioration.cout_pour_lvl_actuel()) + " golds)"
	if DonnesJeu.peut_acheter(amelioration):
		disabled = false
	else:
		disabled = true

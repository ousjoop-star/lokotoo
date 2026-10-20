# Scène principale : fait le lien entre la logique (LogiqueJeu)
# et l'affichage (VueCanari, textes, écran de victoire).
# L'interface est construite par code pour rester dans une seule scène simple.
extends Control

var logique := LogiqueJeu.new()

var vue_principale: VueCanari
var vues_joueurs: Array[VueCanari] = []
var label_tour: Label
var label_message: Label
var panneau_victoire: PanelContainer
var label_victoire: Label


func _ready() -> void:
	_construire_interface()
	_nouvelle_partie()


func _nouvelle_partie() -> void:
	logique.nouvelle_partie()
	panneau_victoire.visible = false
	label_message.text = "Appuie sur ton canari pour l'agiter !"
	_rafraichir()


# Appelé quand le joueur `joueur` appuie sur son canari.
func _sur_canari_appuye(joueur: int) -> void:
	var r := logique.agiter_canari(joueur)
	if not r["valide"]:
		if logique.gagnant == -1:
			label_message.text = "Ce n'est pas ton tour ! C'est au joueur %d." % (logique.joueur_actuel + 1)
		return

	vues_joueurs[joueur].agiter()
	vue_principale.agiter()

	var objet: ObjetCanari = r["objet"]
	var ref: ObjetCanari = r["reference"]
	var debut := "Réf. %s %d, joueur %d sort : %s.\n" % [LogiqueJeu.NOMS_COULEURS[ref.couleur], ref.numero, joueur + 1, objet.decrire()]
	match r["resultat"]:
		LogiqueJeu.Resultat.RETIRE:
			label_message.text = debut + "Même couleur que la référence : l'objet est retiré !"
		LogiqueJeu.Resultat.AJOUT:
			var forme := "billes" if objet.forme == ObjetCanari.Forme.BILLE else "cubes"
			label_message.text = debut + "Même numéro que la référence : +%d %s !" % [r["nb_ajoutes"], forme]
		_:
			label_message.text = debut + "Rien ne se passe, l'objet retourne dans le canari."

	_rafraichir()

	if r["gagnant"] != -1:
		label_victoire.text = "Le joueur %d a vidé son canari !\nVictoire !" % (r["gagnant"] + 1)
		panneau_victoire.visible = true


# Met à jour tous les affichages à partir de l'état de la logique.
func _rafraichir() -> void:
	var ref := logique.objet_reference
	vue_principale.afficher("Canari principal (réf. : %s %d)" % [LogiqueJeu.NOMS_COULEURS[ref.couleur], ref.numero],
			logique.reserve_principale, ref)
	for j in vues_joueurs.size():
		var actif := logique.gagnant == -1 and j == logique.joueur_actuel
		vues_joueurs[j].afficher("Joueur %d" % (j + 1), logique.canaris_joueurs[j], null, actif)
	if logique.gagnant == -1:
		label_tour.text = "Tour du joueur %d" % (logique.joueur_actuel + 1)
	else:
		label_tour.text = "Partie terminée"


# ---------------------------------------------------------------
# CONSTRUCTION DE L'INTERFACE
# ---------------------------------------------------------------

func _construire_interface() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var fond := ColorRect.new()
	fond.color = Color(0.09, 0.11, 0.14)
	fond.set_anchors_preset(Control.PRESET_FULL_RECT)
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fond)

	var marges := MarginContainer.new()
	marges.set_anchors_preset(Control.PRESET_FULL_RECT)
	for cote in ["left", "right", "top", "bottom"]:
		marges.add_theme_constant_override("margin_" + cote, 20)
	add_child(marges)

	var colonne := VBoxContainer.new()
	colonne.add_theme_constant_override("separation", 14)
	marges.add_child(colonne)

	var titre := _creer_label("Jeu des canaris", 44)
	colonne.add_child(titre)

	# Canari principal : un peu plus petit que ceux des joueurs.
	vue_principale = VueCanari.new()
	vue_principale.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vue_principale.size_flags_stretch_ratio = 0.6
	colonne.add_child(vue_principale)

	label_tour = _creer_label("", 34)
	label_tour.add_theme_color_override("font_color", VueCanari.COULEUR_ACTIF)
	colonne.add_child(label_tour)

	# Un canari par joueur (le nombre vient de LogiqueJeu.NB_JOUEURS).
	for j in LogiqueJeu.NB_JOUEURS:
		var vue := VueCanari.new()
		vue.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vue.appuye.connect(_sur_canari_appuye.bind(j))
		colonne.add_child(vue)
		vues_joueurs.append(vue)

	label_message = _creer_label("", 26)
	label_message.custom_minimum_size.y = 80
	label_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	colonne.add_child(label_message)

	_construire_ecran_victoire()


func _construire_ecran_victoire() -> void:
	panneau_victoire = PanelContainer.new()
	panneau_victoire.set_anchors_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.8)
	panneau_victoire.add_theme_stylebox_override("panel", style)
	add_child(panneau_victoire)

	var boite := VBoxContainer.new()
	boite.alignment = BoxContainer.ALIGNMENT_CENTER
	boite.add_theme_constant_override("separation", 40)
	panneau_victoire.add_child(boite)

	label_victoire = _creer_label("", 52)
	label_victoire.add_theme_color_override("font_color", VueCanari.COULEUR_ACTIF)
	boite.add_child(label_victoire)

	var bouton := Button.new()
	bouton.text = "Rejouer"
	bouton.add_theme_font_size_override("font_size", 44)
	bouton.custom_minimum_size = Vector2(360, 120)
	bouton.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bouton.pressed.connect(_nouvelle_partie)
	boite.add_child(bouton)

	panneau_victoire.visible = false


func _creer_label(texte: String, taille: int) -> Label:
	var label := Label.new()
	label.text = texte
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", taille)
	return label

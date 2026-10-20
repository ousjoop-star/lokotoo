# Affichage d'un canari (une cage) et de ses objets.
# Ce script ne connaît pas les règles : il dessine ce qu'on lui donne
# et signale quand le joueur appuie dessus.
class_name VueCanari
extends Control

# Émis quand on appuie (doigt ou souris) sur le canari.
signal appuye

const COULEUR_FOND := Color(0.16, 0.13, 0.10)
const COULEUR_BARREAUX := Color(0.75, 0.62, 0.35)
const COULEUR_ACTIF := Color(1.0, 0.85, 0.2)
const COULEUR_EVIDENCE := Color(1, 1, 1)

var titre := ""
var objets: Array = []
var objet_en_evidence: ObjetCanari = null  # objet entouré (ex. la référence)
var actif := false                         # true = c'est à ce canari de jouer

# Décalage horizontal utilisé pour l'animation « agiter » (en pixels).
var secousse := 0.0:
	set(valeur):
		secousse = valeur
		queue_redraw()


# Met à jour ce qui est affiché.
func afficher(p_titre: String, p_objets: Array, p_evidence: ObjetCanari = null, p_actif := false) -> void:
	titre = p_titre
	objets = p_objets
	objet_en_evidence = p_evidence
	actif = p_actif
	queue_redraw()


# Petite animation : le canari tremble de gauche à droite.
func agiter() -> void:
	var tween := create_tween()
	for i in 4:
		tween.tween_property(self, "secousse", 12.0, 0.04)
		tween.tween_property(self, "secousse", -12.0, 0.04)
	tween.tween_property(self, "secousse", 0.0, 0.04)


func _gui_input(event: InputEvent) -> void:
	# Sur Android, un toucher est converti en clic souris (réglage par défaut de Godot).
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		appuye.emit()
		accept_event()


func _draw() -> void:
	draw_set_transform(Vector2(secousse, 0))
	var police := get_theme_default_font()
	var taille_police := 26

	# Cage : fond + barreaux verticaux + cadre.
	var cadre := Rect2(Vector2.ZERO, size)
	draw_rect(cadre, COULEUR_FOND)
	var nb_barreaux := 12
	for i in range(1, nb_barreaux):
		var x := size.x * i / nb_barreaux
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(COULEUR_BARREAUX, 0.25), 2)
	draw_rect(cadre, COULEUR_ACTIF if actif else COULEUR_BARREAUX, false, 6 if actif else 3)

	# Titre en haut de la cage.
	var texte := "%s  (%d objets)" % [titre, objets.size()]
	draw_string(police, Vector2(14, 34), texte, HORIZONTAL_ALIGNMENT_LEFT, size.x - 28, taille_police,
			COULEUR_ACTIF if actif else Color.WHITE)

	# Zone où l'on range les objets, sous le titre.
	var zone := Rect2(Vector2(10, 46), size - Vector2(20, 56))
	if objets.is_empty() or zone.size.x <= 0 or zone.size.y <= 0:
		return

	# On cherche le nombre de colonnes qui donne les plus grandes cases possibles.
	var n := objets.size()
	var meilleure_case := 0.0
	var colonnes := 1
	for c in range(1, n + 1):
		var lignes := ceili(float(n) / c)
		var case_taille := minf(zone.size.x / c, zone.size.y / lignes)
		if case_taille > meilleure_case:
			meilleure_case = case_taille
			colonnes = c
	meilleure_case = minf(meilleure_case, 90.0)

	for i in n:
		var col := i % colonnes
		var ligne := i / colonnes
		var centre := zone.position + Vector2(col + 0.5, ligne + 0.5) * meilleure_case
		_dessiner_objet(objets[i], centre, meilleure_case * 0.42, police)


# Dessine une bille (cercle) ou un cube (carré) avec son numéro au centre.
func _dessiner_objet(objet: ObjetCanari, centre: Vector2, rayon: float, police: Font) -> void:
	var couleur: Color = LogiqueJeu.COULEURS[objet.couleur]
	if objet.forme == ObjetCanari.Forme.BILLE:
		draw_circle(centre, rayon, couleur)
	else:
		draw_rect(Rect2(centre - Vector2(rayon, rayon), Vector2(rayon, rayon) * 2), couleur)

	if objet == objet_en_evidence:
		var marge := rayon + 5
		if objet.forme == ObjetCanari.Forme.BILLE:
			draw_arc(centre, marge, 0, TAU, 32, COULEUR_EVIDENCE, 4)
		else:
			draw_rect(Rect2(centre - Vector2(marge, marge), Vector2(marge, marge) * 2), COULEUR_EVIDENCE, false, 4)

	var taille := int(maxf(rayon * 1.1, 10))
	var largeur := rayon * 2
	draw_string(police, centre + Vector2(-rayon, taille * 0.35), str(objet.numero),
			HORIZONTAL_ALIGNMENT_CENTER, largeur, taille, Color.WHITE)

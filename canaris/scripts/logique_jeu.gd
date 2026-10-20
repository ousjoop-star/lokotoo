# Toute la logique du jeu de canaris, SANS affichage.
# La scène principale (main.gd) appelle ces fonctions et affiche le résultat.
# Pour changer les règles, c'est ici qu'il faut regarder.
class_name LogiqueJeu
extends RefCounted

# ---------------------------------------------------------------
# PARAMÈTRES FACILES À MODIFIER
# ---------------------------------------------------------------

# Nombre de canaris joueurs (le canari principal n'est pas compté).
const NB_JOUEURS := 2

# Nombre de billes et de cubes de chaque joueur au départ (9 + 9 = 18 objets).
const NB_BILLES_DEPART := 9
const NB_CUBES_DEPART := 9

# Nombre d'objets dans la réserve du canari principal.
const TAILLE_RESERVE := 9

# Numéros possibles des objets.
const NUMERO_MIN := 1
const NUMERO_MAX := 9

# Couleurs utilisées dans la partie (couleur Godot + nom affiché).
# Plus il y a de couleurs, plus la partie est longue :
# avec 2 couleurs une partie dure environ 50 coups par joueur,
# avec 3 couleurs elle peut dépasser 100 coups par joueur.
const COULEURS: Array[Color] = [
	Color(0.90, 0.25, 0.25),  # rouge
	Color(0.25, 0.50, 0.95),  # bleu
]
const NOMS_COULEURS: Array[String] = ["rouge", "bleu"]
# Exemple pour ajouter une 3e couleur :
#   ajouter Color(0.95, 0.80, 0.20) dans COULEURS et "jaune" dans NOMS_COULEURS.

# Résultats possibles quand un joueur agite son canari.
enum Resultat { RETIRE, AJOUT, RIEN }

# ---------------------------------------------------------------
# ÉTAT DE LA PARTIE
# ---------------------------------------------------------------

# Réserve du canari principal (tableau d'ObjetCanari).
var reserve_principale: Array[ObjetCanari] = []

# Objet de la réserve actuellement « en vitrine » : il donne
# la couleur de référence et le numéro de référence du tour.
var objet_reference: ObjetCanari

# Un tableau d'objets par joueur : canaris_joueurs[0] = joueur 1, etc.
var canaris_joueurs: Array = []

# Index du joueur dont c'est le tour (0 = joueur 1).
var joueur_actuel := 0

# Index du gagnant, ou -1 tant que la partie n'est pas finie.
var gagnant := -1


# Prépare une nouvelle partie : nouveaux canaris et nouvelle réserve.
func nouvelle_partie() -> void:
	randomize()
	joueur_actuel = 0
	gagnant = -1

	reserve_principale.clear()
	for i in TAILLE_RESERVE:
		reserve_principale.append(_objet_aleatoire(_forme_aleatoire()))

	canaris_joueurs.clear()
	for j in NB_JOUEURS:
		var canari: Array[ObjetCanari] = []
		for i in NB_BILLES_DEPART:
			canari.append(_objet_aleatoire(ObjetCanari.Forme.BILLE))
		for i in NB_CUBES_DEPART:
			canari.append(_objet_aleatoire(ObjetCanari.Forme.CUBE))
		canaris_joueurs.append(canari)

	_tirer_reference()


# Le joueur `joueur` agite son canari.
# Renvoie un dictionnaire décrivant ce qui s'est passé :
#   { "valide": bool, "objet": ObjetCanari, "resultat": Resultat,
#     "nb_ajoutes": int, "reference": ObjetCanari, "gagnant": int }
# "valide" vaut false si ce n'est pas le tour de ce joueur ou si la partie est finie.
func agiter_canari(joueur: int) -> Dictionary:
	if gagnant != -1 or joueur != joueur_actuel:
		return { "valide": false }

	var canari: Array = canaris_joueurs[joueur]
	var reference := objet_reference

	# Un objet aléatoire sort du canari.
	var index := randi() % canari.size()
	var objet: ObjetCanari = canari[index]

	var resultat := Resultat.RIEN
	var nb_ajoutes := 0

	if objet.couleur == reference.couleur:
		# Même couleur que la référence : l'objet est retiré.
		canari.remove_at(index)
		resultat = Resultat.RETIRE
	elif objet.numero == reference.numero:
		# Même numéro : on ajoute autant d'objets de la même forme que ce numéro.
		nb_ajoutes = objet.numero
		for i in nb_ajoutes:
			canari.append(_objet_aleatoire(objet.forme))
		resultat = Resultat.AJOUT
	# Sinon : rien ne se passe, l'objet reste dans le canari.

	if canari.is_empty():
		gagnant = joueur
	else:
		# Au tour du joueur suivant, avec une nouvelle référence.
		joueur_actuel = (joueur_actuel + 1) % NB_JOUEURS
		_tirer_reference()

	return {
		"valide": true,
		"objet": objet,
		"resultat": resultat,
		"nb_ajoutes": nb_ajoutes,
		"reference": reference,
		"gagnant": gagnant,
	}


# Le canari principal est agité : un objet de sa réserve passe en vitrine
# et devient la référence (couleur + numéro) pour le tour suivant.
func _tirer_reference() -> void:
	objet_reference = reserve_principale[randi() % reserve_principale.size()]


func _forme_aleatoire() -> ObjetCanari.Forme:
	return ObjetCanari.Forme.BILLE if randi() % 2 == 0 else ObjetCanari.Forme.CUBE


func _objet_aleatoire(forme: ObjetCanari.Forme) -> ObjetCanari:
	var couleur := randi() % COULEURS.size()
	var numero := randi_range(NUMERO_MIN, NUMERO_MAX)
	return ObjetCanari.new(forme, couleur, numero)

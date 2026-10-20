# Un objet contenu dans un canari : une bille ou un cube,
# avec une couleur et un numéro de 1 à 9.
# Cette classe ne contient AUCUN code d'affichage.
class_name ObjetCanari
extends RefCounted

enum Forme { BILLE, CUBE }

var forme: Forme
var couleur: int   # index dans LogiqueJeu.COULEURS
var numero: int    # de 1 à 9


func _init(p_forme: Forme, p_couleur: int, p_numero: int) -> void:
	forme = p_forme
	couleur = p_couleur
	numero = p_numero


# Texte lisible, pratique pour les messages et le débogage.
func decrire() -> String:
	var nom_forme := "bille" if forme == Forme.BILLE else "cube"
	return "%s %s n°%d" % [nom_forme, LogiqueJeu.NOMS_COULEURS[couleur], numero]

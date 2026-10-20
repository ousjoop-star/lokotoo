# Canaris, prototype Godot 4

Prototype 2D du jeu des canaris, en GDScript, une seule scène, jouable sur Android.

## Lancer le jeu dans l'éditeur

1. Installer **Godot 4.3** (ou plus récent), version standard (pas .NET) : https://godotengine.org/download
2. Ouvrir Godot, cliquer sur **Importer**, choisir le fichier `canaris/project.godot`.
3. Appuyer sur **F5** (ou le bouton ▶ en haut à droite). La fenêtre s'ouvre au format téléphone.
4. Cliquer (ou toucher) le canari entouré en jaune pour l'agiter.

## Règles implémentées

- Chaque joueur commence avec 9 billes et 9 cubes (couleur et numéro de 1 à 9 au hasard).
- Le canari principal a une réserve de 9 objets. À chaque tour, il est agité et un objet de
  sa réserve passe en vitrine (entouré de blanc) : c'est la **référence** (couleur + numéro).
- Le joueur agite son canari, un objet aléatoire sort :
  - même **couleur** que la référence → l'objet est retiré ;
  - sinon, même **numéro** que la référence → on ajoute N objets de la même forme (N = ce numéro) ;
  - sinon → rien, l'objet retourne dans le canari.
- Le premier canari vide gagne. Un bouton « Rejouer » relance une partie.

## Organisation du code

| Fichier | Rôle |
|---|---|
| `scripts/logique_jeu.gd` | Règles et état de la partie, **sans affichage**. Les paramètres (nombre de joueurs, couleurs, taille de la réserve…) sont en haut du fichier. |
| `scripts/objet_canari.gd` | Un objet : forme, couleur, numéro. |
| `scripts/vue_canari.gd` | Dessin d'un canari et de ses objets, détection de l'appui. |
| `scripts/main.gd` | Relie la logique à l'affichage et construit l'interface. |
| `scenes/main.tscn` | La scène unique. |

## Exporter en .aab pour Google Play

1. Dans Godot : **Éditeur > Gérer les modèles d'exportation**, télécharger les modèles.
2. **Éditeur > Paramètres de l'éditeur > Export > Android** : renseigner le chemin du SDK Android
   (et du JDK 17).
3. **Projet > Installer le modèle de compilation Android** (crée le dossier `android/`,
   nécessaire pour le format .aab).
4. Créer une clé de signature (keystore) et la renseigner dans **Projet > Exporter > Android >
   Keystore > Release**. Changer aussi `package/unique_name` (`com.exemple.canaris` par défaut).
5. **Projet > Exporter > Android > Exporter le projet**, décocher « Exporter en mode debug ».
   Le fichier `build/canaris.aab` est prêt à être envoyé sur Google Play.

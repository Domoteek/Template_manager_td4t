# Template Manager TD-4T (GESTMAG)

Ce projet est une solution complète pour la gestion et l'impression d'étiquettes autonomes sur les imprimantes **Brother TD-4T**, intégré à l'écosystème **GESTMAG**.

Il se compose de deux parties principales :
1.  **L'interface de gestion (Template Manager)** : Une application web locale pour créer, éditer et organiser les modèles d'étiquettes.
2.  **Le programme embarqué (`Prog_Gestmag.BAS`)** : Un script BASIC (FBPL) qui s'exécute directement sur l'imprimante pour permettre son fonctionnement autonome (Scan & Print).

## 🚀 Fonctionnalités

### Interface Web (Template Manager)
*   **Gestion visuelle** : Importation, recadrage et prévisualisation des modèles d'étiquettes (`.bmp`).
*   **Conversion automatique** : Transformation des images en format 1-bit BMP monochrome requis par l'imprimante.
*   **Organisation** : Classement par catégories (Promo, Boucherie, Pizza, etc.) et codification automatique.
*   **Préparation USB** : Fonctionnalité "Smart Copy" pour exporter uniquement les fichiers modifiés vers une clé USB pour la mise à jour des imprimantes.
*   **Documentation** : Génération et consultation du manuel d'utilisation directement depuis l'interface.

### Programme Imprimante (Standalone)
*   **Fonctionnement autonome** : Pas de PC requis lors de l'utilisation.
*   **Scan & Print** : Lecture de codes-barres (EAN13, EAN8, Code128) et impression immédiate de l'étiquette associée.
*   **Multi-formats** : Support de différents formats d'étiquettes (Ronde 46x46, Ovale 39x46, Petite 40x27) avec calibration facile.
*   **Clavier virtuel** : Utilisation d'un clavier numérique USB connecté à l'imprimante pour les saisies manuelles (quantité, prix).

## 🛠️ Installation et Utilisation

### Pré-requis
*   Node.js installé sur le poste de gestion.
*   Imprimante Brother TD-4T (série TD-4420TN, TD-4520TN, etc.).

### Lancement du Gestionnaire
1.  Ouvrir un terminal dans le dossier du projet.
2.  Lancer le serveur :
    ```bash
    node server.js
    ```
3.  L'application s'ouvre automatiquement dans le navigateur (généralement `http://localhost:3000`).

### Mise à jour d'une Imprimante
1.  Dans le Template Manager, cliquez sur **"Préparer Clé USB"**.
2.  Sélectionnez le lecteur correspondant à votre clé USB.
3.  Insérez la clé USB dans le port USB Host de l'imprimante (imprimante éteinte ou allumée selon la procédure).
4.  Le programme `AUTO.BAS` se lancera pour mettre à jour les fichiers internes de l'imprimante.

### Procédure de Calage (Imprimante)
1.  Allumer l'imprimante.
2.  Appuyer sur la touche **²** du clavier connecté.
3.  Sélectionner le format (1, 2 ou 3).
4.  L'imprimante se calibre. Redémarrer l'imprimante pour valider.

## 📂 Structure du Projet

*   `server.js` : Backend Node.js (API, gestion fichiers, serveur web).
*   `template_manager.html` : Interface principale (Frontend).
*   `template_manager.js` : Logique client (manipulation d'images, interaction API).
*   `Prog_Gestmag.BAS` : Code source BASIC du programme embarqué dans l'imprimante.
*   `manuel_brother_td4t.html` : Manuel utilisateur HTML.
*   `AUTO.BAS` : Script d'exécution automatique pour la mise à jour via USB.

## 👤 Auteur

Développé par **Clément CAHAGNE** pour GESTMAG.

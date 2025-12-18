# Procédure d'Installation - Template Manager TD4T

Ce document décrit les étapes nécessaires pour installer l'environnement complet permettant d'exécuter le **Template Manager TD4T**.

## 1. Installation de Node.js (Serveur d'application)

Le "Template Manager" fonctionne grâce à Node.js.

1.  Rendez-vous sur le site officiel : [https://nodejs.org/fr](https://nodejs.org/fr)
2.  Téléchargez la version recommandée **LTS** (Long Term Support).
3.  Lancez l'installateur (`.msi`).
4.  Suivez les instructions à l'écran en cliquant sur "Next" (Suivant) à chaque étape. Les options par défaut conviennent parfaitement.
5.  À la fin, cliquez sur "Finish".

*Vérification :*
Ouvrez une invite de commande (tapez `cmd` dans le menu Démarrer) et saisissez :
```cmd
node -v
```
Si un numéro de version s'affiche (ex: `v20.10.0`), Node.js est bien installé.

## 2. Installation de Git (Gestionnaire de versions)

Git est nécessaire pour récupérer ("cloner") le code source du logiciel.

1.  Rendez-vous sur : [https://git-scm.com/download/win](https://git-scm.com/download/win)
2.  Le téléchargement devrait démarrer automatiquement (sinon cliquez sur "Click here to download").
3.  Lancez l'installateur (`.exe`).
4.  Suivez les étapes. Git propose beaucoup d'options, vous pouvez **laisser toutes les options par défaut** et cliquer successivement sur "Next" jusqu'à l'installation.
5.  Cliquez sur "Install" puis "Finish".

*Vérification :*
Ouvrez une invite de commande et saisissez :
```cmd
git --version
```

## 3. Récupération du logiciel (Clone du Repository)

Une fois les outils installés, vous pouvez récupérer la dernière version du logiciel.

1.  Créez un dossier où vous souhaitez installer le logiciel (par exemple sur le Bureau ou dans `C:\Logiciels`).
2.  Dans ce dossier, faites un **clic droit** dans le vide et choisissez **"Open Git Bash here"** (ou ouvrez un terminal et naviguez jusqu'à ce dossier).
3.  Copiez et collez la commande suivante pour télécharger le logiciel :

```bash
git clone https://github.com/Domoteek/Template_manager_td4t.git
```

4.  Appuyez sur **Entrée**. Git va télécharger tous les fichiers.
5.  Un dossier nommé `Template_manager_td4t` a été créé.

## 4. Lancement de l'application

1.  Entrez dans le dossier du projet :
    ```bash
    cd Template_manager_td4t
    ```
    *(Ou ouvrez simplement le dossier via l'explorateur Windows, puis faites clic droit > "Open in Terminal" ou tapez `cmd` dans la barre d'adresse).*

2.  Lancez le serveur avec la commande :
    ```bash
    node server.js
    ```

3.  Si le pare-feu Windows demande une autorisation, cliquez sur **"Autoriser l'accès"**.
4.  Ouvrez votre navigateur web et allez à l'adresse : [http://localhost:3000](http://localhost:3000)

---
*Note : Pour les mises à jour futures, il suffira de faire un `git pull` dans le dossier.*

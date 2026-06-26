MONY - Ajout du système de monétisation Premium
===============================================

Contexte
--------

Je travaille sur une application Flutter appelée **Mony**.

Mony est une application de gestion financière personnelle qui permet déjà :

*   le suivi des revenus ;
    
*   le suivi des dépenses ;
    
*   la gestion des catégories ;
    
*   les budgets ;
    
*   la génération d'un profil financier ;
    
*   l'utilisation de Google Gemini pour certaines fonctionnalités IA.
    

Le projet contient également un backend Node.js/Express/MongoDB dans un dossier nommé **MonyApi**.

Ce dossier est une copie locale du backend principal.

Tu peux modifier ce dossier si nécessaire afin d'ajouter les nouvelles fonctionnalités. Les modifications seront ensuite répercutées sur le backend principal.

IMPORTANT
=========

Avant toute implémentation :

1.  Analyse le code Flutter existant.
    
2.  Analyse le dossier MonyApi.
    
3.  Réutilise l'architecture actuelle.
    
4.  Ne recrée pas des modèles ou routes déjà existants.
    
5.  Modifie uniquement ce qui est nécessaire.
    
6.  Respecte les conventions déjà présentes dans le projet.
    
7.  Préserve la compatibilité avec les fonctionnalités existantes.
    

Objectif
========

Ajouter un système de monétisation complet autour de Mony.

Le positionnement du produit est :

> Mony est un coach financier personnel intelligent.

La monétisation doit apporter une vraie valeur utilisateur.

Feature 1 : Mony Premium
========================

Description
-----------

Créer une offre Premium donnant accès à des fonctionnalités avancées.

### Version gratuite

*   suivi des revenus ;
    
*   suivi des dépenses ;
    
*   budgets ;
    
*   profil financier ;
    
*   statistiques de base.
    

### Version Premium

*   analyses financières avancées ;
    
*   profil financier évolutif ;
    
*   historique du profil ;
    
*   recommandations personnalisées ;
    
*   coaching IA avancé ;
    
*   simulations financières ;
    
*   contenus premium.
    

Feature 2 : Financial Coaching AI
=================================

Description
-----------

Créer un module Premium nommé :

### Financial Coaching AI

`   google_generative_ai: ^0.4.7   `

L'IA doit analyser :

*   revenus ;
    
*   dépenses ;
    
*   budgets ;
    
*   profil financier ;
    
*   historique financier.
    

Puis produire :

*   conseils personnalisés ;
    
*   recommandations ;
    
*   alertes comportementales ;
    
*   bilans hebdomadaires ;
    
*   bilans mensuels ;
    
*   pistes d'amélioration.
    

Exemples :

*   augmentation inhabituelle des dépenses ;
    
*   comportement impulsif détecté ;
    
*   risque de non atteinte d'un objectif d'épargne.
    

Les réponses doivent être simples, utiles et pédagogiques.

Feature 3 : Pro Insights
========================

Description
-----------

Créer un espace Premium de projection financière.

### Simulations

Permettre de simuler :

*   l'épargne future ;
    
*   les revenus futurs ;
    
*   les dépenses futures ;
    
*   l'évolution du patrimoine.
    

### Scénarios

Créer :

*   scénario optimiste ;
    
*   scénario réaliste ;
    
*   scénario prudent.
    

### Prévisions

Afficher :

*   1 mois ;
    
*   3 mois ;
    
*   6 mois ;
    
*   12 mois.
    

Les résultats doivent être présentés avec des graphiques et indicateurs visuels.

Feature 4 : Académie Mony
=========================

Description
-----------

Créer une bibliothèque de contenus premium.

### Ebooks

Exemples :

*   Comprendre ses finances personnelles ;
    
*   Construire une épargne durable ;
    
*   Réussir son budget étudiant.
    

### Mini-cours

Exemples :

*   Sortir du cycle dépensier ;
    
*   Apprendre à économiser avec un petit revenu ;
    
*   Construire une discipline financière.
    

### Templates

Exemples :

*   Budget mensuel ;
    
*   Budget étudiant ;
    
*   Budget freelance ;
    
*   Plan d'épargne ;
    
*   Objectifs financiers.
    

Architecture Flutter
====================

Respecter strictement l'architecture existante :

`   data/  domain/  presentation/   `

Créer les nouvelles couches nécessaires :

*   entities ;
    
*   repositories ;
    
*   use cases ;
    
*   services ;
    
*   datasources ;
    
*   screens ;
    
*   widgets ;
    
*   state management.
    

Backend
=======

Avant de créer de nouveaux endpoints :

1.  Vérifier les routes existantes.
    
2.  Vérifier les modèles existants.
    
3.  Vérifier les services existants.
    

Créer uniquement ce qui manque.

Les fonctionnalités suivantes peuvent nécessiter des évolutions backend :

*   abonnement Premium ;
    
*   quotas IA ;
    
*   stockage des analyses IA ;
    
*   simulations financières ;
    
*   contenus premium ;
    
*   historique du profil financier.
    

Si une fonctionnalité existe déjà dans MonyApi, la réutiliser.

UX
==

Créer une expérience moderne inspirée des applications fintech.

Écrans attendus :

*   PremiumScreen ;
    
*   CoachAIScreen ;
    
*   MonthlyReportScreen ;
    
*   SimulationScreen ;
    
*   ScenariosScreen ;
    
*   AcademyScreen ;
    
*   ProductDetailsScreen.
    

L'expérience doit être cohérente avec le design actuel de Mony.

Résultat attendu
================

Implémenter complètement les fonctionnalités.

À la fin :

*   lister les fichiers créés ;
    
*   lister les fichiers modifiés ;
    
*   expliquer les modifications Flutter ;
    
*   expliquer les modifications MonyApi ;
    
*   signaler les migrations ou données à ajouter.
    

\# Analyse obligatoire avant développement

Avant de commencer l'implémentation :

1\. Analyser entièrement le dossier MonyApi.

2\. Analyser le Swagger existant.

3\. Identifier les endpoints déjà disponibles.

4\. Identifier les modèles déjà existants.

5\. Réutiliser au maximum les services existants.

6\. Éviter toute duplication de logique métier.

7\. Ne créer de nouveaux endpoints que si aucune route existante ne permet de répondre au besoin.

8\. Fournir un rapport avant implémentation indiquant :

\- les fichiers Flutter à créer ;

\- les fichiers Flutter à modifier ;

\- les fichiers backend à créer ;

\- les fichiers backend à modifier ;

\- les nouvelles routes API nécessaires ;

\- les modèles impactés.

L'objectif est de conserver l'architecture actuelle du projet tout en ajoutant les fonctionnalités Premium, Financial Coaching AI, Pro Insights et Académie Mony de la manière la plus propre possible.
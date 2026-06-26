# Analyse Technique et Fonctionnelle du Projet Mony

## 1. Introduction
Mony est une application mobile de gestion financière personnelle développée avec Flutter. Son objectif est d'aider les utilisateurs à suivre leurs revenus, dépenses, et budgets, tout en fournissant des conseils intelligents via une intégration avec l'IA (Google Gemini).

## 2. Analyse Fonctionnelle (État Actuel)

### Fonctionnalités de base :
- **Gestion des Transactions** : Ajout, modification et suppression de revenus et dépenses.
- **Catégories** : Organisation des transactions par catégories personnalisables.
- **Budgets** : Définition de limites de dépenses par catégorie.
- **Profil Financier** : Questionnaire permettant de définir le profil de risque et les habitudes de l'utilisateur.
- **Tableau de Bord** : Vue d'ensemble des soldes, revenus et dépenses avec visualisations graphiques (fl_chart).
- **Assistant IA** : Chatbot basé sur Gemini 1.5 Flash pour répondre aux questions financières et analyser les données de l'utilisateur.

### Fonctionnalités en cours / à finaliser :
- **Insights & Simulations** : Prévisions financières basées sur les données historiques.
- **Synchronisation API** : Synchronisation des données locales vers un backend Node.js.

## 3. Analyse Technique

### Stack Technologique :
- **Framework** : Flutter (SDK ^3.10.1)
- **Langage** : Dart
- **Gestion d'État** : Riverpod (flutter_riverpod, riverpod_annotation)
- **Persistance Locale** : Hive (NoSQL rapide)
- **Base de données Cloud / API** : Dio pour les requêtes HTTP
- **IA** : Google Generative AI (Gemini 1.5 Flash)
- **Internationalisation** : flutter_localizations (ARB files), support FR et EN.

### Architecture :
Le projet utilise une architecture **Feature-First Modular Architecture** avec une séparation claire en couches inspirée de la Clean Architecture :
- `data/` : Modèles, sources de données (Hive, API), implémentations de dépôts.
- `domain/` : Entités, interfaces de dépôts, cas d'utilisation (use cases).
- `presentation/` : Providers (Riverpod), écrans (Screens), widgets.

Cette structure est robuste, facilite les tests unitaires et permet une scalabilité horizontale (ajout de nouvelles fonctionnalités sans impacter les anciennes).

### Gestion d'État (Riverpod) :
L'utilisation de Riverpod est moderne et efficace. Les providers sont bien segmentés par fonctionnalité (ex: `transaction_providers.dart`, `ai_assistant_provider.dart`). L'utilisation de `StateNotifier` et `AsyncValue` permet de gérer proprement les états de chargement, d'erreur et de données.

### Persistance (Hive) :
Hive est utilisé pour la réactivité et la performance. Les adaptateurs sont correctement enregistrés dans le `main.dart`. La logique de synchronisation dans `SyncService` montre une volonté de rendre l'application fonctionnelle en mode hors-ligne.

## 4. Évaluation de la Structure

### Points Forts :
- **Modularité** : Chaque fonctionnalité est isolée, ce qui facilite la maintenance.
- **Typage** : Utilisation stricte des modèles et entités pour éviter les erreurs de runtime.
- **UI/UX** : Utilisation de thèmes cohérents, de Google Fonts (Poppins) et d'animations (Lottie).
- **Extensibilité** : La structure est prête pour accueillir les fonctionnalités "Premium".

### Points d'Attention :
- **Complexité du Main** : Le fichier `main.dart` commence à devenir volumineux avec tous les enregistrements d'adaptateurs Hive. Une centralisation de l'initialisation de Hive pourrait être bénéfique.
- **Couverture de Tests** : Bien qu'un dossier `test/` existe, la couverture semble pouvoir être renforcée avant le passage au Premium.
- **Gestion des Secrets** : L'API Key Gemini est gérée via `.env`, ce qui est une bonne pratique, mais il faudra veiller à la sécurité en production.

## 5. Recommandations pour le Passage au mode Premium

Pour transformer Mony en "coach financier intelligent", voici les chantiers prioritaires identifiés :

1.  **Refactorisation de l'Assistant IA** : Déplacer la logique de prompt "système" vers un service dédié pour permettre des analyses plus profondes (historique long terme).
2.  **Modèle de Données Premium** : Étendre `UserModel` pour inclure les statuts d'abonnement et les limites de quotas (déjà commencé).
3.  **Module Coaching** : Créer un nouveau module `coaching` qui utilise les données de `financial_profile` pour générer des alertes comportementales proactives.
4.  **Visualisations Avancées** : Intégrer des graphiques de simulation (Pro Insights) dans le module `insights`.
5.  **Académie** : Implémenter le module `academy` pour la gestion des contenus éducatifs (Ebooks, cours).

## 6. Conclusion
Le projet Mony repose sur des bases techniques solides et modernes. L'architecture actuelle est parfaitement adaptée pour supporter l'évolution vers une offre Premium. La transition vers un coach intelligent est une étape naturelle étant donné l'intégration déjà existante de Gemini.

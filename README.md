# Conception-Base-de-Données-avec-PostgreSQL - Global Maritime Logistics (GML)

## Présentation du Projet

Ce projet consiste à concevoir et implémenter une **base de données relationnelle PostgreSQL** destinée à centraliser l’ensemble des opérations logistiques de **Global Maritime Logistics (GML)**, une entreprise internationale spécialisée dans le **transport maritime de marchandises conteneurisées**.

La base est pensée comme un **socle Data fiable**, normalisé et extensible, capable de supporter aussi bien les opérations métier que des **analyses de données futures** (reporting, BI, analytics).
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Contexte Métier

GML gère :

* une **flotte de navires** opérant sur plusieurs zones géographiques
* un **réseau mondial de ports partenaires**
* un **parc de conteneurs** (standards et spécialisés)
* des **routes maritimes** régulières
* des **expéditions** composées de plusieurs segments
* des **événements logistiques** (retards, incidents, météo…)

### Problématique

Le système existant est fragmenté, ce qui limite :

* la visibilité globale des flux
* la traçabilité des opérations
* la capacité d’analyse et d’aide à la décision

## Objectifs du Projet

* Concevoir une **base PostgreSQL unifiée**
* Garantir :
  * l’intégrité référentielle
  * la cohérence métier
  * la traçabilité des changements
* Respecter strictement la **normalisation (1FN → 3FN)**
* Implémenter les **contraintes métier** via :
  * contraintes `CHECK`
  * triggers en **PL/pgSQL**
* Préparer la base pour des **analyses de données futures**

## Modélisation des Données

La conception repose sur trois niveaux de modélisation.


| Modèle       | Description                                              |
| ------------- | -------------------------------------------------------- |
| **MCD**       | Entités métier et relations conceptuelles              |
| **MLD / MRD** | Schéma relationnel avec clés primaires et étrangères |
| **MPD**       | Implémentation physique PostgreSQL                      |

### Entités principales

* PORT
* NAVIRE
* ROUTE
* ESCALE
* EXPEDITION
* SEGMENT\_EXPEDITION
* CONTENEUR
* MARCHANDISE
* EVENEMENT\_LOGISTIQUE
* HISTORIQUE\_STATUT\_CONTENEUR

### Choix de conception

* Utilisation de **types ENUM** pour standardiser les statuts métier
* Séparation entre :
  * **Expédition** (vision globale)
  * **Segment d’expédition** (vision opérationnelle)
* Gestion des relations N–N via des **tables associatives**
* Historisation des statuts pour garantir la traçabilité

## Implémentation PostgreSQL

### 1️⃣ Création du schéma

📄 `schema_creation.sql`

* Création des tables
* Définition des :
  * `PRIMARY KEY`
  * `FOREIGN KEY`
  * contraintes `UNIQUE`
  * contraintes `CHECK`
* Respect strict des formes normales

---

### 2️⃣ Contraintes Métier et Triggers

Les règles métier complexes sont implémentées via **triggers PL/pgSQL**.

#### Contraintes temporelles

* `date_arrivee_prevue ≥ date_depart`
* `date_arrivee_reelle ≥ date_depart`

#### Audit et intégrité

* Interdiction de **modifier ou supprimer** un événement logistique
* Garantie de la **traçabilité des incidents**

#### Historisation automatique

Chaque changement de statut d’un conteneur génère automatiquement :

* l’ancien statut
* le nouveau statut
* la date du changement
* l’utilisateur PostgreSQL

## 🔐 Historisation & Audit

Le système met en place une **historisation automatique des statuts des conteneurs** via une table dédiée.

Cette approche permet :

* un audit complet des changements
* une analyse temporelle des flux logistiques
* une meilleure traçabilité opérationnelle

## ⚙️ Performance & Indexation

Bien que non exhaustive à ce stade, la stratégie de performance prévoit :

* index sur les clés étrangères
* index sur les colonnes de statut
* index sur les colonnes de dates

Ces optimisations faciliteront :

* les jointures
* les analyses
* l’intégration avec des outils BI

## 📊 Perspectives d’Analyse de Données

La base de données permet :

* l’analyse des délais de livraison
* le suivi des incidents logistiques
* l’évaluation des performances des routes et navires
* l’analyse des statuts et mouvements des conteneurs

Elle constitue une base solide pour :

* dashboards BI
* analyses KPI
* projets Data Analytics

## ✅ Conclusion

Ce projet fournit une **base de données robuste, normalisée et orientée Data**, répondant aux besoins opérationnels de GML tout en préparant l’entreprise à des usages analytiques futurs.

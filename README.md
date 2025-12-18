# Global Maritime Logistics (GML) – Base de données PostgreSQL

## 📌 Contexte du projet

Global Maritime Logistics (GML) est une entreprise internationale spécialisée dans le transport maritime de marchandises conteneurisées. L’entreprise gère :

* Une flotte de navires opérant sur plusieurs zones géographiques
* Un réseau global de ports partenaires
* Un parc de conteneurs standards et spécialisés
* Des routes maritimes régulières et des voyages ponctuels
* Un système interne de suivi des opérations logistiques et des incidents

Le système existant étant fragmenté et limitant la visibilité globale, ce projet vise à concevoir une **base de données PostgreSQL unifiée**, robuste et évolutive.

---

## 🎯 Objectifs du projet

* Centraliser toutes les entités logistiques dans une base PostgreSQL unique
* Garantir l’intégrité, la cohérence et la traçabilité des données
* Respecter strictement la normalisation (1FN → 3FN)
* Assurer la performance via une stratégie d’indexation adaptée
* Implémenter les règles métier et temporelles via **CHECK** et **TRIGGERS**
* Permettre l’historisation des événements et des statuts
* Faciliter les **analyses de données futures** (Data Analytics / BI)
* Préparer la base à des extensions et intégrations futures

---

## 🧱 Modélisation des données

Le travail de conception couvre l’ensemble du cycle de modélisation :

* **MCD (Modèle Conceptuel de Données)** : identification des entités métier et de leurs relations
* **MRD (Modèle Relationnel de Données)** : traduction relationnelle avec clés primaires et étrangères
* **MLD (Modèle Logique de Données)** : implémentation PostgreSQL normalisée

### Entités principales

* `port`
* `navire`
* `route`
* `escale`
* `conteneur`
* `marchandise`
* `expedition`
* `segment_expedition`
* `evenement`
* `historique_statut_conteneur`

Toutes les entités respectent les formes normales **N1 à N3**.

---


### Modélisation dans DBSchema

<img width="1099" height="830" alt="image" src="https://github.com/user-attachments/assets/b6240d78-604f-40c1-9a50-6fd1aec38898" />

## 🗂️ Structure du projet

```
.
├── create_databases.sql   # Création du schéma et des tables
├── triggers.sql           # Contraintes métier, CHECK et triggers
└── README.md              # Documentation du projet
```

---

## 🛠️ Implémentation PostgreSQL

### 1️⃣ create_databases.sql

Ce fichier contient :

* Création du schéma `schema_mcd`
* Création de toutes les tables métier
* Définition des clés primaires et étrangères
* Table d’association `expedition_conteneur`
* Index pour l’optimisation des jointures (`idx_expedition_conteneur`)

Les relations assurent la cohérence entre :

* Expéditions ↔ Routes ↔ Ports
* Expéditions ↔ Conteneurs
* Segments ↔ Navires
* Événements ↔ Contexte métier unique

---

### 2️⃣ triggers.sql

Ce fichier implémente les **règles métier et contraintes avancées**.

#### ✔️ Contraintes CHECK

* Valeurs autorisées pour les statuts (navire, conteneur, expédition, route)
* Typage contrôlé (type de navire, type de conteneur, catégorie de port)
* Cohérence des statuts dans l’historique des conteneurs
* Un événement concerne **une seule entité métier à la fois**
* Contrainte temporelle :

  * `date_arrivee_prevue ≥ date_depart`
  * `date_arrivee_reelle ≥ date_depart`

#### 🔒 Triggers métier

* **Événements append-only** :

  * Interdiction de mise à jour
  * Interdiction de suppression
* Auto-remplissage de la date d’événement si absente
* Ordre strict et continu des escales pour une route donnée

Ces triggers garantissent la traçabilité et la fiabilité des données opérationnelles.

---

## ⚡ Performance & Indexation

* Index composite sur `expedition_conteneur (id_expedition_fk, iso_conteneur_fk)`
* Clés étrangères indexables pour accélérer les jointures
* Modèle optimisé pour requêtes analytiques futures (BI, reporting, IA)

---

## 🔐 Intégrité et sécurité des données

* Intégrité référentielle assurée par PK / FK
* Contraintes métier implémentées au niveau base
* Historisation obligatoire des événements et des changements de statut
* Aucune suppression autorisée sur les données critiques (événements)


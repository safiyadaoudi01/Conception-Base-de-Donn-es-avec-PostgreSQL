-- contraintes
-- choix des attributs
ALTER TABLE schema_mcd.port
ADD CONSTRAINT chk_port_categorie CHECK (categorie IN ('commercial', 'industriel', 'militaire')),
ADD CONSTRAINT chk_port_statut CHECK (statut IN ('actif', 'inactif'));

ALTER TABLE schema_mcd.navire
ADD CONSTRAINT chk_navire_type CHECK (type_navire IN ('conteneur', 'reefer', 'special', 'autre')),
ADD CONSTRAINT chk_navire_etat CHECK (etat IN ('en_mer', 'au_port', 'maintenance', 'hors_service'));

ALTER TABLE schema_mcd.route
ADD CONSTRAINT chk_route_statut CHECK (statut IN ('active', 'inactive'));

ALTER TABLE schema_mcd.conteneur
ADD CONSTRAINT chk_conteneur_type CHECK (type_conteneur IN ('20ft', '40ft', 'reefer', 'special')),
ADD CONSTRAINT chk_conteneur_statut CHECK (statut IN ('vide', 'charge', 'port', 'navire', 'inspection', 'transit'));

ALTER TABLE schema_mcd.expedition
ADD CONSTRAINT chk_expedition_status CHECK (status IN ('cree', 'chargee', 'en_transit', 'livree', 'annulee'));

ALTER TABLE schema_mcd.evenement
ADD CONSTRAINT chk_evenement_type CHECK (type_event IN ('retard', 'meteo', 'inspection', 'panne', 'autre')),
ADD CONSTRAINT chk_evenement_gravite CHECK (gravite IN ('mineur', 'modere', 'serieux', 'critique'));

ALTER TABLE schema_mcd.historique_statut_conteneur
ADD CONSTRAINT chk_historique_statut CHECK (ancien_statut IN ('vide', 'charge', 'port', 'navire', 'inspection', 'transit') AND
                                           nouveau_statut IN ('vide', 'charge', 'port', 'navire', 'inspection', 'transit'));

-- Un événement concerne un seul contexte
ALTER TABLE schema_mcd.evenement
ADD CONSTRAINT chk_evenement_une_seule_entite
CHECK (
    (id_route IS NOT NULL)::int +
    (id_expedition IS NOT NULL)::int +
    (iso_conteneur IS NOT NULL)::int +
    (code_port IS NOT NULL)::int +
    (imo_navire IS NOT NULL)::int
    = 1
);

-- Une date d’arrivée ≥ date de départ.
ALTER TABLE schema_mcd.segment_expedition
ADD CONSTRAINT chk_dates_segment CHECK (date_arrivee_prevue >= date_depart AND (date_arrivee_reelle IS NULL OR date_arrivee_reelle >= date_depart));


-- triggers
-- Empêcher les updates sur evenement
CREATE OR REPLACE FUNCTION schema_mcd.prevent_event_update()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Modification interdite : les événements sont append-only (id_evenement=%).', OLD.id_evenement;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_no_update_evenement
BEFORE UPDATE ON schema_mcd.evenement
FOR EACH ROW
EXECUTE FUNCTION schema_mcd.prevent_event_update();

-- Auto-date pour evenement si NULL
CREATE OR REPLACE FUNCTION schema_mcd.auto_date_event()
RETURNS trigger AS $$
BEGIN
    IF NEW.date_event IS NULL THEN
        NEW.date_event := CURRENT_TIMESTAMP; -- ou CURRENT_DATE si tu veux date sans heure
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_date_event
BEFORE INSERT ON schema_mcd.evenement
FOR EACH ROW
EXECUTE FUNCTION schema_mcd.auto_date_event();

-- Un événement ne doit jamais être supprimé
CREATE OR REPLACE FUNCTION prevent_evenement_delete()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION
        'Suppression interdite : les événements sont historisés et non supprimables (id_evenement = %)',
        OLD.id_evenement;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_evenement_delete
BEFORE DELETE ON schema_mcd.evenement
FOR EACH ROW
EXECUTE FUNCTION prevent_evenement_delete();

-- L’ordre des escales est strict pour une route
-- COALESCE retourner la première valeur NON NULL dans une liste dnc retourne 0 si ordre est null
CREATE OR REPLACE FUNCTION schema_mcd.trg_check_ordre_continu()
RETURNS trigger AS $$
DECLARE
    ordre_attendu INT;
BEGIN
    SELECT COALESCE(MAX(ordre), 0) + 1
    INTO ordre_attendu
    FROM schema_mcd.escale
    WHERE id_route = NEW.id_route;

    IF NEW.ordre <> ordre_attendu THEN
        RAISE EXCEPTION
        'Ordre invalide pour la route %. Ordre attendu : %, ordre fourni : %',
        NEW.id_route, ordre_attendu, NEW.ordre;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_ordre_continu
BEFORE INSERT ON schema_mcd.escale
FOR EACH ROW
EXECUTE FUNCTION schema_mcd.trg_check_ordre_continu();
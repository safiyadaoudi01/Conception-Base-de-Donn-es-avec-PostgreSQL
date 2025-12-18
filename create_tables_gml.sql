CREATE SCHEMA IF NOT EXISTS schema_mcd;

CREATE  TABLE schema_mcd.marchandise ( 
	id_marchandise       integer  NOT NULL  ,
	nom                  varchar(200)    ,
	description          text    ,
	dangereux            boolean    ,
	CONSTRAINT pk_marchandise PRIMARY KEY ( id_marchandise )
 );

CREATE  TABLE schema_mcd.navire ( 
	imo                  char(7)  NOT NULL  ,
	nom                  varchar(200)    ,
	armateur             varchar(200)    ,
	capacite_teu         decimal(10,2)    ,
	type_navire          varchar(200)    ,
	etat                 varchar(200)    ,
	CONSTRAINT pk_navire PRIMARY KEY ( imo )
 );

CREATE  TABLE schema_mcd.port ( 
	code_port            char(6)  NOT NULL  ,
	nom                  varchar(200)    ,
	pays                 varchar(200)  NOT NULL  ,
	categorie            varchar(200)    ,
	capacite             integer    ,
	statut               varchar(200)    ,
	localisation         json  NOT NULL  ,
	CONSTRAINT pk_port PRIMARY KEY ( code_port )
 );

CREATE  TABLE schema_mcd.route ( 
	id_route             integer  NOT NULL  ,
	nom                  varchar(200)    ,
	frequence            decimal(10,2)    ,
	statut               varchar(200)    ,
	CONSTRAINT pk_route PRIMARY KEY ( id_route )
 );

CREATE  TABLE schema_mcd.conteneur ( 
	iso                  char(3)  NOT NULL  ,
	type_conteneur       varchar(200)    ,
	statut               varchar(200)    ,
	date_derniere_inspection date    ,
	poids_max            decimal(10,2)    ,
	id_marchandise_categorie integer  NOT NULL  ,
	emplacement          varchar(200)    ,
	CONSTRAINT pk_conteneur PRIMARY KEY ( iso ),
	CONSTRAINT fk_conteneur_marchandise FOREIGN KEY ( id_marchandise_categorie ) REFERENCES schema_mcd.marchandise( id_marchandise )   
 );

CREATE  TABLE schema_mcd.escale ( 
	id_escale            integer  NOT NULL  ,
	ordre                integer    ,
	duree_estimee        decimal(10,2)    ,
	distance_estimee     decimal(10,2)    ,
	code_port            char(6)  NOT NULL  ,
	id_route             integer  NOT NULL  ,
	CONSTRAINT pk_escale PRIMARY KEY ( id_escale ),
	CONSTRAINT fk_escale_port FOREIGN KEY ( code_port ) REFERENCES schema_mcd.port( code_port )   ,
	CONSTRAINT fk_escale_route FOREIGN KEY ( id_route ) REFERENCES schema_mcd.route( id_route )   
 );

CREATE  TABLE schema_mcd.expedition ( 
	id_expedition        integer  NOT NULL  ,
	client               varchar(200)    ,
	status               varchar(200)    ,
	date_creation        date    ,
	code_port_origine    char(6)  NOT NULL  ,
	code_port_destination char(6)  NOT NULL  ,
	id_route             integer  NOT NULL  ,
	CONSTRAINT pk_expedition PRIMARY KEY ( id_expedition ),
	CONSTRAINT fk_expedition_port FOREIGN KEY ( code_port_origine ) REFERENCES schema_mcd.port( code_port )   ,
	CONSTRAINT fk_expedition_port_0 FOREIGN KEY ( code_port_destination ) REFERENCES schema_mcd.port( code_port )   ,
	CONSTRAINT fk_expedition_route FOREIGN KEY ( id_route ) REFERENCES schema_mcd.route( id_route )   
 );

CREATE  TABLE schema_mcd.expedition_conteneur ( 
	id_expedition_fk     integer    ,
	iso_conteneur_fk     char(3)    ,
	CONSTRAINT fk_expedition_conteneur FOREIGN KEY ( id_expedition_fk ) REFERENCES schema_mcd.expedition( id_expedition )   ,
	CONSTRAINT fk_expedition_conteneur_1 FOREIGN KEY ( iso_conteneur_fk ) REFERENCES schema_mcd.conteneur( iso )   
 );

CREATE INDEX idx_expedition_conteneur ON schema_mcd.expedition_conteneur  ( id_expedition_fk, iso_conteneur_fk );

CREATE  TABLE schema_mcd.historique_statut_conteneur ( 
	id_historique        integer  NOT NULL  ,
	ancien_statut        varchar(200)    ,
	nouveau_statut       varchar(200)    ,
	date_statut_conteneur date    ,
	utilisateur          varchar(200)  NOT NULL  ,
	iso_conteneur        char(3)  NOT NULL  ,
	id_expedition        integer  NOT NULL  ,
	CONSTRAINT pk_historique_statut_conteneur PRIMARY KEY ( id_historique ),
	CONSTRAINT fk_historique_statut_conteneur_conteneur FOREIGN KEY ( iso_conteneur ) REFERENCES schema_mcd.conteneur( iso )   ,
	CONSTRAINT fk_historique_statut_conteneur_expedition FOREIGN KEY ( id_expedition ) REFERENCES schema_mcd.expedition( id_expedition )   
 );

CREATE  TABLE schema_mcd.segment_expedition ( 
	id_segment           integer  NOT NULL  ,
	date_depart          date    ,
	date_arrivee_prevue  date    ,
	date_arrivee_reelle  date    ,
	id_expedition        integer  NOT NULL  ,
	imo_navire           char(7)  NOT NULL  ,
	CONSTRAINT pk_segment_expedition PRIMARY KEY ( id_segment ),
	CONSTRAINT fk_segment_expedition_expedition FOREIGN KEY ( id_expedition ) REFERENCES schema_mcd.expedition( id_expedition )   ,
	CONSTRAINT fk_segment_expedition_navire FOREIGN KEY ( imo_navire ) REFERENCES schema_mcd.navire( imo )   
 );

CREATE  TABLE schema_mcd.evenement ( 
	id_evenement         integer  NOT NULL  ,
	type_event           varchar(200)    ,
	description          text    ,
	date_event           date    ,
	gravite              varchar(200)    ,
	imo_navire           char(7)    ,
	code_port            char(6)    ,
	iso_conteneur        char(3)    ,
	id_expedition        integer    ,
	id_route             integer    ,
	CONSTRAINT pk_evenement PRIMARY KEY ( id_evenement ),
	CONSTRAINT fk_evenement_navire FOREIGN KEY ( imo_navire ) REFERENCES schema_mcd.navire( imo )   ,
	CONSTRAINT fk_evenement_port FOREIGN KEY ( code_port ) REFERENCES schema_mcd.port( code_port )   ,
	CONSTRAINT fk_evenement_conteneur FOREIGN KEY ( iso_conteneur ) REFERENCES schema_mcd.conteneur( iso )   ,
	CONSTRAINT fk_evenement_expedition FOREIGN KEY ( id_expedition ) REFERENCES schema_mcd.expedition( id_expedition )   ,
	CONSTRAINT fk_evenement_route FOREIGN KEY ( id_route ) REFERENCES schema_mcd.route( id_route )   
 );


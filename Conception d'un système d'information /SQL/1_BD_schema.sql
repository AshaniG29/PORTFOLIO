DROP DATABASE IF EXISTS snowpeak;
CREATE DATABASE snowpeak
  CHARACTER SET 'utf8mb4'
  COLLATE utf8mb4_unicode_ci;

USE snowpeak;

-- 1. STATION

CREATE TABLE IF NOT EXISTS station (
  id_station  INT AUTO_INCREMENT,
  nom_station VARCHAR(100) NOT NULL,
  altitude_m  INT,
  ville VARCHAR(100),
  CONSTRAINT pk_station PRIMARY KEY (id_station)
);

-- 2. FOURNISSEUR

CREATE TABLE IF NOT EXISTS fournisseur (
  id_fournisseur INT AUTO_INCREMENT,
  nom_societe VARCHAR(100) NOT NULL,
  contact_nom VARCHAR(100),
  tel_pro VARCHAR(20),
  CONSTRAINT pk_fournisseur PRIMARY KEY (id_fournisseur)
);

-- Spécialisation : fournisseur de matériel
CREATE TABLE IF NOT EXISTS fourn_materiel (
  id_fournisseur INT NOT NULL,
  marques_proposees VARCHAR(100),
  CONSTRAINT pk_fourn_mat PRIMARY KEY (id_fournisseur),
  CONSTRAINT fk_fourn_mat FOREIGN KEY (id_fournisseur)
    REFERENCES fournisseur(id_fournisseur)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Spécialisation : fournisseur de services
CREATE TABLE IF NOT EXISTS fourn_services (
id_fournisseur  INT NOT NULL,
type_prestation ENUM('ASSURANCE_NEIGE', 'ASSISTANCE_PISTE', 'PACK_COMPLET') NOT NULL,                                                                                                                                 
CONSTRAINT pk_fourn_serv  PRIMARY KEY (id_fournisseur),
CONSTRAINT fk_fourn_serv  FOREIGN KEY (id_fournisseur) 
REFERENCES fournisseur(id_fournisseur) 
ON UPDATE CASCADE ON DELETE CASCADE
);


-- 3. CONTRAT_FOURNISSEUR

CREATE TABLE IF NOT EXISTS contrat_fournisseur (
  id_contrat INT  AUTO_INCREMENT,
  date_debut DATE NOT NULL,
  date_fin DATE,
  id_fournisseur INT NOT NULL,
  id_station INT NOT NULL,
  CONSTRAINT pk_contrat PRIMARY KEY (id_contrat),
  CONSTRAINT fk_contrat_fourn FOREIGN KEY (id_fournisseur)
    REFERENCES fournisseur(id_fournisseur)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_contrat_station FOREIGN KEY (id_station)
    REFERENCES station(id_station)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 4. EMPLOYE + MONITEUR

CREATE TABLE IF NOT EXISTS employe (
  id_employe INT AUTO_INCREMENT,
  nom VARCHAR(50) NOT NULL,
  prenom VARCHAR(50) NOT NULL,
  id_station INT NOT NULL,
  CONSTRAINT pk_employe PRIMARY KEY (id_employe),
  CONSTRAINT fk_employe_station FOREIGN KEY (id_station)
    REFERENCES station(id_station)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Spécialisation : moniteur (héritage)
CREATE TABLE IF NOT EXISTS moniteur (
  id_employe  INT NOT NULL,
  num_diplome VARCHAR(20) UNIQUE,
  CONSTRAINT pk_moniteur PRIMARY KEY (id_employe),
  CONSTRAINT fk_moniteur_employe FOREIGN KEY (id_employe)
    REFERENCES employe(id_employe)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- 5. CLIENT

CREATE TABLE IF NOT EXISTS client (
  id_client INT AUTO_INCREMENT,
  nom VARCHAR(50) NOT NULL,
  prenom VARCHAR(50)  NOT NULL,
  date_naissance DATE NOT NULL,
  email VARCHAR(100) UNIQUE,
  telephone VARCHAR(20),
  adresse VARCHAR(100),
  CONSTRAINT pk_client PRIMARY KEY (id_client)
);

-- 6. FORFAIT + SOUSCRIPTION_FORFAIT

CREATE TABLE IF NOT EXISTS forfait (
  id_forfait INT AUTO_INCREMENT,
  libelle VARCHAR(50),
  prix_unitaire DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_forfait  PRIMARY KEY (id_forfait),
  CONSTRAINT ck_forfait_prix CHECK (prix_unitaire > 0)
);

CREATE TABLE IF NOT EXISTS souscription_forfait (
  id_souscription INT  AUTO_INCREMENT,
  date_debut DATE,
  date_fin DATE,
  date_achat DATE,
  id_client INT  NOT NULL,
  id_forfait INT  NOT NULL,
  CONSTRAINT pk_souscription PRIMARY KEY (id_souscription),
  CONSTRAINT fk_souscr_client FOREIGN KEY (id_client)
    REFERENCES client(id_client)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_souscr_forfait  FOREIGN KEY (id_forfait)
    REFERENCES forfait(id_forfait)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 7. COURS + SESSION_COURS + RESERVATION_COURS

CREATE TABLE IF NOT EXISTS cours (
  id_cours INT AUTO_INCREMENT,
  niveau VARCHAR(20),
  CONSTRAINT pk_cours PRIMARY KEY (id_cours)
);

CREATE TABLE IF NOT EXISTS session_cours (
  id_session INT AUTO_INCREMENT,
  id_cours INT NOT NULL,
  id_employe INT NOT NULL,
  nb_places_restantes INT UNSIGNED,
  CONSTRAINT pk_session PRIMARY KEY (id_session),
  CONSTRAINT fk_session_cours FOREIGN KEY (id_cours)
    REFERENCES cours(id_cours)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_session_moniteur FOREIGN KEY (id_employe)
    REFERENCES moniteur(id_employe)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS reservation_cours (
  id_client INT NOT NULL,
  id_session INT NOT NULL,
  date_inscription DATETIME,
  CONSTRAINT pk_resa_cours PRIMARY KEY (id_client, id_session),
  CONSTRAINT fk_resa_cours_client  FOREIGN KEY (id_client)
    REFERENCES client(id_client)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_resa_cours_session FOREIGN KEY (id_session)
    REFERENCES session_cours(id_session)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 8. EQUIPEMENT + RESERVATION_EQUIPEMENT + LIGNE_RESERVATION

CREATE TABLE IF NOT EXISTS equipement (
  id_equipement   INT AUTO_INCREMENT,
  type_mat VARCHAR(50) NOT NULL, -- "Ski Rossignol", "Snowboard Burton"
  etat ENUM('NEUF', 'BON', 'USURE', 'HORS_SERVICE') DEFAULT 'NEUF',
  disponibilite BOOLEAN DEFAULT TRUE,
  prix_jour_base  DECIMAL(10,2) NOT NULL,
  id_station INT NOT NULL, 
  CONSTRAINT pk_equipement PRIMARY KEY (id_equipement),
  CONSTRAINT fk_equipement_station FOREIGN KEY (id_station) 
REFERENCES station(id_station)
    ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS reservation_equipement (
  id_resa_mat INT AUTO_INCREMENT,
  id_client INT NOT NULL,
  date_resa DATETIME,
  CONSTRAINT pk_resa_mat PRIMARY KEY (id_resa_mat),
  CONSTRAINT fk_resa_mat_client FOREIGN KEY (id_client)
    REFERENCES client(id_client)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS ligne_reservation (
  id_ligne INT AUTO_INCREMENT,
  id_resa_mat INT NOT NULL,
  id_equipement INT NOT NULL,
  date_ret_reel DATETIME,
  prix_applique DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_ligne_resa PRIMARY KEY (id_ligne),
  CONSTRAINT fk_ligne_resa_mat FOREIGN KEY (id_resa_mat)
    REFERENCES reservation_equipement(id_resa_mat)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ligne_equipement FOREIGN KEY (id_equipement)
    REFERENCES equipement(id_equipement)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 9. FACTURE_CLIENT + PAIEMENT_CLIENT

CREATE TABLE IF NOT EXISTS facture_client (
  id_facture_c INT AUTO_INCREMENT,
  date_facture DATE DEFAULT (CURRENT_DATE),
  total_ttc DECIMAL(10,2),
  id_client INT NOT NULL,
  statut_paiement ENUM('NON_PAYE', 'PARTIEL', 'PAYE') DEFAULT 'NON_PAYE',
  CONSTRAINT pk_facture_c PRIMARY KEY (id_facture_c),
  CONSTRAINT fk_facture_c_client  FOREIGN KEY (id_client)
    REFERENCES client(id_client)
);

CREATE TABLE IF NOT EXISTS paiement_client (
  id_paiement_c INT AUTO_INCREMENT,
  id_facture_c  INT NOT NULL,
  mode_paiement VARCHAR(20),
  CONSTRAINT pk_paiement_c PRIMARY KEY (id_paiement_c),
  CONSTRAINT fk_paiement_c_facture FOREIGN KEY (id_facture_c)
    REFERENCES facture_client(id_facture_c)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 10. FACTURE_FOURNISSEUR + PAIEMENT_FOURNISSEUR

CREATE TABLE IF NOT EXISTS facture_fournisseur (
  id_facture_f INT AUTO_INCREMENT,
  date_reception DATE,
  date_echeance  DATE,       
  montant_du DECIMAL(10,2),
  id_contrat INT NOT NULL,
  statut_paiement ENUM('A_PAYER', 'EN_COURS', 'REGLE') DEFAULT 'A_PAYER',
  CONSTRAINT pk_facture_f PRIMARY KEY (id_facture_f),
  CONSTRAINT fk_facture_f_contrat FOREIGN KEY (id_contrat)
    REFERENCES contrat_fournisseur(id_contrat)
);

CREATE TABLE IF NOT EXISTS paiement_fournisseur (
  id_paiement_f INT AUTO_INCREMENT,
  date_virement DATE,
  montant DECIMAL(10,2),
  id_facture_f  INT NOT NULL,
  CONSTRAINT pk_paiement_f PRIMARY KEY (id_paiement_f),
  CONSTRAINT fk_paiement_f_facture FOREIGN KEY (id_facture_f)
    REFERENCES facture_fournisseur(id_facture_f)
    ON UPDATE CASCADE ON DELETE RESTRICT
);
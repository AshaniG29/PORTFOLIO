-- ===============================
-- Question 1 - Création de la base afihm
-- ===============================
DROP DATABASE IF EXISTS afihm;
CREATE DATABASE IF NOT EXISTS afihm;
USE afihm;

-- ===============================
-- Création des tables
-- ===============================
CREATE TABLE personne (
  personne_id INT AUTO_INCREMENT PRIMARY KEY,
  prenom VARCHAR(50) NOT NULL,
  nom VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL UNIQUE,
  web VARCHAR(255),
  last_login DATETIME,
  pwd_hash VARCHAR(255),
  pwd_policy_version INT NOT NULL DEFAULT 1
);

CREATE TABLE membre (
  numero_membre INT PRIMARY KEY,
  personne_id INT NOT NULL UNIQUE,
  date_attribution DATE NOT NULL,
  CONSTRAINT fk_membre_personne
    FOREIGN KEY (personne_id) REFERENCES personne(personne_id)
);

CREATE TABLE adhesion (
  adhesion_id INT AUTO_INCREMENT PRIMARY KEY,
  personne_id INT NOT NULL,
  organisme VARCHAR(100) NOT NULL,
  debut DATE NOT NULL,
  fin DATE NOT NULL,
  tarif DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_adhesion_personne
    FOREIGN KEY (personne_id) REFERENCES personne(personne_id),
  CONSTRAINT ck_adhesion_periode CHECK (debut < fin),
  CONSTRAINT uq_adhesion_personne_debut UNIQUE (personne_id, debut)
);

CREATE TABLE adresse (
  adresse_id INT AUTO_INCREMENT PRIMARY KEY,
  personne_id INT NOT NULL,
  type VARCHAR(30) NOT NULL,
  ligne1 VARCHAR(255) NOT NULL,
  ligne2 VARCHAR(255),
  code_postal VARCHAR(12),
  ville VARCHAR(100),
  pays VARCHAR(100),
  is_principale BOOLEAN DEFAULT FALSE,
  valide_du DATE NOT NULL,
  valide_au DATE,
  CONSTRAINT fk_adresse_personne
    FOREIGN KEY (personne_id) REFERENCES personne(personne_id)
);

CREATE TABLE conference (
  conf_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  libelle VARCHAR(255) NOT NULL,
  date_debut DATE,
  date_fin DATE,
  ville VARCHAR(100)
);

CREATE TABLE evenement (
  evt_id INT AUTO_INCREMENT PRIMARY KEY,
  conf_id INT NOT NULL,
  type VARCHAR(30),
  libelle VARCHAR(255),
  capacite INT,
  CONSTRAINT fk_evenement_conference
    FOREIGN KEY (conf_id) REFERENCES conference(conf_id)
);

CREATE TABLE atelier (
  atelier_id INT AUTO_INCREMENT PRIMARY KEY,
  evt_id INT NOT NULL UNIQUE,   -- #evt_id UNIQUE
  theme VARCHAR(255),
  creneau VARCHAR(100),
  capacite INT,
  CONSTRAINT fk_atelier_evenement
    FOREIGN KEY (evt_id) REFERENCES evenement(evt_id)
);

CREATE TABLE coupon (
  coupon_code VARCHAR(50) PRIMARY KEY,
  libelle VARCHAR(255),
  type VARCHAR(30),
  valeur DECIMAL(10,2),
  cumulable BOOLEAN,
  valide_du DATE,
  valide_au DATE,
  nb_max_usages INT
);

CREATE TABLE inscription (
  inscr_id INT AUTO_INCREMENT PRIMARY KEY,
  personne_id INT NOT NULL,
  conf_id INT NOT NULL,
  statut VARCHAR(30),
  type VARCHAR(10) NOT NULL,
  date_inscr DATE,
  montant_calcule DECIMAL(10,2),
  coupon_code VARCHAR(50),
  besoins_accessibilite TEXT,
  regime VARCHAR(100),
  allergies TEXT,
  autres TEXT,
  CONSTRAINT fk_inscription_personne
    FOREIGN KEY (personne_id) REFERENCES personne(personne_id),
  CONSTRAINT fk_inscription_conference
    FOREIGN KEY (conf_id)     REFERENCES conference(conf_id),
  CONSTRAINT fk_inscription_coupon
    FOREIGN KEY (coupon_code) REFERENCES coupon(coupon_code),
  -- CHECK : type IN ('conf','evts','cmas')
  CONSTRAINT ck_inscription_type CHECK (type IN ('conf','evts','cmas')),
  -- UK : (#personne_id, #conf_id)
  CONSTRAINT uq_inscription_personne_conf UNIQUE (personne_id, conf_id)
);

CREATE TABLE participation_evt (
  inscr_id INT NOT NULL,
  evt_id INT NOT NULL,
  quantite INT NOT NULL DEFAULT 1,
  PRIMARY KEY (inscr_id, evt_id),
  CONSTRAINT fk_participation_inscription
    FOREIGN KEY (inscr_id) REFERENCES inscription(inscr_id),
  CONSTRAINT fk_participation_evenement
    FOREIGN KEY (evt_id)   REFERENCES evenement(evt_id)
);

CREATE TABLE produit (
  produit_id INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  prix_public DECIMAL(10,2),
  prix_membre DECIMAL(10,2),
  categorie VARCHAR(50),
  conf_id INT,
  CONSTRAINT fk_produit_conference
    FOREIGN KEY (conf_id) REFERENCES conference(conf_id)
);

CREATE TABLE facture (
  facture_id INT AUTO_INCREMENT PRIMARY KEY,
  date_facture DATE NOT NULL,
  code_acces VARCHAR(50),
  personne_id INT,
  adresse_id_source INT,
  adresse_nom VARCHAR(100),
  adresse_prenom VARCHAR(100),
  email VARCHAR(50),
  phone_number VARCHAR(30),
  CONSTRAINT fk_facture_personne
    FOREIGN KEY (personne_id) REFERENCES personne(personne_id),
  CONSTRAINT fk_facture_adresse
    FOREIGN KEY (adresse_id_source) REFERENCES adresse(adresse_id)
);

CREATE TABLE ligne_facture (
  facture_id INT NOT NULL,
  ligne_no INT NOT NULL,
  produit_id INT NOT NULL,
  qte INT NOT NULL,
  prix_unitaire_ttc DECIMAL(10,2) NOT NULL,
  reduction_ttc DECIMAL(10,2) NOT NULL DEFAULT 0,
  inscr_id INT,
  adhesion_id INT,
  PRIMARY KEY (facture_id, ligne_no),   -- PK(facture_id, ligne_no)
  CONSTRAINT fk_ligne_facture_facture
    FOREIGN KEY (facture_id) REFERENCES facture(facture_id),
  CONSTRAINT fk_ligne_facture_produit
    FOREIGN KEY (produit_id) REFERENCES produit(produit_id),
  CONSTRAINT fk_ligne_facture_inscription
    FOREIGN KEY (inscr_id) REFERENCES inscription(inscr_id),
  CONSTRAINT fk_ligne_facture_adhesion
    FOREIGN KEY (adhesion_id) REFERENCES adhesion(adhesion_id),
  -- CK : X (#inscr_id, #adhesion_id)  -> exactement l’un des deux est renseigné
  CONSTRAINT ck_ligne_facture_x CHECK ((inscr_id    IS NULL) <> (adhesion_id IS NULL))
);

CREATE TABLE paiement (
  paiement_id INT AUTO_INCREMENT PRIMARY KEY,
  facture_id INT NOT NULL,
  date_paiement DATE NOT NULL,
  moyen VARCHAR(20), -- (CB, virement, autre)
  ref_transaction VARCHAR(100),
  autorisation VARCHAR(100),
  virement_ref VARCHAR(100),
  montant DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_paiement_facture
    FOREIGN KEY (facture_id) REFERENCES facture(facture_id)
);

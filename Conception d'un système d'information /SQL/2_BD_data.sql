--  SnowPeak : Insertion des données

USE snowpeak;

-- 1. STATIONS (3 stations)

INSERT INTO station (nom_station, altitude_m, ville) VALUES
  ('SnowPeak Alpes Nord',1000, 'Morzine'),
  ('SnowPeak Alpes Sud',1650, 'Les Deux Alpes'),
  ('SnowPeak Pyrénées',930, 'Cauterets');

-- 2. FOURNISSEURS

INSERT INTO fournisseur (nom_societe, contact_nom, tel_pro) VALUES
  ('AlpEquip SAS','Morad Yahia',  '04 56 81 92 36'),
  ('SkiProtect SARL', 'Julie Morin', '04 79 64 75 62'),
  ('Montagne Pro','Carlos Rodriguez','04 50 36 24 85'),
  ('AltiServ','Nina Roux','05 12 18 23 63');

INSERT INTO fourn_materiel (id_fournisseur, marques_proposees) VALUES
  (1, 'Rossignol, Salomon, Atomic'),
  (3, 'Burton, Head, Fischer');

INSERT INTO fourn_services (id_fournisseur, type_prestation) VALUES
  (2, 'ASSURANCE_NEIGE'),
  (4, 'PACK_COMPLET');


-- 3. CONTRATS FOURNISSEURS

INSERT INTO contrat_fournisseur (date_debut, date_fin, id_fournisseur, id_station) VALUES
  ('2025-09-01', '2026-08-31', 1, 1),
  ('2025-09-01', '2026-08-31', 1, 2),
  ('2025-10-01', '2026-04-30', 2, 1),
  ('2025-10-01', '2026-04-30', 2, 2),
  ('2025-11-01', '2026-03-31', 3, 3),
  ('2025-11-01', '2026-03-31', 4, 3),
  ('2025-12-01', '2026-04-30', 4, 1),
  ('2025-12-01', '2026-04-30', 3, 2);


-- 4. EMPLOYES

INSERT INTO employe (nom, prenom, id_station) VALUES
  ('Leblanc','Thomas',1),
  ('Yamamoto','Sakura', 1),
  ('Girard','Pauline', 2),
  ('Martinez', 'Diego',2),
  ('Petrov','Dimitri',3),
  ('Roux','Kevin',1),
  ('Mbeki','Amara',2),
  ('Benrif','Fatima', 3);

INSERT INTO moniteur (id_employe, num_diplome) VALUES
  (1, 'BE-SKI-2019-001'),
  (2, 'BE-SKI-2020-042'),
  (3, 'BE-SKI-2018-017'),
  (4, 'BE-SKI-2021-033'),
  (5, 'BE-SKI-2022-008'),
  (8, 'BE-SKI-2023-015');

-- 5. CLIENTS

INSERT INTO client (nom, prenom, date_naissance, email, telephone, adresse) VALUES
  ('Martin',  'Jean','1985-03-15', 'jean.martin@gmail.com','0674839058', '12 rue de la Paix, 38000 Grenoble'),
  ('Morales', 'Antonia', '1990-07-22', 'antonia.morales@gmail.com','0768849274', '5 av des Fleurs, 69001 Lyon'),
  ('Osei',  'Abena',  '1978-11-03', 'abena.osei@yahoo.fr','0672950283', '8 bd Haussmann, 75008 Paris'),
  ('Leroy','Marc','2000-01-30', 'marc.leroy@hotmail.fr','0722177589', '22 rue Victor Hugo, 13001 Marseille'),
  ('Chen','Mei','1995-06-18', 'mei.chen@gmail.com','0600921563', '3 rue de la République, 38000 Grenoble'),
  ('Hoffman', 'Erik','1982-09-25', 'erik.hoffman@gmail.com','0645349508', '15 rue du Lac, 74000 Annecy'),
  ('Patel',  'Arjun','2005-04-12', 'arjun.patel@outlok.com','0692238450', '7 impasse des Pins, 31000 Toulouse'),
  ('Nguyen',  'Linh','1998-12-05', 'linh.nguyen@gmail.com','0619263129', '18 rue de Bretagne, 44000 Nantes');


-- 6. FORFAITS + SOUSCRIPTIONS

INSERT INTO forfait (libelle, prix_unitaire) VALUES
  ('Forfait Journée',35.00),
  ('Forfait Week-end',60.00),
  ('Forfait Semaine',190.00),
  ('Forfait Saison',650.00),
  ('Forfait Débutant',25.00),
  ('Forfait Famille',120.00),
  ('Forfait Étudiant',45.00),
  ('Forfait Senior',30.00);

INSERT INTO souscription_forfait (date_achat, date_debut, date_fin, id_client, id_forfait) VALUES
  ('2026-01-10', '2026-01-15', '2026-01-21', 1, 3),
  ('2026-01-12', '2026-01-18', '2026-01-18', 2, 1),
  ('2025-11-01', '2025-12-20', '2026-04-20', 3, 4),
  ('2026-02-01', '2026-02-08', '2026-02-09', 4, 2),
  ('2026-01-20', '2026-01-25', '2026-01-31', 5, 3),
  ('2026-02-10', '2026-02-14', '2026-02-14', 6, 1),
  ('2026-01-05', '2026-01-10', '2026-01-10', 7, 5),
  ('2026-02-15', '2026-02-20', '2026-02-21', 8, 2);


-- 7. COURS + SESSIONS + RÉSERVATIONS

INSERT INTO cours (niveau) VALUES
  ('Débutant'),
  ('Intermédiaire'),
  ('Expert'),
  ('Débutant'),
  ('Intermédiaire'),
  ('Expert'),
  ('Débutant'),
  ('Intermédiaire');

INSERT INTO session_cours (id_cours, id_employe, nb_places_restantes) VALUES
  (1, 1, 5),
  (1, 2, 3),
  (2, 1, 4),
  (3, 2, 6),
  (4, 3, 2),
  (5, 4, 7),
  (6, 5, 0),
  (7, 8, 3);

INSERT INTO reservation_cours (id_client, id_session, date_inscription) VALUES
  (1, 1, '2026-01-11 10:00:00'),
  (2, 1, '2026-01-12 14:30:00'),
  (4, 2, '2026-01-13 09:00:00'),
  (5, 3, '2026-01-21 16:00:00'),
  (3, 5, '2026-02-01 11:00:00'),
  (6, 4, '2026-01-20 08:30:00'),
  (7, 7, '2026-01-10 15:00:00'),
  (8, 7, '2026-01-15 10:00:00');


-- 8. ÉQUIPEMENTS + RÉSERVATIONS + LIGNES

INSERT INTO equipement (type_mat, etat, disponibilite, prix_jour_base, id_station) VALUES
  ('Skis Rossignol Experience 80 170cm', 'BON',          TRUE,  15.00, 1),
  ('Skis Salomon XDR 80 165cm',          'BON',          TRUE,  15.00, 1),
  ('Skis Atomic Redster 175cm',          'NEUF',         TRUE,  18.00, 1),
  ('Snowboard Burton Custom 158cm',      'BON',          TRUE,  20.00, 1),
  ('Snowboard Salomon Pulse 154cm',      'USURE',        FALSE, 12.00, 1),
  ('Luge Standard Adulte',               'BON',          TRUE,   8.00, 2),
  ('Skis Rossignol React 6 160cm',       'NEUF',         TRUE,  18.00, 2),
  ('Skis Head Kore 93 172cm',            'BON',          TRUE,  16.00, 2),
  ('Snowboard Lib Tech 156cm',           'BON',          TRUE,  20.00, 2),
  ('Luge Standard Enfant',               'BON',          TRUE,   6.00, 2),
  ('Skis Fischer RC4 168cm',             'HORS_SERVICE', FALSE, 14.00, 3),
  ('Snowboard Burton Instigator 152cm',  'NEUF',         TRUE,  20.00, 3);

INSERT INTO reservation_equipement (id_client, date_resa) VALUES
  (1, '2026-01-14 18:00:00'),
  (2, '2026-01-17 09:30:00'),
  (3, '2026-02-07 14:00:00'),
  (4, '2026-02-09 10:00:00'),
  (5, '2026-01-24 16:00:00'),
  (6, '2026-02-13 11:00:00'),
  (7, '2026-02-18 09:00:00'),
  (8, '2026-02-20 14:00:00');

INSERT INTO ligne_reservation (id_resa_mat, id_equipement, date_ret_reel, prix_applique) VALUES
  (1, 1,  '2026-01-21 17:30:00', 105.00),
  (1, 6,  '2026-01-21 17:30:00',  56.00),
  (2, 2,  NULL, 15.00),
  (3, 7,  NULL, 126.00),
  (3, 9,  NULL, 140.00),
  (4, 4,  NULL, 20.00),
  (5, 3,  NULL, 18.00),
  (6, 12, NULL, 20.00);


-- 9. FACTURES + PAIEMENTS

INSERT INTO facture_client (date_facture, total_ttc, id_client, statut_paiement) VALUES
  ('2026-01-21', 300.00, 1, 'PAYE'),
  ('2026-01-19',  18.00, 2, 'PAYE'),
  ('2026-02-15', 320.40, 3, 'NON_PAYE'),
  ('2026-02-10',  24.00, 4, 'PAYE'),
  ('2026-01-25', 216.00, 5, 'PARTIEL'),
  ('2026-02-14',  35.00, 6, 'PAYE'),
  ('2026-01-10',  30.00, 7, 'NON_PAYE'),
  ('2026-02-20',  72.00, 8, 'NON_PAYE');

INSERT INTO paiement_client (id_facture_c, mode_paiement) VALUES
  (1, 'CB'),
  (2, 'Espèces'),
  (4, 'CB'),
  (5, 'Chèque'),
  (6, 'CB'),
  (1, 'CB'),
  (3, 'Virement'),
  (8, 'CB');


INSERT INTO facture_fournisseur (date_reception, date_echeance, montant_du, id_contrat, statut_paiement) VALUES
  ('2026-01-05', '2026-01-20', 11250.00, 1, 'REGLE'),
  ('2026-01-05', '2026-01-20',  9500.00, 2, 'REGLE'),
  ('2026-01-10', '2026-01-25',  5500.00, 3, 'REGLE'),
  ('2026-02-05', '2026-02-20', 11250.00, 1, 'A_PAYER'),
  ('2026-02-10', '2026-02-25',  4625.00, 4, 'A_PAYER'),
  ('2026-01-15', '2026-01-30',  7750.00, 5, 'REGLE'),
  ('2026-02-01', '2026-02-15',  3750.00, 6, 'EN_COURS'),
  ('2026-02-12', '2026-02-27',  6000.00, 7, 'A_PAYER');

INSERT INTO paiement_fournisseur (date_virement, montant, id_facture_f) VALUES
  ('2026-01-20', 11250.00, 1),
  ('2026-01-20',  9500.00, 2),
  ('2026-01-25',  5500.00, 3),
  ('2026-01-30',  7750.00, 6),
  ('2026-02-10',  1875.00, 7),
  ('2026-01-22',  4000.00, 1),
  ('2026-01-28',  3000.00, 2),
  ('2026-02-05',  2500.00, 3);
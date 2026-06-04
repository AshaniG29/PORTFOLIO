-- =========================
-- Question 2 - Insertion de données fictives
-- =========================
USE afihm;

INSERT INTO personne (prenom, nom, email, web, last_login, pwd_hash, pwd_policy_version) VALUES
('Alice','Martin','alice.martin@gmail.cop','https://alice.siteweb.org', '2024-11-10 09:30:00', 'hash_alice', 1),
('Bob','Durand','bob.durand@orange.fr', NULL, NULL,'hash_bob',1),
('Claire','Petit','claire.petit@hotmail.comm', NULL, NULL,'hash_claire',1),
('David','Leroy','david.leroy@gmail.com', NULL, NULL,'hash_david', 1);

INSERT INTO membre (numero_membre, personne_id, date_attribution) VALUES
(1001, 1, '2025-10-13'),
(1002, 2, '2025-11-11');

INSERT INTO adhesion (personne_id, organisme, debut, fin, tarif) VALUES
(1, 'AFIHM', '2024-01-01', '2024-12-31', 80.00),
(1, 'AFIHM', '2025-01-01', '2025-12-31', 80.00),
(2, 'AFIHM', '2025-01-01', '2025-12-31', 80.00);

INSERT INTO adresse (personne_id, type, ligne1, ligne2, code_postal, ville, pays, is_principale, valide_du, valide_au) VALUES
(1, 'facturation', '9 ruelle des Jardins', NULL, '38000', 'Grenoble', 'France', TRUE, '2025-01-01', NULL),
(2, 'facturation', '163 route du bec des Alpes', NULL, '69000', 'Lyon', 'France', TRUE, '2025-01-01', NULL),
(3, 'facturation', '43 avenue de Geneve', NULL, '74000', 'Annecy', 'France', TRUE, '2025-01-01', NULL),
(4, 'facturation', '12 rue Nationale', NULL, '75000', 'Paris', 'France', TRUE, '2025-01-01', NULL);

INSERT INTO conference (code, libelle, date_debut, date_fin, ville) VALUES
('IHM2025', 'Conférence IHM 2025', '2025-04-20', '2025-04-24', 'Grenoble');

INSERT INTO evenement (conf_id, type, libelle, capacite) VALUES
(1, 'session', 'Keynote d''ouverture', 300),
(1, 'atelier', 'Atelier UX participatif', 40),
(1, 'social', 'Banquet de gala', 200);

INSERT INTO atelier (evt_id, theme, creneau, capacite) VALUES
(2, 'Atelier UX : prototypage', '2025-04-21 matin', 40); -- (lié à l’événement 2) --

INSERT INTO coupon (coupon_code, libelle, type, valeur, cumulable, valide_du, valide_au, nb_max_usages) VALUES
('EARLYBIRD', 'Réduction early bird 20 %', 'pourcentage', 20.00, TRUE,  '2025-10-01', '2026-01-31', 200),
('ETUDIANT', 'Réduction inscription étudiant','montant', 50.00, FALSE, '2025-10-01', '2026-04-15', 500);

INSERT INTO inscription (personne_id, conf_id, statut, type, date_inscr, montant_calcule,coupon_code, besoins_accessibilite, regime, allergies, autres) VALUES
(1, 1, 'validee', 'conf', '2025-12-10', 280.00, 'EARLYBIRD', 'Boucle magnétique', 'végétarien', NULL, NULL),
(2, 1, 'validee', 'conf', '2025-01-05', 300.00,'ETUDIANT', NULL, NULL, NULL, NULL);

INSERT INTO participation_evt (inscr_id, evt_id, quantite) VALUES
((SELECT inscr_id FROM inscription WHERE personne_id=1), 1, 1), -- Alice : keynote
((SELECT inscr_id FROM inscription WHERE personne_id=1), 2, 1), -- Alice : atelier UX
((SELECT inscr_id FROM inscription WHERE personne_id=1), 3, 1); -- Alice : banquet

INSERT INTO produit (nom, prix_public, prix_membre, categorie, conf_id) VALUES
('Inscription IHM 2025 - plein tarif', 450.00, 350.00, 'inscription', 1),
('Inscription IHM 2025 - étudiant', 300.00, 250.00, 'inscription', 1),
('Cotisation AFIHM 2024', 80.00,  80.00, 'adhesion', NULL),
('Cotisation AFIHM 2025', 80.00,  80.00, 'adhesion', NULL);

INSERT INTO facture (date_facture, code_acces, personne_id, adresse_id_source,adresse_nom, adresse_prenom, email, phone_number) VALUES
('2024-12-20', 'F2024-0001', 1, 1, 'Martin', 'Alice', 'alice.martin@example.org', '+33 6 11 22 33 44'),
('2025-01-15', 'F2025-0005', 2, 2, 'Durand', 'Bob',   'bob.durand@example.org',   '+33 6 55 66 77 88');

INSERT INTO ligne_facture (facture_id, ligne_no, produit_id, qte,prix_unitaire_ttc, reduction_ttc, inscr_id, adhesion_id) VALUES
-- (adhésion 2024 de Alice)
(1, 1, 3, 1,80.00, 0.00,NULL,
(SELECT a.adhesion_id
FROM adhesion a
WHERE a.personne_id = 1 AND a.organisme = 'AFIHM'AND a.debut = '2024-01-01')),
-- (avec réduction)
(1, 2, 1, 1,350.00, 70.00,
(SELECT i.inscr_id
FROM inscription i
WHERE i.personne_id = 1 AND i.conf_id = 1),NULL),
-- (adhésion 2025 de Bob)
(2, 1, 4, 1,80.00, 0.00,NULL,
(SELECT a.adhesion_id
FROM adhesion a
WHERE a.personne_id = 2 AND a.organisme = 'AFIHM' AND a.debut = '2025-01-01')),
-- inscription conf IHM 2025 de Bob
(2, 2, 2, 1,300.00, 0.00,
(SELECT i.inscr_id
FROM inscription i
WHERE i.personne_id = 2 AND i.conf_id = 1),NULL);

INSERT INTO paiement (facture_id, date_paiement, moyen, ref_transaction, autorisation, virement_ref, montant) VALUES
(1, '2024-12-22', 'CB','CB-20241222-0001', 'AUTH123', NULL, 360.00),
(2, '2025-01-18', 'virement', NULL,NULL,'VIR-20250118-0007', 380.00);
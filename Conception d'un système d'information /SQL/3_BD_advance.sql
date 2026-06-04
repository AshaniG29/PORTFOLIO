USE snowpeak;

## PARTIE 1 – REQUÊTES SELECT ##
# Ce SELECT a pour objectif d'avoir un catalogue complet des équipements disponibles par station ainsi que leurs états
SELECT s.nom_station, s.ville, e.id_equipement, e.type_mat, e.etat, e.prix_jour_base,
CASE e.disponibilite
WHEN TRUE  THEN 'Disponible'
WHEN FALSE THEN 'En location'
END AS statut_dispo
FROM equipement e
JOIN station s ON s.id_station = e.id_station
ORDER BY s.nom_station, e.type_mat, e.etat;

# Ce SELECT a pour objectif d'avoir un bilan sur les stocks de chaque station selon le type des materiels/ matériaux 
SELECT s.nom_station, e.type_mat, COUNT(*) AS total, SUM(e.disponibilite) AS disponibles, COUNT(*) - SUM(e.disponibilite) AS en_location, ROUND(SUM(e.disponibilite) / COUNT(*) * 100, 1) AS taux_dispo_pct, ROUND(AVG(e.prix_jour_base), 2) AS prix_moyen_jour
FROM equipement e
JOIN station s ON s.id_station = e.id_station
WHERE e.etat != 'HORS_SERVICE'
GROUP BY s.nom_station, e.type_mat
ORDER BY s.nom_station, e.type_mat;

# Ce SELECT a pour objectif de connaître le nombre d'équipements, de cours et d'employés dans chaque station dans le but d'avoir un tableau de bord de direction
SELECT s.id_station, s.nom_station, s.ville, s.altitude_m, COUNT(DISTINCT e.id_equipement) AS nb_equipements, SUM(e.disponibilite) AS equip_disponibles, COUNT(DISTINCT co.id_cours) AS nb_cours_catalogue, COUNT(DISTINCT emp.id_employe) AS nb_employes, COUNT(DISTINCT m.id_employe) AS nb_moniteurs
FROM station s
LEFT JOIN equipement e ON e.id_station  = s.id_station
LEFT JOIN cours co ON co.id_cours IN (SELECT id_cours FROM session_cours sc2
JOIN moniteur m2 ON m2.id_employe = sc2.id_employe
JOIN employe e2  ON e2.id_employe = m2.id_employe
WHERE e2.id_station = s.id_station)
LEFT JOIN employe emp ON emp.id_station = s.id_station
LEFT JOIN moniteur m ON m.id_employe   = emp.id_employe
GROUP BY s.id_station, s.nom_station, s.ville, s.altitude_m
ORDER BY s.nom_station;

# Ce SELECT a pour objectif d'avoir une liste des fournisseurs en fonction de leur spécialité et leurs contrats
SELECT f.id_fournisseur, f.nom_societe, f.contact_nom, f.tel_pro, COALESCE(fm.marques_proposees, '—') AS marques_materiel, COALESCE(fs.type_prestation,  '—') AS type_service,
CASE
WHEN fm.id_fournisseur IS NOT NULL THEN 'MATERIEL'
WHEN fs.id_fournisseur IS NOT NULL THEN 'SERVICES'
ELSE 'NON CLASSIFIE'
END AS type_fournisseur,
COUNT(DISTINCT cf.id_contrat) AS nb_contrats_actifs, GROUP_CONCAT(DISTINCT st.nom_station)  AS stations_liees
FROM fournisseur f
LEFT JOIN fourn_materiel fm ON fm.id_fournisseur = f.id_fournisseur
LEFT JOIN fourn_services fs ON fs.id_fournisseur = f.id_fournisseur
LEFT JOIN contrat_fournisseur cf ON cf.id_fournisseur = f.id_fournisseur
AND (cf.date_fin IS NULL OR cf.date_fin >= CURDATE())
LEFT JOIN station st ON st.id_station = cf.id_station
GROUP BY f.id_fournisseur, f.nom_societe, f.contact_nom, f.tel_pro, fm.marques_proposees, fs.type_prestation
ORDER BY type_fournisseur, f.nom_societe;

# Ce SELECT a pour objectif d'avoir uen liste de toutes les réservations déquipements (avec le détail des clients, du matériel, de la date et de l'état de retour)
SELECT r.id_resa_mat, r.date_resa, CONCAT(c.prenom, ' ', c.nom) AS client, c.telephone, s.nom_station,e.type_mat, e.etat AS etat_equipement, lr.prix_applique, lr.date_ret_reel,
CASE
WHEN lr.date_ret_reel IS NOT NULL THEN 'RENDU'
ELSE 'EN COURS'
END AS statut_ligne, 
DATEDIFF(COALESCE(lr.date_ret_reel, NOW()), r.date_resa) AS nb_jours
FROM reservation_equipement r
JOIN client c ON c.id_client = r.id_client
JOIN ligne_reservation lr ON lr.id_resa_mat = r.id_resa_mat
JOIN equipement e ON e.id_equipement = lr.id_equipement
JOIN station s ON s.id_station = e.id_station
ORDER BY r.date_resa DESC;

# Ce SELECT a pour objectif d'avoir les réservations des cours avec le détail des sessions et des clients
SELECT rc.date_inscription, CONCAT(c.prenom, ' ', c.nom) AS client, c.email, co.niveau, CONCAT(emp.prenom, ' ', emp.nom) AS moniteur, s.nom_station, sc.nb_places_restantes
FROM reservation_cours rc
JOIN client c ON c.id_client = rc.id_client
JOIN session_cours sc ON sc.id_session = rc.id_session
JOIN cours co ON co.id_cours = sc.id_cours
JOIN moniteur m ON m.id_employe = sc.id_employe
JOIN employe emp ON emp.id_employe = m.id_employe
JOIN station s ON s.id_station = emp.id_station
ORDER BY rc.date_inscription DESC;

# Ce SELECT a pour objectif d'avoir un suivi des factures clients avec le statut des paiements
SELECT fc.id_facture_c, fc.date_facture, CONCAT(c.prenom, ' ', c.nom) AS client, c.email, fc.total_ttc, fc.statut_paiement, DATEDIFF(CURDATE(), fc.date_facture)  AS age_jours, COUNT(pc.id_paiement_c) AS nb_paiements_enregistres
FROM facture_client fc
JOIN client c ON c.id_client = fc.id_client
LEFT JOIN paiement_client pc ON pc.id_facture_c = fc.id_facture_c
GROUP BY fc.id_facture_c, fc.date_facture, c.prenom, c.nom, c.email, fc.total_ttc, fc.statut_paiement
ORDER BY fc.date_facture DESC;

# Ce SELECT a pour objectif de connaître les factures fournisseurs non réglées et en retard pour permettre à la station de les payer au plus vite
SELECT f.nom_societe, f.contact_nom, f.tel_pro,
CASE
WHEN fm.id_fournisseur IS NOT NULL THEN 'MATERIEL'
ELSE 'SERVICES'
END AS type_fourn,
ff.id_facture_f, ff.date_reception, ff.date_echeance, DATEDIFF(CURDATE(), ff.date_echeance) AS jours_retard, ff.montant_du, COALESCE(SUM(pf.montant), 0) AS deja_paye, ff.montant_du - COALESCE(SUM(pf.montant), 0) AS reste_a_payer, ff.statut_paiement
FROM facture_fournisseur ff
JOIN contrat_fournisseur cf ON cf.id_contrat = ff.id_contrat
JOIN fournisseur f ON f.id_fournisseur = cf.id_fournisseur
LEFT JOIN fourn_materiel fm ON fm.id_fournisseur = f.id_fournisseur
LEFT JOIN paiement_fournisseur pf ON pf.id_facture_f = ff.id_facture_f
WHERE ff.statut_paiement != 'REGLE' AND ff.date_echeance < CURDATE()
GROUP BY ff.id_facture_f, f.nom_societe, f.contact_nom, f.tel_pro, fm.id_fournisseur, ff.date_reception, ff.date_echeance, ff.montant_du, ff.statut_paiement
ORDER BY jours_retard DESC;

# Ce SELECT a pour objectif d'avoir une liste de tous les employés selon les stations avec leur rôle (si ils sont des moniteurs ou non)
SELECT s.nom_station, emp.id_employe, emp.nom, emp.prenom,
CASE
WHEN m.id_employe IS NOT NULL THEN 'MONITEUR'
ELSE 'AUTRE'
END AS role_employe, m.num_diplome
FROM employe emp
JOIN station s ON s.id_station  = emp.id_station
LEFT JOIN moniteur m ON m.id_employe = emp.id_employe
ORDER BY s.nom_station, role_employe, emp.nom;

# Ce SELECT a pour objectif de connaître la charge de travail des moniteurs, c'est-à-dire le nombre de sessions animées ainsi que le nombre total d'inscrits
SELECT CONCAT(emp.prenom, ' ', emp.nom) AS moniteur, m.num_diplome, s.nom_station, COUNT(DISTINCT sc.id_session) AS nb_sessions_animees, SUM(sc.nb_places_restantes) AS places_encore_dispo, COUNT(rc.id_client) AS total_inscrits
FROM moniteur m
JOIN employe emp ON emp.id_employe = m.id_employe
JOIN station s ON s.id_station = emp.id_station
LEFT JOIN session_cours sc ON sc.id_employe = m.id_employe
LEFT JOIN reservation_cours rc ON rc.id_session = sc.id_session
GROUP BY m.id_employe, emp.prenom, emp.nom, m.num_diplome, s.nom_station
ORDER BY total_inscrits DESC;

# Ce SELECT a pour objectif de connaître les équipements qui ne sont presque jamais loués dans le but de les réaffecter
SELECT e.id_equipement, e.type_mat, e.etat, e.prix_jour_base, s.nom_station
FROM equipement e
JOIN station s ON s.id_station = e.id_station
WHERE e.id_equipement NOT IN (SELECT DISTINCT id_equipement FROM ligne_reservation)
ORDER BY s.nom_station, e.type_mat;

## PARTIE 2 – VUES ##
# Cette VUE permet d'avoir un bilan des stocks de chaque station avec le type et l'état du matériel (utile pour les responsables des stocks)
CREATE OR REPLACE VIEW v_stock_equipement AS
SELECT s.id_station, s.nom_station, s.ville, e.type_mat, e.etat, COUNT(*) AS nb_total, SUM(e.disponibilite) AS nb_disponibles, COUNT(*) - SUM(e.disponibilite) AS nb_en_location, ROUND(SUM(e.disponibilite)/COUNT(*)*100, 1) AS taux_dispo_pct, ROUND(AVG(e.prix_jour_base), 2) AS prix_moyen_jour
FROM equipement e
JOIN station s ON s.id_station = e.id_station
GROUP BY s.id_station, s.nom_station, s.ville, e.type_mat, e.etat;

SELECT * FROM v_stock_equipement WHERE nb_disponibles = 0;
# comme ça on pourra savoir quels types de matériel sont épuisés dans quelle station 

# Cette VUE permet d'avoir une fiche station avec les équipements qu'il y a, les cours, les moniteurs ainsi que les fournisseurs
CREATE OR REPLACE VIEW v_fiche_station AS
SELECT s.id_station, s.nom_station, s.ville, s.altitude_m, COUNT(DISTINCT e.id_equipement) AS nb_equipements, SUM(e.disponibilite) AS equip_disponibles, COUNT(DISTINCT emp.id_employe) AS nb_employes, COUNT(DISTINCT m.id_employe) AS nb_moniteurs, COUNT(DISTINCT cf.id_contrat) AS nb_contrats_fournisseurs
FROM station s
LEFT JOIN equipement e ON e.id_station = s.id_station
LEFT JOIN employe emp ON emp.id_station = s.id_station
LEFT JOIN moniteur m  ON m.id_employe = emp.id_employe
LEFT JOIN contrat_fournisseur cf ON cf.id_station = s.id_station
AND (cf.date_fin IS NULL OR cf.date_fin >= CURDATE())
GROUP BY s.id_station, s.nom_station, s.ville, s.altitude_m;

SELECT * FROM v_fiche_station ORDER BY nb_equipements DESC;
# comme ça la direction peut consulter rapidement l'état des lieux des stations

# Cette VUE permet d'avoir un résumé des activités de chaque client 
CREATE OR REPLACE VIEW v_fiche_client AS
SELECT c.id_client, CONCAT(c.prenom, ' ', c.nom) AS client, c.email, c.telephone, TIMESTAMPDIFF(YEAR, c.date_naissance, CURDATE()) AS age, COUNT(DISTINCT r.id_resa_mat) AS nb_locations, COUNT(DISTINCT lr.id_ligne) AS nb_articles_loues, COALESCE(SUM(lr.prix_applique), 0) AS ca_locations, COUNT(DISTINCT rc.id_session) AS nb_cours_suivis, COUNT(DISTINCT sf.id_souscription) AS nb_forfaits
FROM client c
LEFT JOIN reservation_equipement r ON r.id_client = c.id_client
LEFT JOIN ligne_reservation lr ON lr.id_resa_mat = r.id_resa_mat
LEFT JOIN reservation_cours rc ON rc.id_client = c.id_client
LEFT JOIN souscription_forfait sf ON sf.id_client = c.id_client
GROUP BY c.id_client, c.prenom, c.nom, c.email, c.telephone, c.date_naissance;

SELECT * FROM v_fiche_client ORDER BY ca_locations DESC;
SELECT * FROM v_fiche_client WHERE nb_cours_suivis > 0;
# comme ça, on pourra utilisé ces informations dans le but de fidéliser les clients fidèles et d'avoir un meilleur service commercial

# Cette VUE permet d'avoir une liste des fournisseurs avec leur spécialisation et leurs contrats en cours selon chaque station
CREATE OR REPLACE VIEW v_fournisseurs_actifs AS
SELECT f.id_fournisseur, f.nom_societe, f.contact_nom, f.tel_pro,
CASE
WHEN fm.id_fournisseur IS NOT NULL THEN 'MATERIEL'
WHEN fs.id_fournisseur IS NOT NULL THEN 'SERVICES'
ELSE 'NON CLASSIFIE'
END AS type_fournisseur, fm.marques_proposees, fs.type_prestation, cf.id_contrat, cf.date_debut, cf.date_fin, st.nom_station
FROM fournisseur f
LEFT JOIN fourn_materiel fm ON fm.id_fournisseur = f.id_fournisseur
LEFT JOIN fourn_services fs ON fs.id_fournisseur = f.id_fournisseur
LEFT JOIN contrat_fournisseur cf ON cf.id_fournisseur = f.id_fournisseur
LEFT JOIN station st ON st.id_station = cf.id_station
WHERE cf.date_fin IS NULL OR cf.date_fin >= CURDATE();

SELECT * FROM v_fournisseurs_actifs WHERE type_fournisseur = 'SERVICES';
# comme ça, les services achats peuvent consulter d'un coup d'oeil les fourniseurs à contacter pour commander certains services

# Cette VUE permet de voir les locations en cours (ceux qui n'ont pas eu de retour)
CREATE OR REPLACE VIEW v_locations_en_cours AS
SELECT r.id_resa_mat, r.date_resa, CONCAT(c.prenom, ' ', c.nom) AS client, c.telephone, c.email, s.nom_station, e.type_mat, e.etat, lr.prix_applique, DATEDIFF(NOW(), r.date_resa) AS jours_en_cours
FROM reservation_equipement r
JOIN client c ON c.id_client = r.id_client
JOIN ligne_reservation lr ON lr.id_resa_mat = r.id_resa_mat
JOIN equipement e ON e.id_equipement = lr.id_equipement
JOIN station s ON s.id_station = e.id_station
WHERE lr.date_ret_reel IS NULL;

SELECT * FROM v_locations_en_cours WHERE jours_en_cours > 7;
# comme ça, on peut voir le matériel potentiellement en retard

# Cette VUE permet de voir les factures des clients qui restent impayées
CREATE OR REPLACE VIEW v_factures_clients_impayees AS
SELECT fc.id_facture_c, CONCAT(c.prenom, ' ', c.nom) AS client, c.email, c.telephone, fc.date_facture, DATEDIFF(CURDATE(), fc.date_facture) AS age_facture_jours, fc.total_ttc, fc.statut_paiement
FROM facture_client fc
JOIN client c ON c.id_client = fc.id_client
WHERE fc.statut_paiement != 'PAYE'
ORDER BY age_facture_jours DESC;

SELECT * FROM v_factures_clients_impayees WHERE age_facture_jours > 30;
# comme ça, on peut voir les clients qui n'ont pas payé leurs factures qui datent d'il y a plus de 30 jours et faire une relance 


## PARTIE 3 – TRIGGERS ##
# Trigger AFTER INSERT sur la ligne réservation des équipements (disponibilité de l'équipement après une réservation)
DELIMITER //
CREATE TRIGGER trg_indisponible_a_la_location
AFTER INSERT ON ligne_reservation
FOR EACH ROW
BEGIN
UPDATE equipement
SET disponibilite = FALSE
WHERE id_equipement = NEW.id_equipement;
END//
DELIMITER ;

# Trigger AFTER UPDATE sur la ligne réservation des équipements (pour les retours)
DELIMITER //
CREATE TRIGGER trg_retour_equipement
AFTER UPDATE ON ligne_reservation
FOR EACH ROW
BEGIN
IF NEW.date_ret_reel IS NOT NULL AND OLD.date_ret_reel IS NULL THEN
UPDATE equipement
SET disponibilite = TRUE
WHERE id_equipement = NEW.id_equipement;
END IF;
END //
DELIMITER ;

# Trigger AFTER INSERT sur la réservation des cours (pour décrémenter le nombre de places à chaque inscription)
DELIMITER //
CREATE TRIGGER trg_decrement_places_cours
AFTER INSERT ON reservation_cours
FOR EACH ROW
BEGIN
UPDATE session_cours
SET nb_places_restantes = nb_places_restantes - 1
WHERE id_session = NEW.id_session;
END//
DELIMITER ;

# Trigger AFTER DELETE sur la réservation des cours (pour rajouter le nombre de place après qu'une inscription est annulée)
DELIMITER //
CREATE TRIGGER trg_increment_places_suppression
AFTER DELETE ON reservation_cours
FOR EACH ROW
BEGIN
UPDATE session_cours
SET nb_places_restantes = nb_places_restantes + 1
WHERE id_session = OLD.id_session;
END//
DELIMITER ;

# Trigger AFTER INSERT sur le paiement des fournisseurs (pour mettre à jour le statut de paiement selon le cumul des paiements)
DELIMITER //
CREATE TRIGGER trg_statut_facture_fournisseur
AFTER INSERT ON paiement_fournisseur
FOR EACH ROW
BEGIN
DECLARE v_total_paye DECIMAL(10,2);
DECLARE v_montant_du DECIMAL(10,2);

SELECT SUM(montant) INTO v_total_paye
FROM paiement_fournisseur
WHERE id_facture_f = NEW.id_facture_f;

SELECT montant_du INTO v_montant_du
FROM facture_fournisseur
WHERE id_facture_f = NEW.id_facture_f;

IF v_total_paye >= v_montant_du THEN
UPDATE facture_fournisseur
SET statut_paiement = 'REGLE'
WHERE id_facture_f = NEW.id_facture_f;
ELSE
UPDATE facture_fournisseur
SET statut_paiement = 'EN_COURS'
WHERE id_facture_f = NEW.id_facture_f;
END IF;
END//
DELIMITER ;

# Trigger AFTER INSERT sur le paiement des clients (permet de passer le statut de paiement à PAYÉ quand le paiement est enregistré)
DELIMITER //
CREATE TRIGGER trg_statut_facture_client
AFTER INSERT ON paiement_client
FOR EACH ROW
BEGIN
UPDATE facture_client
SET statut_paiement = 'PAYE'
WHERE id_facture_c = NEW.id_facture_c;
END//
DELIMITER ;


## PARTIE 4 – PROCÉDURES STOCKÉES ##
# Cette procédure permet de vérifier la disponibilité des équipements avant de créer une réservation pour un client
DELIMITER // 
CREATE PROCEDURE sp_reserver_equipement(IN p_id_client INT, IN p_id_equipement INT, OUT p_id_resa INT, OUT p_message VARCHAR(255))
BEGIN
DECLARE v_dispo  BOOLEAN;
DECLARE v_etat   VARCHAR(20);
DECLARE v_prix   DECIMAL(10,2); 
SET p_id_resa = NULL;
# ici, on va récupérer dans la base de données la disponibilité et le prix de l'équipement
SELECT disponibilite, etat, prix_jour_base
INTO v_dispo, v_etat, v_prix
FROM equipement
WHERE id_equipement = p_id_equipement;
IF v_dispo IS NULL THEN
SET p_message = 'ERREUR : équipement introuvable.';
ELSEIF v_dispo = FALSE OR v_etat = 'HORS_SERVICE' THEN
SET p_message = 'ERREUR : équipement non disponible ou hors service.';
ELSE
# ici, on crée la réservation 
INSERT INTO reservation_equipement (id_client, date_resa)
VALUES (p_id_client, NOW());
SET p_id_resa = LAST_INSERT_ID();
# ici, on crée la ligne 
INSERT INTO ligne_reservation (id_resa_mat, id_equipement, prix_applique)
VALUES (p_id_resa, p_id_equipement, v_prix);
SET p_message = CONCAT('OK : réservation #', p_id_resa,' créée. Prix/jour appliqué : ', v_prix, ' EUR.');
END IF;
END //
DELIMITER ;
 
# APPEL DE LA PROCÉDURE :
CALL sp_reserver_equipement(2, 5, @id_resa, @msg);
SELECT @id_resa, @msg;
 
# Cette procédure permet d'enregistrer le retour d'un équipement avec un message si toutes les lignes de réservation sont rendues  
DELIMITER //
CREATE PROCEDURE sp_restituer_equipement(IN  p_id_ligne INT, OUT p_message  VARCHAR(255))
BEGIN
DECLARE v_id_resa    INT;
DECLARE v_non_rendus INT;
# ici, on va récupérer la réservation parente
SELECT id_resa_mat INTO v_id_resa
FROM ligne_reservation
WHERE id_ligne = p_id_ligne;
IF v_id_resa IS NULL THEN
SET p_message = 'ERREUR : ligne de réservation introuvable.';
ELSE
# ici, on enregistre le retour       
UPDATE ligne_reservation
SET date_ret_reel = NOW()
WHERE id_ligne = p_id_ligne;
# ici, on vérifie si les lignes sont encore ouvertes sur cette réservation 
SELECT COUNT(*) INTO v_non_rendus
FROM ligne_reservation
WHERE id_resa_mat   = v_id_resa
AND date_ret_reel IS NULL; 
IF v_non_rendus = 0 THEN
SET p_message = CONCAT('OK : retour enregistré. Réservation #',v_id_resa, ' entièrement clôturée.');
ELSE
SET p_message = CONCAT('OK : retour enregistré. ', v_non_rendus,' équipement(s) encore en cours sur réservation #',v_id_resa, '.');
END IF;
END IF;
END //
DELIMITER ;
 
# APPEL DE LA PROCÉDURE :
CALL sp_restituer_equipement(3, @msg);
SELECT @msg;
 
# Cette procédure vérifie qu'un client n'est pas déjà inscrit à la session de cours et qu'il reste des places avant l'inscription 
DELIMITER //
CREATE PROCEDURE sp_inscrire_cours(IN  p_id_client  INT, IN  p_id_session INT, OUT p_message    VARCHAR(255))
BEGIN
DECLARE v_places     INT;
DECLARE v_deja_inscr INT;
#ici, on va vérifier si le client est déjà inscrit 
SELECT COUNT(*) INTO v_deja_inscr
FROM reservation_cours
WHERE id_client = p_id_client AND id_session = p_id_session; 
IF v_deja_inscr > 0 THEN
SET p_message = 'ERREUR : le client est déjà inscrit à cette session.';
#on va récupérer des places restantes
ELSE
SELECT nb_places_restantes INTO v_places
FROM session_cours
WHERE id_session = p_id_session;
IF v_places IS NULL THEN
SET p_message = 'ERREUR : session introuvable.';
ELSEIF v_places <= 0 THEN
SET p_message = 'ERREUR : plus de places disponibles dans cette session.';
ELSE
INSERT INTO reservation_cours (id_client, id_session, date_inscription)
VALUES (p_id_client, p_id_session, NOW());
SET p_message = CONCAT('OK : inscription confirmée. Places restantes : ', v_places - 1, '.');
END IF;
END IF;
END // 
DELIMITER ;
 
# APPEL DE LA PROCÉDURE :
CALL sp_inscrire_cours(4, 2, @msg);
SELECT @msg;
 
# Cette procédure permet d'annuler l'inscription d'un client à une session
DELIMITER //
CREATE PROCEDURE sp_annuler_inscription_cours(IN  p_id_client  INT, IN p_id_session INT, OUT p_message VARCHAR(255))
BEGIN
DECLARE v_existe INT;
# ici, on vérifie si l'inscription existe 
SELECT COUNT(*) INTO v_existe
FROM reservation_cours
WHERE id_client  = p_id_client AND id_session = p_id_session;
IF v_existe = 0 THEN SET p_message = 'ERREUR : aucune inscription trouvée pour ce client/session.';
#ici, on va supprimer l'inscription du client
ELSE
DELETE FROM reservation_cours WHERE id_client  = p_id_client AND id_session = p_id_session;
SET p_message = CONCAT('OK : inscription du client #', p_id_client, ' à la session #', p_id_session, ' annulée.');
END IF;
END // 
DELIMITER ;
 
# APPEL DE LA PROCÉDURE :
CALL sp_annuler_inscription_cours(4, 2, @msg);
SELECT @msg;
 
# Cette procédure a pour but de créer une facture client en calculant le total de ses locations qui sont enregistrées dans les lignes réservations
DELIMITER // 
CREATE PROCEDURE sp_creer_facture_client(IN  p_id_client  INT, OUT p_id_facture INT, OUT p_message VARCHAR(255))
BEGIN
DECLARE v_total DECIMAL(10,2);
SET p_id_facture = NULL;
# ici, on calcule le total des locations d'un client
SELECT COALESCE(SUM(lr.prix_applique), 0) INTO v_total
FROM ligne_reservation lr
JOIN reservation_equipement r ON r.id_resa_mat = lr.id_resa_mat
WHERE r.id_client = p_id_client;
IF v_total = 0 THEN 
SET p_message = 'ERREUR : aucune location trouvée pour ce client.';
ELSE
INSERT INTO facture_client (id_client, date_facture, total_ttc, statut_paiement)
VALUES (p_id_client, CURDATE(), v_total, 'NON_PAYE');
SET p_id_facture = LAST_INSERT_ID();
SET p_message = CONCAT('OK : facture #', p_id_facture, ' créée pour un montant de ', v_total, ' euros.');
END IF;
END // 
DELIMITER ;
 
# APPEL DE LA PROCÉDURE :
CALL sp_creer_facture_client(1, @id_f, @msg);
SELECT @id_f, @msg;
 

## PARTIE 5 – FONCTIONS ##
# Cette fonction a pour but de retourner l'âge exact en années d'un client, utiles pour la réutilisée dans les procédures de tarification
DELIMITER //
CREATE FUNCTION fn_age_client(p_id_client INT)
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
DECLARE v_age INT;
SELECT TIMESTAMPDIFF(YEAR, date_naissance, CURDATE())
INTO v_age
FROM client WHERE id_client = p_id_client;
RETURN v_age;
END//
DELIMITER ;

SELECT nom, prenom, fn_age_client(id_client) AS age FROM client;
# Ce SELECT permet de savoir l'âge de chaque client
SELECT * FROM client WHERE fn_age_client(id_client) < 35;
# Et celui-ci, tous les informations des clients qui ont un âge inférieur à 35 ans.


# Cette fonction a pour but de retourner le nombre d'équipements disponibles dans une station pour un type donné. Elle permet de vérifier le stock en temps réel
DELIMITER //
CREATE FUNCTION fn_nb_equip_disponibles(p_id_station INT,p_type_mat   VARCHAR(50))
RETURNS INT
READS SQL DATA
DETERMINISTIC
BEGIN
DECLARE v_nb INT;
SELECT COUNT(*) INTO v_nb
FROM equipement
WHERE id_station = p_id_station AND type_mat      LIKE CONCAT('%', p_type_mat, '%') AND disponibilite = TRUE AND etat != 'HORS_SERVICE';
RETURN v_nb;
END//
DELIMITER ;

SELECT fn_nb_equip_disponibles(1, 'Ski') AS skis_dispos_station1;
# Avec ce SELECT, on fait appel à la fonction pour vérifier le nombre d'équipements disponibles pour les équipements type ski


# Cette fonction a pour but de retourner le chiffre d'affaire généré par un client sur ses locations. Elle peut être utilisée pour le classement de fidélités
DELIMITER //
CREATE FUNCTION fn_ca_client(p_id_client INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
DECLARE v_ca DECIMAL(10,2);
SELECT COALESCE(SUM(lr.prix_applique), 0)
INTO v_ca
FROM ligne_reservation lr
JOIN reservation_equipement r ON r.id_resa_mat = lr.id_resa_mat
WHERE r.id_client = p_id_client;
RETURN v_ca;
END//
DELIMITER ;

SELECT nom, prenom, fn_ca_client(id_client) AS ca_total
FROM client ORDER BY ca_total DESC;
#Ce SELECT va permettre de voir rapidement le chiffre d'affaire généré par chaque client, affiché par odre décroissant (le client le plus qui a dépensé)


# Cette fonction a pour but de retourner le montant total dû à un fournisseur sur toutes ses factures non règlées 
DELIMITER //
CREATE FUNCTION fn_montant_du_fournisseur(p_id_fournisseur INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
DECLARE v_total DECIMAL(10,2);
SELECT COALESCE(SUM(ff.montant_du), 0) INTO v_total
FROM facture_fournisseur ff
JOIN contrat_fournisseur cf ON cf.id_contrat = ff.id_contrat
WHERE cf.id_fournisseur = p_id_fournisseur
AND ff.statut_paiement != 'REGLE';
RETURN v_total;
END//
DELIMITER ;

SELECT nom_societe, fn_montant_du_fournisseur(id_fournisseur) AS montant_restant_du
FROM fournisseur ORDER BY montant_restant_du DESC;
# Ce SELECT fait appel à la fonction pour consulter le montant restant à payer pour chaque fournisseur

# Cette fonction a pour objectif de retourner le nom de la station qui a généré le plus gros chiffre d'affaires sur les locations 
DELIMITER //
CREATE FUNCTION fn_station_la_plus_active()
RETURNS VARCHAR(100)
READS SQL DATA
DETERMINISTIC
BEGIN
DECLARE v_nom VARCHAR(100);
SELECT s.nom_station INTO v_nom
FROM ligne_reservation lr
JOIN reservation_equipement r ON r.id_resa_mat   = lr.id_resa_mat
JOIN equipement e ON e.id_equipement = lr.id_equipement
JOIN station s ON s.id_station = e.id_station
GROUP BY s.id_station, s.nom_station
ORDER BY SUM(lr.prix_applique) DESC
LIMIT 1;
RETURN v_nom;
END //
DELIMITER ;

SELECT fn_station_la_plus_active() AS meilleure_station;
# Ce SELECT permet de voir grâce à la fonction la meilleur station (celle qui a le plus gros chiffre d'affaire)
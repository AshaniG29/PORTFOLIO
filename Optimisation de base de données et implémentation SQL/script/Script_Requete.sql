-- =========================
-- Question 3 - Requête Trésoriers + Organisateurs
-- =========================
USE afihm;

-- R1 : Nombre de repas de gala par régime et allergies, pour une conférence donnée (pour les organisateurs)--
SELECT c.code AS conference, ins.regime, ins.allergies, SUM(pe.quantite)AS nb_repas
FROM participation_evt pe
JOIN evenement e ON e.evt_id = pe.evt_id
JOIN inscription ins ON ins.inscr_id = pe.inscr_id
JOIN conference c ON c.conf_id = ins.conf_id
WHERE c.code = 'IHM2025' AND e.type = 'gala'         
GROUP BY c.code, ins.regime, ins.allergies
ORDER BY nb_repas DESC;

-- R2 : Montant total des cotisations versées par année d’adhésion (pour les trésoriers) --
SELECT YEAR(a.debut) AS annee_adhesion,SUM(lf.qte * (lf.prix_unitaire_ttc - lf.reduction_ttc)) AS total_cotisations
FROM adhesion a
JOIN ligne_facture lf ON lf.adhesion_id = a.adhesion_id
JOIN facture f ON f.facture_id = lf.facture_id
WHERE f.facture_id IN (
    SELECT DISTINCT facture_id FROM paiement)
GROUP BY YEAR(a.debut)
ORDER BY annee_adhesion;

-- R3 : Montant total des inscriptions par conférence et par année (pour les organisateurs)
SELECT c.code AS conference,YEAR(c.date_debut) AS annee_conference,SUM(lf.qte * (lf.prix_unitaire_ttc - lf.reduction_ttc)) AS montant_inscriptions
FROM ligne_facture lf
JOIN inscription ins ON ins.inscr_id = lf.inscr_id
JOIN conference c ON c.conf_id   = ins.conf_id
JOIN facture f ON f.facture_id = lf.facture_id
WHERE f.facture_id IN (
    SELECT DISTINCT facture_id 
    FROM paiement)
GROUP BY c.code, YEAR(c.date_debut)
ORDER BY annee_conference, conference;


-- R4 : Utilisation des coupons (combien de fois, pour quel montant) (pour les organisateurs)--
SELECT c.coupon_code,c.libelle,COUNT(ins.inscr_id)AS nb_utilisations,SUM(ins.montant_calcule) AS total_montant_inscriptions
FROM coupon c
LEFT JOIN inscription ins ON ins.coupon_code = c.coupon_code
GROUP BY c.coupon_code, c.libelle
ORDER BY nb_utilisations DESC, c.coupon_code;

-- R5 : La liste des participants à chaque atelier (pour la logistique --
SELECT a.atelier_id,a.theme,a.creneau,p.personne_id,p.nom,p.prenom,pe.quantite
FROM atelier a
JOIN evenement e ON e.evt_id = a.evt_id
JOIN participation_evt pe ON pe.evt_id = e.evt_id
JOIN inscription ins ON ins.inscr_id = pe.inscr_id
JOIN personne p ON p.personne_id = ins.personne_id
JOIN conference c ON c.conf_id = e.conf_id
WHERE c.code = 'IHM2025'
ORDER BY a.atelier_id, p.nom, p.prenom;
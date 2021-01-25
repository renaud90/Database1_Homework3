-- Normalitsation de la base de données entreprise_tp4 et interrogation de la BD
-- Travail par Renaud Lussier
USE entreprise_tp4;

-- Transaction pour la création d'une nouvelle table "titre_emp" et la modification des données de la table "titre"
BEGIN;

-- Changement du nom de la table titre qui sera remplacée
ALTER TABLE titre
RENAME TO titre_temp;
    
-- Création de la nouvelle table titre
CREATE TABLE IF NOT EXISTS titre(
	id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificateur unique',
    nom VARCHAR(255) UNIQUE NOT NULL COMMENT 'Nom unique de chaque affectation'
) COMMENT 'Table contenant seulement les noms uniques de chaque affectation';

-- Insertion des données dans la table title
INSERT INTO titre(
	nom)
SELECT DISTINCT titre
FROM titre_temp;

-- Création d'une table de correspondance entre les table "employe" et "titre"
CREATE TABLE IF NOT EXISTS titre_emp(
	id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'Identificateur unique',
    id_emp INT NOT NULL COMMENT 'Référence à la table employe',
    FOREIGN KEY(id_emp) REFERENCES employe(id),
    id_titre INT UNSIGNED NOT NULL COMMENT 'Référence à la table titre',
    FOREIGN KEY(id_titre) REFERENCES titre(id),
    date_debut DATE NOT NULL COMMENT 'Date d\'attribution du titre',
    date_fin DATE COMMENT 'Date de fin de la fonction, NULL si toujours en fonction',
    UNIQUE(id_emp, id_titre, date_debut)
) COMMENT 'Table d\'association entre un employé et le poste occupé';

-- Insertion des données dans la table titre_emp à partir des tables "employe" et "titre"
INSERT INTO titre_emp(
	id_emp, id_titre, date_debut, date_fin)
SELECT
	employe.id, titre.id, date_debut, date_fin
FROM titre_temp
JOIN titre ON titre_temp.titre = titre.nom
JOIN employe ON titre_temp.no_emp = employe.no_emp
;

-- Effacement de la table titre_temp qui est devenue inutile, ses données ayant été distribuées dans d'autres tables
DROP TABLE titre_temp;

-- Fin de la transaction
COMMIT;

-- Transaction pour la francisation des tables 
BEGIN;

-- Francisation de la table "titre" avec des UPDATE 
UPDATE titre
SET 
	nom = 'Ingénieur sénior'
WHERE
	id = 1;
UPDATE titre
SET 
	nom = 'Employé'
WHERE
	id = 2;
UPDATE titre
SET 
	nom = 'Ingénieur'
WHERE
	id = 3;
UPDATE titre
SET 
	nom = 'Employé sénior'
WHERE
	id = 4;
UPDATE titre
SET 
	nom = 'Assistant ingénieur'
WHERE
	id = 5;
UPDATE titre
SET 
	nom = 'Chef technique'
WHERE
	id = 6;
UPDATE titre
SET 
	nom = 'Gestionnaire'
WHERE
	id = 7;
    
-- Francisation de la table "departement" avec des UPDATE 
UPDATE departement
SET 
	nom_dept = 'Ressources humaines'
WHERE
	id = 3;
UPDATE departement
SET 
	nom_dept = 'Développement'
WHERE
	id = 5;
UPDATE departement
SET 
	nom_dept = 'Contrôle qualité'
WHERE
	id = 6;
UPDATE departement
SET 
	nom_dept = 'Ventes'
WHERE
	id = 7;
UPDATE departement
SET 
	nom_dept = 'Recherche'
WHERE
	id = 8;
UPDATE departement
SET 
	nom_dept = 'Service à la clientèle'
WHERE
	id = 9;
    
-- Fin de la transaction
COMMIT;

-- Ajout de clés étrangères valides à l'aide des id plutôt que le no_emp et no_dept
-- Transaction pour la table gest_dept
BEGIN;

-- On enlève les contraintes de clé étrangères pour cette portion du travail
SET foreign_key_checks = 0;

-- Ajout des colonnes de clés étrangères
ALTER TABLE gest_dept
ADD id_employe INT NOT NULL COMMENT 'Référence à une entrée de la table "employe"',
ADD FOREIGN KEY(id_employe) REFERENCES employe(id),
ADD id_dept INT NOT NULL COMMENT 'Référence à une entrée de la table "departement"',
ADD FOREIGN KEY(id_dept) REFERENCES departement(id);

-- Ajout des données dans les colonnes id_employe et id_dept
UPDATE gest_dept
JOIN employe ON gest_dept.no_emp = employe.no_emp
SET id_employe = employe.id;

UPDATE gest_dept
JOIN departement ON gest_dept.no_dept = departement.no_dept
SET id_dept = departement.id;

-- Ajout d'une clé unique composite
ALTER TABLE gest_dept
ADD UNIQUE(id_employe, id_dept, date_debut);

-- On efface les colonne np_emp et no_dept qui sont maintenant inutile et les contraintes qui leur sont rattachées
ALTER TABLE gest_dept
DROP CONSTRAINT fk_ges_no_emp,
DROP CONSTRAINT fk_ges_no_dept,
DROP no_emp,
DROP no_dept;

-- On remet les contraintes de clé étrangères
SET foreign_key_checks = 1;

-- Fin de la transaction
COMMIT;

-- Transaction pour la table dept_emp
BEGIN;

-- On enlève les contraintes de clé étrangères pour cette portion du travail
SET foreign_key_checks = 0;

-- Ajout des colonnes de clés étrangères
ALTER TABLE dept_emp
ADD id_employe INT NOT NULL COMMENT 'Référence à une entrée de la table "employe"',
ADD FOREIGN KEY(id_employe) REFERENCES employe(id),
ADD id_dept INT NOT NULL COMMENT 'Référence à une entrée de la table "departement"',
ADD FOREIGN KEY(id_dept) REFERENCES departement(id);

-- Ajout des données dans les colonnes id_employe et id_dept
UPDATE dept_emp
JOIN employe ON dept_emp.no_emp = employe.no_emp
SET id_employe = employe.id;

UPDATE dept_emp
JOIN departement ON dept_emp.no_dept = departement.no_dept
SET id_dept = departement.id;

-- Ajout d'une clé unique composite
ALTER TABLE dept_emp
ADD UNIQUE(id_employe, id_dept, date_debut);

-- On efface les colonne np_emp et no_dept qui sont maintenant inutile et les contraintes qui leur sont rattachées
ALTER TABLE dept_emp
DROP CONSTRAINT fk_dee_no_emp,
DROP CONSTRAINT fk_dee_no_dept,
DROP no_emp,
DROP no_dept;

-- On remet les contraintes de clé étrangères
SET foreign_key_checks = 1;

-- Fin de la transaction
COMMIT;

-- Transaction pour la modification des données de la table "salaire"
BEGIN;

-- On enlève les contraintes de clé étrangères pour cette portion du travail
SET foreign_key_checks = 0;

-- TABLE SALAIRE
-- Ajout de la colonne id_employe et changement du nom de la colonne "salaire" pour "montant" pour éviter que la table et une de ses colonne possède le même nom
ALTER TABLE salaire
RENAME COLUMN salaire TO montant,
ADD id_employe INT NOT NULL COMMENT 'Référence à une entrée de la table "employe"',
ADD FOREIGN KEY(id_employe) REFERENCES employe(id);

-- Ajout des données dans la colonne id_employe
UPDATE salaire
JOIN employe ON salaire.no_emp = employe.no_emp
SET id_employe = employe.id;

-- Ajout d'une clé unique composite
ALTER TABLE salaire
ADD UNIQUE(id_employe, date_debut);

-- On efface la colonne no_emp et la contrainte associée qui sont devenues inutiles
ALTER TABLE salaire
DROP CONSTRAINT fk_sal_no_emp,
DROP no_emp;

-- On remet les contraintes de clé étrangères
SET foreign_key_checks = 1;

-- Fin de la transaction
COMMIT;

-- Transaction pour l\'ajout des index
BEGIN;

-- Table dept_emp
-- Indexation des clés étrangères et des dates pour la rapidité des recherches
ALTER TABLE dept_emp
ADD INDEX(id_employe),
ADD INDEX(id_dept),
ADD INDEX(date_debut),
ADD INDEX(date_fin);

-- Table gest_dept
-- Indexation des clés étrangères et des dates pour la rapidité des recherches
ALTER TABLE gest_dept
ADD INDEX(id_employe),
ADD INDEX(id_dept),
ADD INDEX(date_debut),
ADD INDEX(date_fin);

-- Table employe
-- Indexation de la date d'embauche pour la rapidité des recherches
ALTER TABLE employe
ADD INDEX(date_embauche);

-- Table salaire
-- Indexation de la clé étrangère
ALTER TABLE salaire
ADD INDEX(id_employe);

-- Table titre_emp
-- Indexation des clés étrangères et des dates pour la rapidité des recherches
ALTER TABLE titre_emp
ADD INDEX(id_emp),
ADD INDEX(id_titre),
ADD INDEX(date_debut),
ADD INDEX(date_fin);

-- Fin de la transaction
COMMIT;

-- Ajout des commentaire sur toutes les tables dans lesquelles il en manque
ALTER TABLE departement 
	COMMENT 'Liste des départements uniques de l\'entreprise',
	MODIFY id INT AUTO_INCREMENT COMMENT 'Identificateur unique',
    MODIFY no_dept CHAR(4) NOT NULL COMMENT 'Numéro de département à 4 caractères unique',
    MODIFY nom_dept VARCHAR(50) NOT NULL COMMENT 'Nom de département unique';
    
ALTER TABLE dept_emp
	COMMENT 'Table d\'association entre departement et employe. Contient les dates d\'affectation',
    MODIFY id INT AUTO_INCREMENT COMMENT 'Identificateur unique',
    MODIFY date_debut DATE NOT NULL COMMENT 'Date de début dans le département, obligatoire',
    MODIFY date_fin DATE COMMENT 'Date de fin dans le département, NULL si encore au sein du département';
    
ALTER TABLE gest_dept
	COMMENT 'Table d\'association entre departement et employe. Contient les dates d\'affectation dans les postes de gestion de département',
    MODIFY id INT AUTO_INCREMENT COMMENT 'Identificateur unique',
    MODIFY date_debut DATE NOT NULL COMMENT 'Date de début de gestion du département, obligatoire',
    MODIFY date_fin DATE COMMENT 'Date de fin dans gestion du département, NULL si encore respansable';
    
ALTER TABLE employe
	COMMENT 'Table contenant les informations personnelles de chaque employé.',
    MODIFY id INT AUTO_INCREMENT COMMENT 'Identificateur unique',
    MODIFY no_emp INT NOT NULL COMMENT 'Numéro d\'employé unique',
    MODIFY date_naissance DATE NOT NULL COMMENT 'Date de naissance de l\'employé',
    MODIFY prenom VARCHAR(50) NOT NULL COMMENT 'Prénom de l\'employé',
    MODIFY nom_famille VARCHAR(50) NOT NULL COMMENT 'Nom de famille de l\'employé',
    MODIFY sexe ENUM('M','F') NOT NULL COMMENT 'Sexe de l\'employé, "M" ou "F"',
    MODIFY date_embauche DATE NOT NULL COMMENT 'Date d\'embauche de l\'employé';
    
ALTER TABLE salaire
	COMMENT 'Contien l\'historique salariale de chaque employé de l\'entreprise',
    MODIFY id INT AUTO_INCREMENT COMMENT 'Identificateur unique',
    MODIFY montant FLOAT NOT NULL COMMENT 'Montant du salaire annuel',
    MODIFY date_debut DATE NOT NULL COMMENT 'Date de début d\'entrée en vigueur du salaire , obligatoire',
    MODIFY date_fin DATE COMMENT 'Date de fin du versement du salaire, NULL si encore respansable';
    
-- Transaction pour remplacer les dates 9999-01-01 par des valeurs NULL
BEGIN;

-- Changement pour la table salaire
UPDATE salaire
SET date_fin = NULL
WHERE date_fin = '9999-01-01';

UPDATE dept_emp
SET date_fin = NULL
WHERE date_fin = '9999-01-01';

UPDATE gest_dept
SET date_fin = NULL
WHERE date_fin = '9999-01-01';

UPDATE titre_emp
SET date_fin = NULL
WHERE date_fin = '9999-01-01';

-- Fin de la transaction
COMMIT;


-- INTERROGATION DE LA BASE DE DONNÉES

-- Différence entre le salaire moyen actuel des homme et des femmes du département production
SELECT
	MAX(moyenneHF.moyenne) - MIN(moyenneHF.moyenne) AS 'Différence de moyenne salariale homme-femme du département de production ($)'
FROM
(
-- Cette sous-requête calcule le salaire moyen des hommes et des femmes du département de production séparémment
SELECT 
	ROUND(AVG(salaire.montant)) AS moyenne
FROM 
	employe
JOIN salaire ON employe.id = salaire.id_employe
JOIN dept_emp ON employe.id = dept_emp.id_employe
WHERE 
	-- Employés actuels
	salaire.date_fin IS NULL
    AND
    -- Sélection de l'id associée au départment de production
	dept_emp.id_dept = (
		SELECT DISTINCT departement.id
        FROM departement
        JOIN dept_emp ON departement.id = dept_emp.id_dept
        WHERE departement.nom_dept = 'Production'
    )
GROUP BY employe.sexe
) AS moyenneHF
;

-- Employés ayant été gestionnaires sans être gestionnaires de département
SELECT 
	prenom, nom_famille, titre.nom AS 'Titre'
FROM 
	employe
JOIN titre_emp ON employe.id = titre_emp.id_emp
JOIN titre ON titre_emp.id_titre = titre.id
-- Le LEFT JOIN permet d'afficher les les gestionnaires qui ne se retouvent pas dans la table gest_dept
LEFT JOIN gest_dept ON employe.id = gest_dept.id_employe 
WHERE
	-- On cherches les gestionnaires
	titre.nom = 'Gestionnaire'
    AND
    -- Qui n'ont jamais été gestionnaires de département
    gest_dept.id_employe IS NULL;
    
-- Âge moyen des gestionnaires actuels de département par sexe
SELECT
	-- DATEDIFF donne la différence en jours, division par 365 pour l'avoir en années
	sexe, ROUND(AVG(DATEDIFF(NOW(), date_naissance) / 365)) AS 'Âge moyen'
FROM
	employe
JOIN gest_dept ON employe.id = gest_dept.id_employe
WHERE 
	-- Gestionnaires actuels
	gest_dept.date_fin IS NULL
GROUP BY sexe;

-- Nom d'employé ayant "ingénieur" dans leur titre par département
SELECT
	-- Le nom d'employé par département sera compté par le nombre de fois que le nom du départmene se trouve dans la requête
	departement.nom_dept AS 'Département', COUNT(departement.nom_dept) AS 'Nombre d\'ingénieurs'
FROM employe
JOIN dept_emp ON employe.id = dept_emp.id_employe
JOIN departement ON dept_emp.id_dept = departement.id 
JOIN titre_emp ON employe.id = titre_emp.id_emp
JOIN titre ON titre_emp.id_titre = titre.id
WHERE 
	-- Recher du mot Ingénieur de la titre
	titre.nom LIKE '%Ingénieur%'
	AND
    -- Employés actuels
    dept_emp.date_fin IS NULL
GROUP BY departement.nom_dept;


-- Employés actuel n'ayant jamais travaillé dans le département de production
SELECT
	COUNT(*) AS 'Nombre d\'employé actual n\'ayant jamais travaillé dans le département de production'
FROM
	employe
JOIN dept_emp ON employe.id = dept_emp.id_employe
JOIN departement ON dept_emp.id_dept = departement.id
WHERE 
    -- Sélectionne tous les id d'employés associés au départment de production pour les exclure de la requête principale 
    employe.id NOT IN(
		SELECT 
			id_employe
		FROM 
			dept_emp
		JOIN departement ON dept_emp.id_dept = departement.id
        WHERE departement.nom_dept = 'Production'
    )
    AND
    -- Sélectionne les employés actuels
    dept_emp.date_fin IS NULL;
    

    
   




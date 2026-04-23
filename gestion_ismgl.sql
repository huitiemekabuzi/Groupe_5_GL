-- ============================================
-- BASE DE DONNÉES: ISMGL - Gestion Universitaire
-- Auteur: Expert Flutter/PHP/MySQL
-- Date: 2024
-- ============================================

CREATE DATABASE IF NOT EXISTS ismgl_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ismgl_db;

-- ============================================
-- 1. TABLE DES RÔLES
-- ============================================
CREATE TABLE roles (
    id_role INT PRIMARY KEY AUTO_INCREMENT,
    nom_role VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_nom_role (nom_role),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 2. TABLE DES PERMISSIONS
-- ============================================
CREATE TABLE permissions (
    id_permission INT PRIMARY KEY AUTO_INCREMENT,
    nom_permission VARCHAR(100) UNIQUE NOT NULL,
    code_permission VARCHAR(50) UNIQUE NOT NULL,
    module VARCHAR(50) NOT NULL,
    description TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code_permission),
    INDEX idx_module (module)
) ENGINE=InnoDB;

-- ============================================
-- 3. TABLE RELATION RÔLES-PERMISSIONS
-- ============================================
CREATE TABLE role_permissions (
    id_role_permission INT PRIMARY KEY AUTO_INCREMENT,
    id_role INT NOT NULL,
    id_permission INT NOT NULL,
    date_attribution TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_role) REFERENCES roles(id_role) ON DELETE CASCADE,
    FOREIGN KEY (id_permission) REFERENCES permissions(id_permission) ON DELETE CASCADE,
    UNIQUE KEY unique_role_permission (id_role, id_permission),
    INDEX idx_role (id_role),
    INDEX idx_permission (id_permission)
) ENGINE=InnoDB;

-- ============================================
-- 4. TABLE DES UTILISATEURS
-- ============================================
CREATE TABLE users (
    id_user INT PRIMARY KEY AUTO_INCREMENT,
    matricule VARCHAR(20) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telephone VARCHAR(20),
    mot_de_passe VARCHAR(255) NOT NULL,
    id_role INT NOT NULL,
    photo_profil VARCHAR(255),
    est_actif BOOLEAN DEFAULT TRUE,
    derniere_connexion DATETIME,
    token_reset VARCHAR(100),
    token_expiration DATETIME,
    tentatives_connexion INT DEFAULT 0,
    compte_bloque BOOLEAN DEFAULT FALSE,
    date_blocage DATETIME,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_role) REFERENCES roles(id_role),
    INDEX idx_matricule (matricule),
    INDEX idx_email (email),
    INDEX idx_role (id_role),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 5. TABLE DES SESSIONS
-- ============================================
CREATE TABLE sessions (
    id_session INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    date_debut DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_expiration DATETIME NOT NULL,
    est_actif BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_user (id_user),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 6. TABLE DES FACULTÉS
-- ============================================
CREATE TABLE facultes (
    id_faculte INT PRIMARY KEY AUTO_INCREMENT,
    code_faculte VARCHAR(10) UNIQUE NOT NULL,
    nom_faculte VARCHAR(200) NOT NULL,
    description TEXT,
    doyen VARCHAR(100),
    email VARCHAR(150),
    telephone VARCHAR(20),
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code_faculte),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 7. TABLE DES DÉPARTEMENTS
-- ============================================
CREATE TABLE departements (
    id_departement INT PRIMARY KEY AUTO_INCREMENT,
    code_departement VARCHAR(10) UNIQUE NOT NULL,
    nom_departement VARCHAR(200) NOT NULL,
    id_faculte INT NOT NULL,
    chef_departement VARCHAR(100),
    email VARCHAR(150),
    telephone VARCHAR(20),
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_faculte) REFERENCES facultes(id_faculte),
    INDEX idx_code (code_departement),
    INDEX idx_faculte (id_faculte),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 8. TABLE DES FILIÈRES
-- ============================================
CREATE TABLE filieres (
    id_filiere INT PRIMARY KEY AUTO_INCREMENT,
    code_filiere VARCHAR(10) UNIQUE NOT NULL,
    nom_filiere VARCHAR(200) NOT NULL,
    id_departement INT NOT NULL,
    diplome_delivre VARCHAR(100),
    duree_etudes INT NOT NULL COMMENT 'Durée en années',
    description TEXT,
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_departement) REFERENCES departements(id_departement),
    INDEX idx_code (code_filiere),
    INDEX idx_departement (id_departement),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 9. TABLE DES NIVEAUX
-- ============================================
CREATE TABLE niveaux (
    id_niveau INT PRIMARY KEY AUTO_INCREMENT,
    code_niveau VARCHAR(10) UNIQUE NOT NULL,
    nom_niveau VARCHAR(100) NOT NULL COMMENT 'L1, L2, L3, M1, M2, etc.',
    ordre INT NOT NULL,
    description TEXT,
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code_niveau),
    INDEX idx_ordre (ordre),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 10. TABLE DES ANNÉES ACADÉMIQUES
-- ============================================
CREATE TABLE annees_academiques (
    id_annee_academique INT PRIMARY KEY AUTO_INCREMENT,
    code_annee VARCHAR(20) UNIQUE NOT NULL COMMENT '2023-2024',
    annee_debut YEAR NOT NULL,
    annee_fin YEAR NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    est_courante BOOLEAN DEFAULT FALSE,
    est_cloturee BOOLEAN DEFAULT FALSE,
    date_cloture DATETIME,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code_annee),
    INDEX idx_courante (est_courante),
    INDEX idx_dates (date_debut, date_fin)
) ENGINE=InnoDB;

-- ============================================
-- 11. TABLE DES ÉTUDIANTS
-- ============================================
CREATE TABLE etudiants (
    id_etudiant INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT UNIQUE NOT NULL,
    numero_etudiant VARCHAR(20) UNIQUE NOT NULL,
    date_naissance DATE NOT NULL,
    lieu_naissance VARCHAR(100),
    sexe ENUM('M', 'F') NOT NULL,
    nationalite VARCHAR(50) DEFAULT 'Congolaise',
    adresse TEXT,
    ville VARCHAR(100),
    province VARCHAR(100),
    nom_pere VARCHAR(100),
    nom_mere VARCHAR(100),
    telephone_urgence VARCHAR(20),
    groupe_sanguin VARCHAR(5),
    photo_identite VARCHAR(255),
    statut ENUM('Actif', 'Suspendu', 'Diplômé', 'Abandonné') DEFAULT 'Actif',
    date_premiere_inscription DATE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    INDEX idx_numero (numero_etudiant),
    INDEX idx_user (id_user),
    INDEX idx_statut (statut),
    INDEX idx_nom (id_user)
) ENGINE=InnoDB;

-- ============================================
-- 12. TABLE DES INSCRIPTIONS
-- ============================================
CREATE TABLE inscriptions (
    id_inscription INT PRIMARY KEY AUTO_INCREMENT,
    numero_inscription VARCHAR(30) UNIQUE NOT NULL,
    id_etudiant INT NOT NULL,
    id_filiere INT NOT NULL,
    id_niveau INT NOT NULL,
    id_annee_academique INT NOT NULL,
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP,
    type_inscription ENUM('Nouvelle', 'Réinscription', 'Transfert') NOT NULL,
    statut_inscription ENUM('En attente', 'Validée', 'Rejetée', 'Annulée') DEFAULT 'En attente',
    montant_total DECIMAL(10,2) NOT NULL,
    montant_paye DECIMAL(10,2) DEFAULT 0.00,
    montant_restant DECIMAL(10,2) NOT NULL,
    est_complete BOOLEAN DEFAULT FALSE,
    date_validation DATETIME,
    validee_par INT,
    motif_rejet TEXT,
    notes TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_etudiant) REFERENCES etudiants(id_etudiant),
    FOREIGN KEY (id_filiere) REFERENCES filieres(id_filiere),
    FOREIGN KEY (id_niveau) REFERENCES niveaux(id_niveau),
    FOREIGN KEY (id_annee_academique) REFERENCES annees_academiques(id_annee_academique),
    FOREIGN KEY (validee_par) REFERENCES users(id_user),
    INDEX idx_numero (numero_inscription),
    INDEX idx_etudiant (id_etudiant),
    INDEX idx_annee (id_annee_academique),
    INDEX idx_statut (statut_inscription),
    INDEX idx_date (date_inscription),
    UNIQUE KEY unique_inscription (id_etudiant, id_annee_academique)
) ENGINE=InnoDB;

-- ============================================
-- 13. TABLE DES TYPES DE FRAIS
-- ============================================
CREATE TABLE types_frais (
    id_type_frais INT PRIMARY KEY AUTO_INCREMENT,
    code_frais VARCHAR(20) UNIQUE NOT NULL,
    nom_frais VARCHAR(100) NOT NULL,
    description TEXT,
    montant_base DECIMAL(10,2) NOT NULL,
    est_obligatoire BOOLEAN DEFAULT TRUE,
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code_frais),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 14. TABLE DES FRAIS DE SCOLARITÉ
-- ============================================
CREATE TABLE frais_scolarite (
    id_frais INT PRIMARY KEY AUTO_INCREMENT,
    id_filiere INT NOT NULL,
    id_niveau INT NOT NULL,
    id_annee_academique INT NOT NULL,
    id_type_frais INT NOT NULL,
    montant DECIMAL(10,2) NOT NULL,
    date_debut_validite DATE NOT NULL,
    date_fin_validite DATE NOT NULL,
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_filiere) REFERENCES filieres(id_filiere),
    FOREIGN KEY (id_niveau) REFERENCES niveaux(id_niveau),
    FOREIGN KEY (id_annee_academique) REFERENCES annees_academiques(id_annee_academique),
    FOREIGN KEY (id_type_frais) REFERENCES types_frais(id_type_frais),
    INDEX idx_filiere_niveau (id_filiere, id_niveau),
    INDEX idx_annee (id_annee_academique),
    INDEX idx_actif (est_actif),
    UNIQUE KEY unique_frais (id_filiere, id_niveau, id_annee_academique, id_type_frais)
) ENGINE=InnoDB;

-- ============================================
-- 15. TABLE DES MODES DE PAIEMENT
-- ============================================
CREATE TABLE modes_paiement (
    id_mode_paiement INT PRIMARY KEY AUTO_INCREMENT,
    code_mode VARCHAR(20) UNIQUE NOT NULL,
    nom_mode VARCHAR(50) NOT NULL COMMENT 'Espèces, Carte, Mobile Money, Virement',
    description TEXT,
    est_actif BOOLEAN DEFAULT TRUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code_mode),
    INDEX idx_actif (est_actif)
) ENGINE=InnoDB;

-- ============================================
-- 16. TABLE DES PAIEMENTS
-- ============================================
CREATE TABLE paiements (
    id_paiement INT PRIMARY KEY AUTO_INCREMENT,
    numero_paiement VARCHAR(30) UNIQUE NOT NULL,
    id_inscription INT NOT NULL,
    id_etudiant INT NOT NULL,
    id_type_frais INT NOT NULL,
    id_mode_paiement INT NOT NULL,
    montant DECIMAL(10,2) NOT NULL,
    date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
    reference_transaction VARCHAR(100),
    recu_par INT NOT NULL COMMENT 'ID du caissier',
    statut_paiement ENUM('En attente', 'Validé', 'Annulé', 'Remboursé') DEFAULT 'Validé',
    motif_annulation TEXT,
    annule_par INT,
    date_annulation DATETIME,
    notes TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_inscription) REFERENCES inscriptions(id_inscription),
    FOREIGN KEY (id_etudiant) REFERENCES etudiants(id_etudiant),
    FOREIGN KEY (id_type_frais) REFERENCES types_frais(id_type_frais),
    FOREIGN KEY (id_mode_paiement) REFERENCES modes_paiement(id_mode_paiement),
    FOREIGN KEY (recu_par) REFERENCES users(id_user),
    FOREIGN KEY (annule_par) REFERENCES users(id_user),
    INDEX idx_numero (numero_paiement),
    INDEX idx_inscription (id_inscription),
    INDEX idx_etudiant (id_etudiant),
    INDEX idx_date (date_paiement),
    INDEX idx_statut (statut_paiement),
    INDEX idx_caissier (recu_par)
) ENGINE=InnoDB;

-- ============================================
-- 17. TABLE DES REÇUS
-- ============================================
CREATE TABLE recus (
    id_recu INT PRIMARY KEY AUTO_INCREMENT,
    numero_recu VARCHAR(30) UNIQUE NOT NULL,
    id_paiement INT NOT NULL,
    id_etudiant INT NOT NULL,
    montant_total DECIMAL(10,2) NOT NULL,
    date_emission DATETIME DEFAULT CURRENT_TIMESTAMP,
    emis_par INT NOT NULL,
    fichier_pdf VARCHAR(255),
    est_imprime BOOLEAN DEFAULT FALSE,
    date_impression DATETIME,
    nombre_impressions INT DEFAULT 0,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paiement) REFERENCES paiements(id_paiement),
    FOREIGN KEY (id_etudiant) REFERENCES etudiants(id_etudiant),
    FOREIGN KEY (emis_par) REFERENCES users(id_user),
    INDEX idx_numero (numero_recu),
    INDEX idx_paiement (id_paiement),
    INDEX idx_etudiant (id_etudiant),
    INDEX idx_date (date_emission)
) ENGINE=InnoDB;

-- ============================================
-- 18. TABLE DES LOGS D'ACTIVITÉ
-- ============================================
CREATE TABLE logs_activite (
    id_log BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_user INT,
    action VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    donnees_avant JSON,
    donnees_apres JSON,
    date_action TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE SET NULL,
    INDEX idx_user (id_user),
    INDEX idx_action (action),
    INDEX idx_module (module),
    INDEX idx_date (date_action)
) ENGINE=InnoDB;

-- ============================================
-- 19. TABLE DES NOTIFICATIONS
-- ============================================
CREATE TABLE notifications (
    id_notification INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT NOT NULL,
    titre VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type_notification ENUM('Info', 'Succès', 'Avertissement', 'Erreur') DEFAULT 'Info',
    est_lu BOOLEAN DEFAULT FALSE,
    date_lecture DATETIME,
    lien VARCHAR(255),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    INDEX idx_user (id_user),
    INDEX idx_lu (est_lu),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB;

-- ============================================
-- 20. TABLE DES DOCUMENTS
-- ============================================
CREATE TABLE documents (
    id_document INT PRIMARY KEY AUTO_INCREMENT,
    id_etudiant INT NOT NULL,
    type_document VARCHAR(50) NOT NULL COMMENT 'Diplôme, Relevé, Attestation, etc.',
    nom_fichier VARCHAR(255) NOT NULL,
    chemin_fichier VARCHAR(255) NOT NULL,
    taille_fichier INT,
    extension VARCHAR(10),
    telecharge_par INT,
    date_upload DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_etudiant) REFERENCES etudiants(id_etudiant) ON DELETE CASCADE,
    FOREIGN KEY (telecharge_par) REFERENCES users(id_user),
    INDEX idx_etudiant (id_etudiant),
    INDEX idx_type (type_document),
    INDEX idx_date (date_upload)
) ENGINE=InnoDB;

-- ============================================
-- PROCÉDURES STOCKÉES
-- ============================================

-- Procédure: Générer numéro d'inscription
DELIMITER $$
CREATE PROCEDURE sp_generer_numero_inscription(
    IN p_annee_academique VARCHAR(20),
    OUT p_numero VARCHAR(30)
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_annee_code VARCHAR(10);
    
    -- Extraire code année (ex: 2024 de 2023-2024)
    SET v_annee_code = SUBSTRING(p_annee_academique, 1, 4);
    
    -- Compter inscriptions de l'année
    SELECT COUNT(*) + 1 INTO v_count
    FROM inscriptions i
    JOIN annees_academiques aa ON i.id_annee_academique = aa.id_annee_academique
    WHERE aa.code_annee = p_annee_academique;
    
    -- Générer numéro: INS-2024-0001
    SET p_numero = CONCAT('INS-', v_annee_code, '-', LPAD(v_count, 4, '0'));
END$$
DELIMITER ;

-- Procédure: Générer numéro de paiement
DELIMITER $$
CREATE PROCEDURE sp_generer_numero_paiement(
    OUT p_numero VARCHAR(30)
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_annee VARCHAR(4);
    DECLARE v_mois VARCHAR(2);
    
    SET v_annee = YEAR(CURDATE());
    SET v_mois = LPAD(MONTH(CURDATE()), 2, '0');
    
    SELECT COUNT(*) + 1 INTO v_count
    FROM paiements
    WHERE YEAR(date_paiement) = v_annee 
    AND MONTH(date_paiement) = MONTH(CURDATE());
    
    -- PAY-2024-01-0001
    SET p_numero = CONCAT('PAY-', v_annee, '-', v_mois, '-', LPAD(v_count, 4, '0'));
END$$
DELIMITER ;

-- Procédure: Générer numéro de reçu
DELIMITER $$
CREATE PROCEDURE sp_generer_numero_recu(
    OUT p_numero VARCHAR(30)
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_annee VARCHAR(4);
    
    SET v_annee = YEAR(CURDATE());
    
    SELECT COUNT(*) + 1 INTO v_count
    FROM recus
    WHERE YEAR(date_emission) = v_annee;
    
    -- REC-2024-00001
    SET p_numero = CONCAT('REC-', v_annee, '-', LPAD(v_count, 5, '0'));
END$$
DELIMITER ;

-- Procédure: Calculer montant total inscription
DELIMITER $$
CREATE PROCEDURE sp_calculer_montant_inscription(
    IN p_id_filiere INT,
    IN p_id_niveau INT,
    IN p_id_annee_academique INT,
    OUT p_montant_total DECIMAL(10,2)
)
BEGIN
    SELECT SUM(fs.montant) INTO p_montant_total
    FROM frais_scolarite fs
    JOIN types_frais tf ON fs.id_type_frais = tf.id_type_frais
    WHERE fs.id_filiere = p_id_filiere
    AND fs.id_niveau = p_id_niveau
    AND fs.id_annee_academique = p_id_annee_academique
    AND fs.est_actif = TRUE
    AND tf.est_obligatoire = TRUE;
    
    IF p_montant_total IS NULL THEN
        SET p_montant_total = 0;
    END IF;
END$$
DELIMITER ;

-- Procédure: Enregistrer inscription complète
DELIMITER $$
CREATE PROCEDURE sp_enregistrer_inscription(
    IN p_id_etudiant INT,
    IN p_id_filiere INT,
    IN p_id_niveau INT,
    IN p_id_annee_academique INT,
    IN p_type_inscription VARCHAR(20),
    OUT p_id_inscription INT,
    OUT p_numero_inscription VARCHAR(30),
    OUT p_montant_total DECIMAL(10,2)
)
BEGIN
    DECLARE v_numero VARCHAR(30);
    DECLARE v_montant DECIMAL(10,2);
    DECLARE v_annee_code VARCHAR(20);
    
    -- Obtenir code année académique
    SELECT code_annee INTO v_annee_code
    FROM annees_academiques
    WHERE id_annee_academique = p_id_annee_academique;
    
    -- Générer numéro
    CALL sp_generer_numero_inscription(v_annee_code, v_numero);
    
    -- Calculer montant
    CALL sp_calculer_montant_inscription(p_id_filiere, p_id_niveau, p_id_annee_academique, v_montant);
    
    -- Insérer inscription
    INSERT INTO inscriptions (
        numero_inscription, id_etudiant, id_filiere, id_niveau,
        id_annee_academique, type_inscription, montant_total, montant_restant
    ) VALUES (
        v_numero, p_id_etudiant, p_id_filiere, p_id_niveau,
        p_id_annee_academique, p_type_inscription, v_montant, v_montant
    );
    
    SET p_id_inscription = LAST_INSERT_ID();
    SET p_numero_inscription = v_numero;
    SET p_montant_total = v_montant;
END$$
DELIMITER ;

-- Procédure: Enregistrer paiement
DELIMITER $$
CREATE PROCEDURE sp_enregistrer_paiement(
    IN p_id_inscription INT,
    IN p_id_etudiant INT,
    IN p_id_type_frais INT,
    IN p_id_mode_paiement INT,
    IN p_montant DECIMAL(10,2),
    IN p_recu_par INT,
    IN p_reference VARCHAR(100),
    OUT p_id_paiement INT,
    OUT p_numero_paiement VARCHAR(30)
)
BEGIN
    DECLARE v_numero VARCHAR(30);
    
    -- Générer numéro paiement
    CALL sp_generer_numero_paiement(v_numero);
    
    -- Insérer paiement
    INSERT INTO paiements (
        numero_paiement, id_inscription, id_etudiant, id_type_frais,
        id_mode_paiement, montant, reference_transaction, recu_par
    ) VALUES (
        v_numero, p_id_inscription, p_id_etudiant, p_id_type_frais,
        p_id_mode_paiement, p_montant, p_reference, p_recu_par
    );
    
    SET p_id_paiement = LAST_INSERT_ID();
    SET p_numero_paiement = v_numero;
    
    -- Mettre à jour inscription
    UPDATE inscriptions
    SET montant_paye = montant_paye + p_montant,
        montant_restant = montant_total - (montant_paye + p_montant),
        est_complete = (montant_total <= (montant_paye + p_montant))
    WHERE id_inscription = p_id_inscription;
END$$
DELIMITER ;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger: Après insertion paiement -> créer reçu
DELIMITER $$
CREATE TRIGGER trg_after_paiement_insert
AFTER INSERT ON paiements
FOR EACH ROW
BEGIN
    DECLARE v_numero_recu VARCHAR(30);
    
    IF NEW.statut_paiement = 'Validé' THEN
        CALL sp_generer_numero_recu(v_numero_recu);
        
        INSERT INTO recus (
            numero_recu, id_paiement, id_etudiant, 
            montant_total, emis_par
        ) VALUES (
            v_numero_recu, NEW.id_paiement, NEW.id_etudiant,
            NEW.montant, NEW.recu_par
        );
    END IF;
END$$
DELIMITER ;

-- Trigger: Avant insertion utilisateur -> hasher mot de passe (simulation)
DELIMITER $$
CREATE TRIGGER trg_before_user_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    -- Vérifier format email
    IF NEW.email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Format email invalide';
    END IF;
    
    -- Générer matricule si vide
    IF NEW.matricule IS NULL OR NEW.matricule = '' THEN
        SET NEW.matricule = CONCAT('USR', YEAR(CURDATE()), LPAD((SELECT COUNT(*) + 1 FROM users), 5, '0'));
    END IF;
END$$
DELIMITER ;

-- Trigger: Après inscription -> créer notification
DELIMITER $$
CREATE TRIGGER trg_after_inscription_insert
AFTER INSERT ON inscriptions
FOR EACH ROW
BEGIN
    DECLARE v_id_user INT;
    
    -- Récupérer id_user de l'étudiant
    SELECT id_user INTO v_id_user
    FROM etudiants
    WHERE id_etudiant = NEW.id_etudiant;
    
    -- Créer notification
    INSERT INTO notifications (id_user, titre, message, type_notification)
    VALUES (
        v_id_user,
        'Nouvelle inscription',
        CONCAT('Votre inscription N° ', NEW.numero_inscription, ' a été enregistrée avec succès.'),
        'Succès'
    );
END$$
DELIMITER ;

-- Trigger: Vérifier année académique unique courante
DELIMITER $$
CREATE TRIGGER trg_before_annee_academique_insert
BEFORE INSERT ON annees_academiques
FOR EACH ROW
BEGIN
    IF NEW.est_courante = TRUE THEN
        UPDATE annees_academiques SET est_courante = FALSE WHERE est_courante = TRUE;
    END IF;
END$$

CREATE TRIGGER trg_before_annee_academique_update
BEFORE UPDATE ON annees_academiques
FOR EACH ROW
BEGIN
    IF NEW.est_courante = TRUE AND OLD.est_courante = FALSE THEN
        UPDATE annees_academiques SET est_courante = FALSE WHERE est_courante = TRUE AND id_annee_academique != NEW.id_annee_academique;
    END IF;
END$$
DELIMITER ;

-- Trigger: Logger les modifications importantes
DELIMITER $$
CREATE TRIGGER trg_after_paiement_update
AFTER UPDATE ON paiements
FOR EACH ROW
BEGIN
    IF OLD.statut_paiement != NEW.statut_paiement THEN
        INSERT INTO logs_activite (id_user, action, module, description, donnees_avant, donnees_apres)
        VALUES (
            NEW.annule_par,
            'MODIFICATION_PAIEMENT',
            'Paiements',
            CONCAT('Changement statut paiement N° ', NEW.numero_paiement),
            JSON_OBJECT('statut', OLD.statut_paiement, 'montant', OLD.montant),
            JSON_OBJECT('statut', NEW.statut_paiement, 'montant', NEW.montant)
        );
    END IF;
END$$
DELIMITER ;

-- ============================================
-- VUES POUR RAPPORTS ET ÉTATS
-- ============================================

-- Vue: Liste complète des étudiants avec informations
CREATE VIEW v_etudiants_complets AS
SELECT 
    e.id_etudiant,
    e.numero_etudiant,
    u.matricule,
    u.nom,
    u.prenom,
    u.email,
    u.telephone,
    e.date_naissance,
    e.sexe,
    e.statut,
    e.date_premiere_inscription,
    u.est_actif
FROM etudiants e
JOIN users u ON e.id_user = u.id_user;

-- Vue: Inscriptions avec détails
CREATE VIEW v_inscriptions_detaillees AS
SELECT 
    i.id_inscription,
    i.numero_inscription,
    i.date_inscription,
    e.numero_etudiant,
    u.nom,
    u.prenom,
    f.nom_filiere,
    n.nom_niveau,
    aa.code_annee,
    i.type_inscription,
    i.statut_inscription,
    i.montant_total,
    i.montant_paye,
    i.montant_restant,
    i.est_complete,
    CONCAT(ROUND((i.montant_paye / i.montant_total) * 100, 2), '%') AS pourcentage_paye
FROM inscriptions i
JOIN etudiants e ON i.id_etudiant = e.id_etudiant
JOIN users u ON e.id_user = u.id_user
JOIN filieres f ON i.id_filiere = f.id_filiere
JOIN niveaux n ON i.id_niveau = n.id_niveau
JOIN annees_academiques aa ON i.id_annee_academique = aa.id_annee_academique;

-- Vue: Paiements avec détails
CREATE VIEW v_paiements_detailles AS
SELECT 
    p.id_paiement,
    p.numero_paiement,
    p.date_paiement,
    e.numero_etudiant,
    CONCAT(u.nom, ' ', u.prenom) AS nom_complet_etudiant,
    i.numero_inscription,
    tf.nom_frais,
    p.montant,
    mp.nom_mode AS mode_paiement,
    p.reference_transaction,
    CONCAT(uc.nom, ' ', uc.prenom) AS recu_par_nom,
    p.statut_paiement,
    r.numero_recu
FROM paiements p
JOIN etudiants e ON p.id_etudiant = e.id_etudiant
JOIN users u ON e.id_user = u.id_user
JOIN inscriptions i ON p.id_inscription = i.id_inscription
JOIN types_frais tf ON p.id_type_frais = tf.id_type_frais
JOIN modes_paiement mp ON p.id_mode_paiement = mp.id_mode_paiement
JOIN users uc ON p.recu_par = uc.id_user
LEFT JOIN recus r ON p.id_paiement = r.id_paiement;

-- Vue: Statistiques par filière
CREATE VIEW v_statistiques_filieres AS
SELECT 
    f.id_filiere,
    f.nom_filiere,
    aa.code_annee,
    COUNT(DISTINCT i.id_inscription) AS nombre_inscriptions,
    COUNT(DISTINCT CASE WHEN i.est_complete = TRUE THEN i.id_inscription END) AS inscriptions_completes,
    SUM(i.montant_total) AS montant_total_attendu,
    SUM(i.montant_paye) AS montant_total_percu,
    SUM(i.montant_restant) AS montant_total_restant
FROM filieres f
LEFT JOIN inscriptions i ON f.id_filiere = i.id_filiere
LEFT JOIN annees_academiques aa ON i.id_annee_academique = aa.id_annee_academique
GROUP BY f.id_filiere, f.nom_filiere, aa.code_annee;

-- Vue: Rapport journalier caisse
CREATE VIEW v_rapport_journalier_caisse AS
SELECT 
    DATE(p.date_paiement) AS date_operation,
    COUNT(p.id_paiement) AS nombre_transactions,
    SUM(p.montant) AS montant_total,
    mp.nom_mode,
    CONCAT(u.nom, ' ', u.prenom) AS caissier
FROM paiements p
JOIN modes_paiement mp ON p.id_mode_paiement = mp.id_mode_paiement
JOIN users u ON p.recu_par = u.id_user
WHERE p.statut_paiement = 'Validé'
GROUP BY DATE(p.date_paiement), mp.nom_mode, p.recu_par, u.nom, u.prenom;

-- Vue: Étudiants avec solde impayé
CREATE VIEW v_etudiants_impayes AS
SELECT 
    e.numero_etudiant,
    CONCAT(u.nom, ' ', u.prenom) AS nom_complet,
    u.email,
    u.telephone,
    i.numero_inscription,
    f.nom_filiere,
    n.nom_niveau,
    i.montant_total,
    i.montant_paye,
    i.montant_restant,
    DATEDIFF(CURDATE(), i.date_inscription) AS jours_depuis_inscription
FROM inscriptions i
JOIN etudiants e ON i.id_etudiant = e.id_etudiant
JOIN users u ON e.id_user = u.id_user
JOIN filieres f ON i.id_filiere = f.id_filiere
JOIN niveaux n ON i.id_niveau = n.id_niveau
WHERE i.montant_restant > 0
AND i.statut_inscription = 'Validée'
ORDER BY i.montant_restant DESC;

-- ============================================
-- PROCÉDURES POUR RAPPORTS
-- ============================================

-- Rapport: Statistiques globales
DELIMITER $$
CREATE PROCEDURE sp_rapport_statistiques_globales(
    IN p_id_annee_academique INT
)
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM etudiants WHERE statut = 'Actif') AS total_etudiants_actifs,
        (SELECT COUNT(*) FROM inscriptions WHERE id_annee_academique = p_id_annee_academique) AS total_inscriptions,
        (SELECT COUNT(*) FROM inscriptions WHERE id_annee_academique = p_id_annee_academique AND est_complete = TRUE) AS inscriptions_payees,
        (SELECT SUM(montant_total) FROM inscriptions WHERE id_annee_academique = p_id_annee_academique) AS montant_total_attendu,
        (SELECT SUM(montant_paye) FROM inscriptions WHERE id_annee_academique = p_id_annee_academique) AS montant_total_percu,
        (SELECT SUM(montant_restant) FROM inscriptions WHERE id_annee_academique = p_id_annee_academique) AS montant_total_impaye,
        (SELECT COUNT(*) FROM paiements WHERE DATE(date_paiement) = CURDATE() AND statut_paiement = 'Validé') AS paiements_aujourdhui,
        (SELECT IFNULL(SUM(montant), 0) FROM paiements WHERE DATE(date_paiement) = CURDATE() AND statut_paiement = 'Validé') AS montant_aujourdhui;
END$$
DELIMITER ;

-- Rapport: Paiements par période
DELIMITER $$
CREATE PROCEDURE sp_rapport_paiements_periode(
    IN p_date_debut DATE,
    IN p_date_fin DATE,
    IN p_id_caissier INT
)
BEGIN
    SELECT 
        p.numero_paiement,
        p.date_paiement,
        CONCAT(u.nom, ' ', u.prenom) AS etudiant,
        tf.nom_frais,
        p.montant,
        mp.nom_mode,
        p.reference_transaction,
        p.statut_paiement
    FROM paiements p
    JOIN etudiants e ON p.id_etudiant = e.id_etudiant
    JOIN users u ON e.id_user = u.id_user
    JOIN types_frais tf ON p.id_type_frais = tf.id_type_frais
    JOIN modes_paiement mp ON p.id_mode_paiement = mp.id_mode_paiement
    WHERE DATE(p.date_paiement) BETWEEN p_date_debut AND p_date_fin
    AND (p_id_caissier IS NULL OR p.recu_par = p_id_caissier)
    ORDER BY p.date_paiement DESC;
END$$
DELIMITER ;

-- Rapport: Situation inscription étudiant
DELIMITER $$
CREATE PROCEDURE sp_rapport_situation_etudiant(
    IN p_id_etudiant INT,
    IN p_id_annee_academique INT
)
BEGIN
    -- Informations inscription
    SELECT 
        i.numero_inscription,
        i.date_inscription,
        f.nom_filiere,
        n.nom_niveau,
        i.montant_total,
        i.montant_paye,
        i.montant_restant,
        i.est_complete,
        i.statut_inscription
    FROM inscriptions i
    JOIN filieres f ON i.id_filiere = f.id_filiere
    JOIN niveaux n ON i.id_niveau = n.id_niveau
    WHERE i.id_etudiant = p_id_etudiant
    AND i.id_annee_academique = p_id_annee_academique;
    
    -- Historique paiements
    SELECT 
        p.numero_paiement,
        p.date_paiement,
        tf.nom_frais,
        p.montant,
        mp.nom_mode,
        r.numero_recu
    FROM paiements p
    JOIN inscriptions i ON p.id_inscription = i.id_inscription
    JOIN types_frais tf ON p.id_type_frais = tf.id_type_frais
    JOIN modes_paiement mp ON p.id_mode_paiement = mp.id_mode_paiement
    LEFT JOIN recus r ON p.id_paiement = r.id_paiement
    WHERE p.id_etudiant = p_id_etudiant
    AND i.id_annee_academique = p_id_annee_academique
    AND p.statut_paiement = 'Validé'
    ORDER BY p.date_paiement DESC;
END$$
DELIMITER ;

-- ============================================
-- DONNÉES INITIALES
-- ============================================

-- Insertion des rôles
INSERT INTO roles (nom_role, description) VALUES
('Administrateur', 'Accès complet au système'),
('Caissier', 'Gestion des paiements et reçus'),
('Gestionnaire', 'Gestion des inscriptions et étudiants'),
('Etudiant', 'Consultation personnelle'),
('Comptable', 'Consultation rapports financiers');

-- Insertion des permissions
INSERT INTO permissions (nom_permission, code_permission, module, description) VALUES
-- Module Utilisateurs
('Créer utilisateur', 'user.create', 'Utilisateurs', 'Créer de nouveaux utilisateurs'),
('Modifier utilisateur', 'user.update', 'Utilisateurs', 'Modifier les utilisateurs'),
('Supprimer utilisateur', 'user.delete', 'Utilisateurs', 'Supprimer les utilisateurs'),
('Consulter utilisateur', 'user.read', 'Utilisateurs', 'Voir les utilisateurs'),

-- Module Étudiants
('Créer étudiant', 'etudiant.create', 'Etudiants', 'Enregistrer nouveaux étudiants'),
('Modifier étudiant', 'etudiant.update', 'Etudiants', 'Modifier informations étudiants'),
('Supprimer étudiant', 'etudiant.delete', 'Etudiants', 'Supprimer étudiants'),
('Consulter étudiant', 'etudiant.read', 'Etudiants', 'Voir informations étudiants'),

-- Module Inscriptions
('Créer inscription', 'inscription.create', 'Inscriptions', 'Enregistrer inscriptions'),
('Modifier inscription', 'inscription.update', 'Inscriptions', 'Modifier inscriptions'),
('Valider inscription', 'inscription.validate', 'Inscriptions', 'Valider/rejeter inscriptions'),
('Consulter inscription', 'inscription.read', 'Inscriptions', 'Voir inscriptions'),

-- Module Paiements
('Créer paiement', 'paiement.create', 'Paiements', 'Enregistrer paiements'),
('Annuler paiement', 'paiement.cancel', 'Paiements', 'Annuler paiements'),
('Consulter paiement', 'paiement.read', 'Paiements', 'Voir paiements'),
('Imprimer reçu', 'recu.print', 'Paiements', 'Imprimer reçus'),

-- Module Rapports
('Rapport général', 'rapport.general', 'Rapports', 'Voir rapports généraux'),
('Rapport caisse', 'rapport.caisse', 'Rapports', 'Voir rapports caisse'),
('Rapport étudiant', 'rapport.etudiant', 'Rapports', 'Voir rapports étudiants'),

-- Module Configuration
('Gérer filières', 'config.filieres', 'Configuration', 'Gérer filières et niveaux'),
('Gérer frais', 'config.frais', 'Configuration', 'Gérer types de frais'),
('Gérer année académique', 'config.annee', 'Configuration', 'Gérer années académiques');

-- Attribution permissions Administrateur (tous)
INSERT INTO role_permissions (id_role, id_permission)
SELECT 1, id_permission FROM permissions;

-- Attribution permissions Caissier
INSERT INTO role_permissions (id_role, id_permission)
SELECT 2, id_permission FROM permissions 
WHERE code_permission IN (
    'paiement.create', 'paiement.read', 'recu.print',
    'etudiant.read', 'inscription.read', 'rapport.caisse'
);

-- Attribution permissions Gestionnaire
INSERT INTO role_permissions (id_role, id_permission)
SELECT 3, id_permission FROM permissions 
WHERE code_permission LIKE 'etudiant.%' 
   OR code_permission LIKE 'inscription.%'
   OR code_permission = 'rapport.etudiant';

-- Attribution permissions Étudiant
INSERT INTO role_permissions (id_role, id_permission)
SELECT 4, id_permission FROM permissions 
WHERE code_permission IN ('inscription.read', 'paiement.read', 'rapport.etudiant');

-- Modes de paiement
INSERT INTO modes_paiement (code_mode, nom_mode, description) VALUES
('ESPECES', 'Espèces', 'Paiement en argent liquide'),
('CARTE', 'Carte bancaire', 'Paiement par carte'),
('MOBILE', 'Mobile Money', 'Paiement mobile (M-Pesa, Airtel Money, etc.)'),
('VIREMENT', 'Virement bancaire', 'Virement bancaire'),
('CHEQUE', 'Chèque', 'Paiement par chèque');

-- Niveaux
INSERT INTO niveaux (code_niveau, nom_niveau, ordre, description) VALUES
('L1', 'Licence 1', 1, 'Première année de licence'),
('L2', 'Licence 2', 2, 'Deuxième année de licence'),
('L3', 'Licence 3', 3, 'Troisième année de licence'),
('M1', 'Master 1', 4, 'Première année de master'),
('M2', 'Master 2', 5, 'Deuxième année de master');

-- Types de frais
INSERT INTO types_frais (code_frais, nom_frais, description, montant_base, est_obligatoire) VALUES
('SCOL', 'Frais de scolarité', 'Frais de scolarité annuels', 500000.00, TRUE),
('INSC', 'Frais d\'inscription', 'Frais d\'inscription administrative', 50000.00, TRUE),
('BIB', 'Frais de bibliothèque', 'Accès bibliothèque', 25000.00, TRUE),
('SPORT', 'Frais sportifs', 'Activités sportives', 15000.00, FALSE),
('ASSUR', 'Assurance', 'Assurance étudiante', 20000.00, TRUE),
('CARTE', 'Carte étudiant', 'Carte d\'étudiant', 5000.00, TRUE);

-- Utilisateur admin par défaut (mot de passe: Admin@123)
INSERT INTO users (matricule, nom, prenom, email, mot_de_passe, id_role, est_actif) VALUES
('ADMIN001', 'Super', 'Admin', 'admin@ismgl.cd', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1, TRUE);
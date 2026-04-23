<?php
// Constantes de l'application

// Statuts d'inscription
define('INSCRIPTION_EN_ATTENTE', 'En attente');
define('INSCRIPTION_VALIDEE', 'Validée');
define('INSCRIPTION_REJETEE', 'Rejetée');
define('INSCRIPTION_ANNULEE', 'Annulée');

// Types d'inscription
define('TYPE_NOUVELLE', 'Nouvelle');
define('TYPE_REINSCRIPTION', 'Réinscription');
define('TYPE_TRANSFERT', 'Transfert');

// Statuts de paiement
define('PAIEMENT_EN_ATTENTE', 'En attente');
define('PAIEMENT_VALIDE', 'Validé');
define('PAIEMENT_ANNULE', 'Annulé');
define('PAIEMENT_REMBOURSE', 'Remboursé');

// Statuts d'étudiant
define('ETUDIANT_ACTIF', 'Actif');
define('ETUDIANT_SUSPENDU', 'Suspendu');
define('ETUDIANT_DIPLOME', 'Diplômé');
define('ETUDIANT_ABANDONNE', 'Abandonné');

// Types de notification
define('NOTIF_INFO', 'Info');
define('NOTIF_SUCCES', 'Succès');
define('NOTIF_AVERTISSEMENT', 'Avertissement');
define('NOTIF_ERREUR', 'Erreur');

// Rôles
define('ROLE_ADMIN', 1);
define('ROLE_CAISSIER', 2);
define('ROLE_GESTIONNAIRE', 3);
define('ROLE_ETUDIANT', 4);
define('ROLE_COMPTABLE', 5);

// Messages d'erreur
define('MSG_UNAUTHORIZED', 'Non autorisé. Veuillez vous connecter.');
define('MSG_FORBIDDEN', 'Accès interdit. Permissions insuffisantes.');
define('MSG_NOT_FOUND', 'Ressource non trouvée.');
define('MSG_VALIDATION_ERROR', 'Erreur de validation des données.');
define('MSG_SERVER_ERROR', 'Erreur serveur. Veuillez réessayer.');
define('MSG_INVALID_TOKEN', 'Token invalide ou expiré.');
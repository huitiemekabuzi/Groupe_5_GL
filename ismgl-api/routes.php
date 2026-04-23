<?php
require_once __DIR__ . '/core/Router.php';
require_once __DIR__ . '/controllers/AuthController.php';
require_once __DIR__ . '/controllers/UserController.php';
require_once __DIR__ . '/controllers/EtudiantController.php';
require_once __DIR__ . '/controllers/InscriptionController.php';
require_once __DIR__ . '/controllers/PaiementController.php';
require_once __DIR__ . '/controllers/RecuController.php';
require_once __DIR__ . '/controllers/FiliereController.php';
require_once __DIR__ . '/controllers/ConfigurationController.php';
require_once __DIR__ . '/controllers/RapportController.php';
require_once __DIR__ . '/controllers/NotificationController.php';
require_once __DIR__ . '/controllers/DashboardController.php';

$router = new Router('/api/v1');

// ==================== AUTH ====================
$router->post('/auth/login',           'AuthController@login');
$router->post('/auth/logout',          'AuthController@logout');
$router->post('/auth/refresh',         'AuthController@refresh');
$router->get('/auth/me',               'AuthController@me');
$router->post('/auth/change-password', 'AuthController@changePassword');
$router->post('/auth/forgot-password', 'AuthController@forgotPassword');
$router->post('/auth/reset-password',  'AuthController@resetPassword');

// ==================== DASHBOARD ====================
$router->get('/dashboard', 'DashboardController@index');

// ==================== UTILISATEURS ====================
$router->get('/users',                  'UserController@index');
$router->get('/users/{id}',             'UserController@show');
$router->post('/users',                 'UserController@store');
$router->put('/users/{id}',             'UserController@update');
$router->delete('/users/{id}',          'UserController@delete');
$router->patch('/users/{id}/toggle',    'UserController@toggleActive');
$router->patch('/users/{id}/unlock',    'UserController@unlockAccount');

// ==================== ÉTUDIANTS ====================
$router->get('/etudiants',              'EtudiantController@index');
$router->get('/etudiants/me',           'EtudiantController@myProfile');
$router->get('/etudiants/{id}',         'EtudiantController@show');
$router->post('/etudiants',             'EtudiantController@store');
$router->put('/etudiants/{id}',         'EtudiantController@update');
$router->delete('/etudiants/{id}',      'EtudiantController@delete');
$router->patch('/etudiants/{id}/statut','EtudiantController@updateStatut');

// ==================== INSCRIPTIONS ====================
$router->get('/inscriptions',               'InscriptionController@index');
$router->get('/inscriptions/me',            'InscriptionController@myInscriptions');
$router->get('/inscriptions/{id}',          'InscriptionController@show');
$router->post('/inscriptions',              'InscriptionController@store');
$router->patch('/inscriptions/{id}/valider','InscriptionController@valider');
$router->patch('/inscriptions/{id}/rejeter','InscriptionController@rejeter');

// ==================== PAIEMENTS ====================
$router->get('/paiements',                  'PaiementController@index');
$router->get('/paiements/me',               'PaiementController@myPaiements');
$router->get('/paiements/journalier',       'PaiementController@rapportJournalier');
$router->get('/paiements/{id}',             'PaiementController@show');
$router->post('/paiements',                 'PaiementController@store');
$router->patch('/paiements/{id}/annuler',   'PaiementController@annuler');

// ==================== REÇUS ====================
$router->get('/recus/me',              'RecuController@myRecus');
$router->get('/recus/{id}',            'RecuController@show');
$router->get('/recus/{id}/generate',   'RecuController@generate');
$router->get('/recus/{id}/download',   'RecuController@download');

// ==================== FILIÈRES ====================
$router->get('/filieres',                           'FiliereController@index');
$router->get('/filieres/{id}',                      'FiliereController@show');
$router->post('/filieres',                          'FiliereController@store');
$router->put('/filieres/{id}',                      'FiliereController@update');
$router->delete('/filieres/{id}',                   'FiliereController@delete');
$router->get('/filieres/departement/{id}',          'FiliereController@byDepartement');
$router->get('/filieres/faculte/{id}',              'FiliereController@byFaculte');

// ==================== CONFIGURATION ====================
// Années académiques
$router->get('/config/annees',                      'ConfigurationController@getAnnees');
$router->get('/config/annees/courante',             'ConfigurationController@getAnneeCourante');
$router->post('/config/annees',                     'ConfigurationController@createAnnee');
$router->put('/config/annees/{id}',                 'ConfigurationController@updateAnnee');
$router->patch('/config/annees/{id}/courante',      'ConfigurationController@setAnneeCourante');
$router->patch('/config/annees/{id}/cloturer',      'ConfigurationController@cloturerAnnee');

// Types de frais
$router->get('/config/types-frais',                 'ConfigurationController@getTypesFrais');
$router->post('/config/types-frais',                'ConfigurationController@createTypeFrais');
$router->put('/config/types-frais/{id}',            'ConfigurationController@updateTypeFrais');

// Frais de scolarité
$router->get('/config/frais-scolarite',             'ConfigurationController@getFraisScolarite');
$router->post('/config/frais-scolarite',            'ConfigurationController@createFraisScolarite');
$router->put('/config/frais-scolarite/{id}',        'ConfigurationController@updateFraisScolarite');

// Niveaux
$router->get('/config/niveaux',                     'ConfigurationController@getNiveaux');
$router->post('/config/niveaux',                    'ConfigurationController@createNiveau');

// Facultés
$router->get('/config/facultes',                    'ConfigurationController@getFacultes');
$router->post('/config/facultes',                   'ConfigurationController@createFaculte');

// Départements
$router->get('/config/departements',                'ConfigurationController@getDepartements');
$router->post('/config/departements',               'ConfigurationController@createDepartement');

// Modes de paiement
$router->get('/config/modes-paiement',              'ConfigurationController@getModesPaiement');

// Rôles & Permissions
$router->get('/config/roles',                       'ConfigurationController@getRoles');
$router->get('/config/roles/{id}/permissions',      'ConfigurationController@getRolePermissions');
$router->post('/config/roles/{id}/permissions',     'ConfigurationController@assignPermissions');
$router->get('/config/permissions',                 'ConfigurationController@getPermissions');

// ==================== RAPPORTS ====================
$router->get('/rapports/statistiques',              'RapportController@statistiquesGlobales');
$router->get('/rapports/paiements',                 'RapportController@rapportPaiements');
$router->get('/rapports/journalier',                'RapportController@rapportJournalier');
$router->get('/rapports/impayes',                   'RapportController@etudiantsImpayes');
$router->get('/rapports/filieres',                  'RapportController@statistiquesFilieres');
$router->get('/rapports/financier',                 'RapportController@recapitulatifFinancier');
$router->get('/rapports/etudiant/{id}',             'RapportController@situationEtudiant');
$router->get('/rapports/export/pdf',                'RapportController@exportPDF');
$router->get('/rapports/export/csv',                'RapportController@exportCSV');
$router->get('/rapports/logs',                      'RapportController@logsActivite');

// ==================== NOTIFICATIONS ====================
$router->get('/notifications',                      'NotificationController@index');
$router->get('/notifications/debug',                'NotificationController@debug');
$router->get('/notifications/count/all',            'NotificationController@countAll');
$router->get('/notifications/count',                'NotificationController@count');
$router->patch('/notifications/{id}/lire',          'NotificationController@marquerLu');
$router->patch('/notifications/lire-tout',          'NotificationController@marquerToutLu');
$router->delete('/notifications/{id}',              'NotificationController@supprimer');
$router->post('/notifications/broadcast',           'NotificationController@envoyerBroadcast');

return $router;
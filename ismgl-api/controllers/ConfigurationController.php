<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../middleware/RoleMiddleware.php';
require_once __DIR__ . '/../models/AnneeAcademiqueModel.php';
require_once __DIR__ . '/../models/TypeFraisModel.php';
require_once __DIR__ . '/../models/FraisScolariteModel.php';
require_once __DIR__ . '/../models/NiveauModel.php';
require_once __DIR__ . '/../models/RoleModel.php';
require_once __DIR__ . '/../models/PermissionModel.php';

class ConfigurationController extends Controller {
    private $anneeModel;
    private $typeFraisModel;
    private $fraisModel;
    private $niveauModel;
    private $roleModel;
    private $permissionModel;

    public function __construct() {
        parent::__construct();
        $this->anneeModel      = new AnneeAcademiqueModel();
        $this->typeFraisModel  = new TypeFraisModel();
        $this->fraisModel      = new FraisScolariteModel();
        $this->niveauModel     = new NiveauModel();
        $this->roleModel       = new RoleModel();
        $this->permissionModel = new PermissionModel();
    }

    // ==================== ANNÉES ACADÉMIQUES ====================

    public function getAnnees() {
        AuthMiddleware::handle();

        try {
            $annees = $this->anneeModel->getAllAnneesAcademiques();
            Response::success($annees);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function getAnneeCourante() {
        AuthMiddleware::handle();

        try {
            $annee = $this->anneeModel->getAnneeCourante();
            if (!$annee) {
                Response::notFound('Aucune année académique courante définie');
            }
            Response::success($annee);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function createAnnee() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.annee');

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required(['code_annee', 'annee_debut', 'annee_fin', 'date_debut', 'date_fin'])
                  ->date('date_debut')
                  ->date('date_fin')
                  ->unique('code_annee', 'annees_academiques', 'code_annee');

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            $id = $this->anneeModel->create([
                'code_annee'    => $data['code_annee'],
                'annee_debut'   => $data['annee_debut'],
                'annee_fin'     => $data['annee_fin'],
                'date_debut'    => $data['date_debut'],
                'date_fin'      => $data['date_fin'],
                'est_courante'  => $data['est_courante'] ?? false,
                'est_cloturee'  => false
            ]);

            $this->logActivity('CREATE_ANNEE', 'Configuration', "Création année académique {$data['code_annee']}");

            $annee = $this->anneeModel->find($id);
            Response::created($annee, 'Année académique créée avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function updateAnnee($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.annee');

        $data = $this->getRequestData();

        try {
            $annee = $this->anneeModel->find($id);
            if (!$annee) {
                Response::notFound('Année académique non trouvée');
            }

            $updateData = [];
            $allowed = ['code_annee', 'annee_debut', 'annee_fin', 'date_debut', 'date_fin'];
            foreach ($allowed as $field) {
                if (isset($data[$field])) {
                    $updateData[$field] = $data[$field];
                }
            }

            $this->anneeModel->update($id, $updateData);
            $this->logActivity('UPDATE_ANNEE', 'Configuration', "Modification année académique ID: $id");

            Response::updated($this->anneeModel->find($id));
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function setAnneeCourante($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.annee');

        try {
            $annee = $this->anneeModel->find($id);
            if (!$annee) {
                Response::notFound('Année académique non trouvée');
            }

            $this->anneeModel->setAnneeCourante($id);
            $this->logActivity('SET_ANNEE_COURANTE', 'Configuration', "Définir année courante ID: $id");

            Response::success(null, 'Année académique définie comme courante');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function cloturerAnnee($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.annee');

        try {
            $annee = $this->anneeModel->find($id);
            if (!$annee) {
                Response::notFound('Année académique non trouvée');
            }

            if ($annee['est_cloturee']) {
                Response::error('Cette année académique est déjà clôturée', 400);
            }

            $this->anneeModel->cloturerAnnee($id);
            $this->logActivity('CLOTURER_ANNEE', 'Configuration', "Clôture année académique ID: $id");

            Response::success(null, 'Année académique clôturée avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    // ==================== TYPES DE FRAIS ====================

    public function getTypesFrais() {
        AuthMiddleware::handle();

        try {
            $typesFrais = $this->typeFraisModel->getAllTypesFrais();
            Response::success($typesFrais);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function createTypeFrais() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.frais');

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required(['code_frais', 'nom_frais', 'montant_base'])
                  ->numeric('montant_base')
                  ->min('montant_base', 0)
                  ->unique('code_frais', 'types_frais', 'code_frais');

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            $id = $this->typeFraisModel->create([
                'code_frais'      => strtoupper($data['code_frais']),
                'nom_frais'       => $data['nom_frais'],
                'description'     => $data['description'] ?? null,
                'montant_base'    => $data['montant_base'],
                'est_obligatoire' => $data['est_obligatoire'] ?? true,
                'est_actif'       => true
            ]);

            $this->logActivity('CREATE_TYPE_FRAIS', 'Configuration', "Création type frais {$data['nom_frais']}");

            Response::created($this->typeFraisModel->find($id), 'Type de frais créé avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function updateTypeFrais($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.frais');

        $data = $this->getRequestData();

        try {
            $typeFrais = $this->typeFraisModel->find($id);
            if (!$typeFrais) {
                Response::notFound('Type de frais non trouvé');
            }

            $updateData = [];
            $allowed = ['nom_frais', 'description', 'montant_base', 'est_obligatoire', 'est_actif'];
            foreach ($allowed as $field) {
                if (isset($data[$field])) {
                    $updateData[$field] = $data[$field];
                }
            }

            $this->typeFraisModel->update($id, $updateData);
            $this->logActivity('UPDATE_TYPE_FRAIS', 'Configuration', "Modification type frais ID: $id");

            Response::updated($this->typeFraisModel->find($id));
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    // ==================== FRAIS DE SCOLARITÉ ====================

    public function getFraisScolarite() {
        AuthMiddleware::handle();

        try {
            $idFiliere      = $_GET['filiere'] ?? null;
            $idNiveau       = $_GET['niveau'] ?? null;
            $idAnnee        = $_GET['annee'] ?? null;

            if ($idFiliere && $idNiveau && $idAnnee) {
                $frais = $this->fraisModel->getFraisByFiliereNiveau($idFiliere, $idNiveau, $idAnnee);
                $total = $this->fraisModel->getMontantTotal($idFiliere, $idNiveau, $idAnnee);

                Response::success([
                    'frais'         => $frais,
                    'montant_total' => $total
                ]);
            } else {
                $frais = $this->fraisModel->all();
                Response::success($frais);
            }
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function createFraisScolarite() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.frais');

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required(['id_filiere', 'id_niveau', 'id_annee_academique', 'id_type_frais', 'montant', 'date_debut_validite', 'date_fin_validite'])
                  ->numeric('montant')
                  ->min('montant', 0)
                  ->date('date_debut_validite')
                  ->date('date_fin_validite');

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            // Vérifier unicité
            $existing = $this->db->fetchOne(
                "SELECT id_frais FROM frais_scolarite WHERE id_filiere = ? AND id_niveau = ? AND id_annee_academique = ? AND id_type_frais = ?",
                [$data['id_filiere'], $data['id_niveau'], $data['id_annee_academique'], $data['id_type_frais']]
            );

            if ($existing) {
                Response::error('Ces frais existent déjà pour cette combinaison filière/niveau/année', 400);
            }

            $id = $this->fraisModel->create([
                'id_filiere'           => $data['id_filiere'],
                'id_niveau'            => $data['id_niveau'],
                'id_annee_academique'  => $data['id_annee_academique'],
                'id_type_frais'        => $data['id_type_frais'],
                'montant'              => $data['montant'],
                'date_debut_validite'  => $data['date_debut_validite'],
                'date_fin_validite'    => $data['date_fin_validite'],
                'est_actif'            => true
            ]);

            $this->logActivity('CREATE_FRAIS', 'Configuration', "Création frais scolarité ID: $id");

            Response::created($this->fraisModel->find($id), 'Frais de scolarité créés avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function updateFraisScolarite($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.frais');

        $data = $this->getRequestData();

        try {
            $frais = $this->fraisModel->find($id);
            if (!$frais) {
                Response::notFound('Frais de scolarité non trouvés');
            }

            $updateData = [];
            $allowed = ['montant', 'date_debut_validite', 'date_fin_validite', 'est_actif'];
            foreach ($allowed as $field) {
                if (isset($data[$field])) {
                    $updateData[$field] = $data[$field];
                }
            }

            $this->fraisModel->update($id, $updateData);
            $this->logActivity('UPDATE_FRAIS', 'Configuration', "Modification frais scolarité ID: $id");

            Response::updated($this->fraisModel->find($id));
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    // ==================== NIVEAUX ====================

    public function getNiveaux() {
        AuthMiddleware::handle();

        try {
            $niveaux = $this->niveauModel->getAllNiveaux();
            Response::success($niveaux);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function createNiveau() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.filieres');

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required(['code_niveau', 'nom_niveau', 'ordre'])
                  ->numeric('ordre')
                  ->unique('code_niveau', 'niveaux', 'code_niveau');

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            $id = $this->niveauModel->create([
                'code_niveau' => strtoupper($data['code_niveau']),
                'nom_niveau'  => $data['nom_niveau'],
                'ordre'       => $data['ordre'],
                'description' => $data['description'] ?? null,
                'est_actif'   => true
            ]);

            $this->logActivity('CREATE_NIVEAU', 'Configuration', "Création niveau {$data['nom_niveau']}");
            Response::created($this->niveauModel->find($id), 'Niveau créé avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    // ==================== FACULTÉS & DÉPARTEMENTS ====================

    public function getFacultes() {
        AuthMiddleware::handle();

        try {
            $facultes = $this->db->fetchAll(
                "SELECT * FROM facultes WHERE est_actif = TRUE ORDER BY nom_faculte"
            );
            Response::success($facultes);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function createFaculte() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.filieres');

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required(['code_faculte', 'nom_faculte'])
                  ->unique('code_faculte', 'facultes', 'code_faculte');

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            $id = $this->db->insert(
                "INSERT INTO facultes (code_faculte, nom_faculte, description, doyen, email, telephone, est_actif)
                 VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                [
                    strtoupper($data['code_faculte']),
                    $data['nom_faculte'],
                    $data['description'] ?? null,
                    $data['doyen'] ?? null,
                    $data['email'] ?? null,
                    $data['telephone'] ?? null
                ]
            );

            $this->logActivity('CREATE_FACULTE', 'Configuration', "Création faculté {$data['nom_faculte']}");

            $faculte = $this->db->fetchOne("SELECT * FROM facultes WHERE id_faculte = ?", [$id]);
            Response::created($faculte, 'Faculté créée avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function getDepartements() {
        AuthMiddleware::handle();

        try {
            $idFaculte = $_GET['faculte'] ?? null;

            if ($idFaculte) {
                $departements = $this->db->fetchAll(
                    "SELECT d.*, f.nom_faculte FROM departements d
                     JOIN facultes f ON d.id_faculte = f.id_faculte
                     WHERE d.id_faculte = ? AND d.est_actif = TRUE ORDER BY d.nom_departement",
                    [$idFaculte]
                );
            } else {
                $departements = $this->db->fetchAll(
                    "SELECT d.*, f.nom_faculte FROM departements d
                     JOIN facultes f ON d.id_faculte = f.id_faculte
                     WHERE d.est_actif = TRUE ORDER BY d.nom_departement"
                );
            }

            Response::success($departements);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function createDepartement() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.filieres');

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required(['code_departement', 'nom_departement', 'id_faculte'])
                  ->unique('code_departement', 'departements', 'code_departement');

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            $id = $this->db->insert(
                "INSERT INTO departements (code_departement, nom_departement, id_faculte, chef_departement, email, telephone, est_actif)
                 VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                [
                    strtoupper($data['code_departement']),
                    $data['nom_departement'],
                    $data['id_faculte'],
                    $data['chef_departement'] ?? null,
                    $data['email'] ?? null,
                    $data['telephone'] ?? null
                ]
            );

            $this->logActivity('CREATE_DEPARTEMENT', 'Configuration', "Création département {$data['nom_departement']}");

            $departement = $this->db->fetchOne(
                "SELECT d.*, f.nom_faculte FROM departements d JOIN facultes f ON d.id_faculte = f.id_faculte WHERE d.id_departement = ?",
                [$id]
            );

            Response::created($departement, 'Département créé avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    // ==================== MODES DE PAIEMENT ====================

    public function getModesPaiement() {
        AuthMiddleware::handle();

        try {
            $modes = $this->db->fetchAll(
                "SELECT * FROM modes_paiement WHERE est_actif = TRUE ORDER BY nom_mode"
            );
            Response::success($modes);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    // ==================== RÔLES & PERMISSIONS ====================

    public function getRoles() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.read');

        try {
            $roles = $this->roleModel->getAllRoles();
            Response::success($roles);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function getRolePermissions($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.read');

        try {
            $role = $this->roleModel->getRoleWithPermissions($id);
            if (!$role) {
                Response::notFound('Rôle non trouvé');
            }
            Response::success($role);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function assignPermissions($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasRole(ROLE_ADMIN);

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required('permissions');

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            $role = $this->roleModel->find($id);
            if (!$role) {
                Response::notFound('Rôle non trouvé');
            }

            $this->roleModel->assignPermissions($id, $data['permissions']);
            $this->logActivity('ASSIGN_PERMISSIONS', 'Configuration', "Attribution permissions rôle ID: $id");

            Response::success(null, 'Permissions attribuées avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function getPermissions() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('user.read');

        try {
            $permissions = $this->permissionModel->getPermissionsByModule();
            Response::success($permissions);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}
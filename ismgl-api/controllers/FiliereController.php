<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../middleware/RoleMiddleware.php';
require_once __DIR__ . '/../models/FiliereModel.php';

class FiliereController extends Controller {
    private $filiereModel;

    public function __construct() {
        parent::__construct();
        $this->filiereModel = new FiliereModel();
    }

    public function index() {
        AuthMiddleware::handle();

        try {
            $filieres = $this->filiereModel->getAllFilieres();
            Response::success($filieres);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function show($id) {
        AuthMiddleware::handle();

        try {
            $filiere = $this->filiereModel->getFiliereComplete($id);
            if (!$filiere) {
                Response::notFound('Filière non trouvée');
            }
            Response::success($filiere);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function store() {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.filieres');

        $data = $this->getRequestData();

        $validator = new Validator($data);
        $validator->required(['code_filiere', 'nom_filiere', 'id_departement', 'duree_etudes'])
                  ->numeric('duree_etudes')
                  ->unique('code_filiere', 'filieres', 'code_filiere');

        if ($validator->fails()) {
            Response::validationError($validator->errors());
        }

        try {
            $id = $this->filiereModel->create([
                'code_filiere'    => strtoupper($data['code_filiere']),
                'nom_filiere'     => $data['nom_filiere'],
                'id_departement'  => $data['id_departement'],
                'diplome_delivre' => $data['diplome_delivre'] ?? null,
                'duree_etudes'    => $data['duree_etudes'],
                'description'     => $data['description'] ?? null,
                'est_actif'       => true
            ]);

            $this->logActivity('CREATE_FILIERE', 'Configuration', "Création filière {$data['nom_filiere']}");

            $filiere = $this->filiereModel->getFiliereComplete($id);
            Response::created($filiere, 'Filière créée avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function update($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.filieres');

        $data = $this->getRequestData();

        try {
            $filiere = $this->filiereModel->find($id);
            if (!$filiere) {
                Response::notFound('Filière non trouvée');
            }

            $updateData = [];
            $allowed = ['nom_filiere', 'id_departement', 'diplome_delivre', 'duree_etudes', 'description', 'est_actif'];
            foreach ($allowed as $field) {
                if (isset($data[$field])) {
                    $updateData[$field] = $data[$field];
                }
            }

            $this->filiereModel->update($id, $updateData);
            $this->logActivity('UPDATE_FILIERE', 'Configuration', "Modification filière ID: $id");

            $updated = $this->filiereModel->getFiliereComplete($id);
            Response::updated($updated);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function delete($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('config.filieres');

        try {
            $filiere = $this->filiereModel->find($id);
            if (!$filiere) {
                Response::notFound('Filière non trouvée');
            }

            // Soft delete
            $this->filiereModel->update($id, ['est_actif' => false]);
            $this->logActivity('DELETE_FILIERE', 'Configuration', "Suppression filière ID: $id");

            Response::deleted('Filière désactivée avec succès');
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function byDepartement($idDepartement) {
        AuthMiddleware::handle();

        try {
            $filieres = $this->filiereModel->getFilieresByDepartement($idDepartement);
            Response::success($filieres);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }

    public function byFaculte($idFaculte) {
        AuthMiddleware::handle();

        try {
            $filieres = $this->filiereModel->getFilieresByFaculte($idFaculte);
            Response::success($filieres);
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}
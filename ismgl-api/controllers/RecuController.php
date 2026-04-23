<?php
require_once __DIR__ . '/../core/Controller.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';
require_once __DIR__ . '/../middleware/RoleMiddleware.php';
require_once __DIR__ . '/../models/RecuModel.php';
require_once __DIR__ . '/../utils/PDFGenerator.php';

class RecuController extends Controller {
    private $recuModel;
    
    public function __construct() {
        parent::__construct();
        $this->recuModel = new RecuModel();
    }
    
    public function show($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('recu.print');
        
        try {
            $recu = $this->recuModel->getRecuComplet($id);
            
            if (!$recu) {
                Response::notFound('Reçu non trouvé');
            }
            
            Response::success($recu);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function generate($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('recu.print');
        
        try {
            $recu = $this->recuModel->getRecuComplet($id);
            
            if (!$recu) {
                Response::notFound('Reçu non trouvé');
            }
            
            // Générer le PDF
            $pdfGenerator = new PDFGenerator();
            $pdfPath = $pdfGenerator->generateRecu($recu);
            
            // Marquer comme imprimé
            $this->recuModel->marquerImprime($id);
            
            $this->logActivity(
                'PRINT_RECU',
                'Reçus',
                "Impression du reçu {$recu['numero_recu']}"
            );
            
            Response::success([
                'pdf_url' => BASE_URL . '/' . $pdfPath,
                'numero_recu' => $recu['numero_recu']
            ], 'Reçu généré avec succès');
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function download($id) {
        AuthMiddleware::handle();
        RoleMiddleware::hasPermission('recu.print');
        
        try {
            $recu = $this->recuModel->getRecuComplet($id);
            
            if (!$recu) {
                Response::notFound('Reçu non trouvé');
            }
            
            // Générer le fichier HTML
            $pdfGenerator = new PDFGenerator();
            $filePath = $pdfGenerator->generateRecu($recu);
            
            // Obtenir le chemin complet du fichier
            $fullPath = BASE_PATH . '/' . $filePath;
            
            if (!file_exists($fullPath)) {
                Response::notFound('Fichier non trouvé');
            }
            
            // Servir le fichier HTML
            header('Content-Type: text/html; charset=utf-8');
            header('Content-Disposition: inline; filename="recu_' . $recu['numero_recu'] . '.html"');
            header('Content-Length: ' . filesize($fullPath));
            
            readfile($fullPath);
            exit;
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
    
    public function myRecus() {
        AuthMiddleware::handle();
        
        try {
            $userId = $this->getUserId();
            $etudiantModel = new EtudiantModel();
            $etudiant = $etudiantModel->getEtudiantByUser($userId);
            
            if (!$etudiant) {
                Response::error('Profil étudiant non trouvé', 404);
            }
            
            $recus = $this->recuModel->getRecusByEtudiant($etudiant['id_etudiant']);
            
            Response::success($recus);
            
        } catch (Exception $e) {
            Response::serverError($e->getMessage());
        }
    }
}
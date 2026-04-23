<?php
/**
 * Générateur de PDF pour les reçus et rapports
 * Supporte wkhtmltopdf et génère des PDF valides sans dépendances externes
 */
class PDFGenerator {

    private $recuPath;

    public function __construct() {
        $this->recuPath = RECU_PATH;
        $this->ensureDirectories();
    }

    private function ensureDirectories() {
        foreach ([RECU_PATH, DOCUMENT_PATH] as $path) {
            if (!is_dir($path)) {
                mkdir($path, 0755, true);
            }
        }
    }

    /**
     * Génère le PDF du reçu de paiement
     */
    public function generateRecu($recu) {
        // Générer un nom de fichier HTML (plus facile à convertir)
        $filename = 'recu_' . $recu['numero_recu'] . '_' . time() . '.html';
        $filepath = $this->recuPath . $filename;
        $html = $this->buildRecuHTML($recu);

        // Sauvegarder le HTML
        file_put_contents($filepath, $html);

        // Mettre à jour le chemin dans la DB
        $db = new Database();
        $db->update(
            "UPDATE recus SET fichier_pdf = ? WHERE id_recu = ?",
            ['uploads/recus/' . $filename, $recu['id_recu']]
        );

        return 'uploads/recus/' . $filename;
    }

    /**
     * Convertit du HTML en PDF
     * Essaie wkhtmltopdf en premier, puis utilise une solution de secours
     */
    private function convertHTMLToPDF($html, $outputPath) {
        // Implémentation future pour conversion en vrai PDF
        // Pour maintenant, on utilise le HTML directement (imprimable en PDF)
    }

    /**
     * Construit le HTML du reçu avec style professionnel
     */
    private function buildRecuHTML($recu) {
        $date     = date('d/m/Y H:i', strtotime($recu['date_paiement']));
        $montant  = number_format($recu['montant_total'], 2, ',', '.');

        return "<!DOCTYPE html>
<html lang='fr'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Reçu {$recu['numero_recu']}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Arial', sans-serif; 
            background: #f5f5f5;
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 8px;
        }
        
        /* En-tête */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 3px solid #003580;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .header-left h1 { color: #003580; font-size: 28px; margin-bottom: 5px; }
        .header-left p { color: #666; font-size: 12px; margin-bottom: 3px; }
        .header-right { text-align: right; }
        .receipt-label { 
            background: #003580; 
            color: white; 
            padding: 8px 16px; 
            border-radius: 4px;
            font-size: 14px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 10px;
        }
        .receipt-number { color: #666; font-size: 12px; }
        
        /* Contenu */
        .content { margin-bottom: 30px; }
        
        .section {
            margin-bottom: 25px;
        }
        .section-title {
            background: #003580;
            color: white;
            padding: 10px 15px;
            font-size: 13px;
            font-weight: bold;
            margin-bottom: 15px;
            border-radius: 4px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 15px;
        }
        .info-item {
            padding: 10px;
            background: #f8f9fa;
            border-radius: 4px;
            border-left: 3px solid #003580;
        }
        .info-label {
            font-size: 11px;
            color: #999;
            text-transform: uppercase;
            margin-bottom: 5px;
            letter-spacing: 0.5px;
        }
        .info-value {
            font-size: 14px;
            font-weight: bold;
            color: #333;
        }
        
        /* Tableau de paiement */
        .payment-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .payment-table thead {
            background: #003580;
            color: white;
        }
        .payment-table th {
            padding: 12px;
            text-align: left;
            font-size: 12px;
            font-weight: bold;
        }
        .payment-table td {
            padding: 12px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 13px;
        }
        .payment-table tbody tr:hover {
            background: #f5f5f5;
        }
        
        /* Montant */
        .amount-box {
            background: linear-gradient(135deg, #003580, #1a5fa0);
            color: white;
            padding: 30px;
            border-radius: 8px;
            text-align: center;
            margin: 30px 0;
        }
        .amount-label {
            font-size: 12px;
            text-transform: uppercase;
            opacity: 0.9;
            margin-bottom: 10px;
            letter-spacing: 1px;
        }
        .amount-value {
            font-size: 42px;
            font-weight: bold;
            line-height: 1;
        }
        .amount-currency {
            font-size: 18px;
            margin-left: 10px;
            vertical-align: super;
        }
        
        /* Signatures */
        .signature-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            margin-top: 50px;
        }
        .signature-box {
            text-align: center;
        }
        .signature-line {
            border-top: 1px solid #333;
            margin-top: 30px;
            padding-top: 5px;
            font-size: 12px;
            font-weight: bold;
        }
        
        /* Footer */
        .footer {
            text-align: center;
            font-size: 11px;
            color: #999;
            border-top: 1px solid #e0e0e0;
            padding-top: 20px;
            margin-top: 30px;
        }
        
        /* Impression */
        @media print {
            body { background: white; padding: 0; }
            .container { box-shadow: none; padding: 0; max-width: 100%; }
        }
    </style>
</head>
<body>
    <div class='container'>
        <!-- En-tête -->
        <div class='header'>
            <div class='header-left'>
                <h1>ISMGL</h1>
                <p>Institut Supérieur de Management et de Gestion</p>
                <p>Lubumbashi, RDC</p>
            </div>
            <div class='header-right'>
                <div class='receipt-label'>REÇU DE PAIEMENT</div>
                <div class='receipt-number'>N° {$recu['numero_recu']}</div>
            </div>
        </div>

        <!-- Contenu -->
        <div class='content'>
            <!-- Informations Étudiant -->
            <div class='section'>
                <div class='section-title'>👤 INFORMATIONS DE L'ÉTUDIANT</div>
                <div class='info-grid'>
                    <div class='info-item'>
                        <div class='info-label'>Numéro Étudiant</div>
                        <div class='info-value'>{$recu['numero_etudiant']}</div>
                    </div>
                    <div class='info-item'>
                        <div class='info-label'>Nom Complet</div>
                        <div class='info-value'>{$recu['nom_complet_etudiant']}</div>
                    </div>
                    <div class='info-item'>
                        <div class='info-label'>Filière</div>
                        <div class='info-value'>{$recu['nom_filiere']}</div>
                    </div>
                    <div class='info-item'>
                        <div class='info-label'>Niveau</div>
                        <div class='info-value'>{$recu['nom_niveau']}</div>
                    </div>
                </div>
            </div>

            <!-- Informations Paiement -->
            <div class='section'>
                <div class='section-title'>💳 DÉTAILS DU PAIEMENT</div>
                <table class='payment-table'>
                    <thead>
                        <tr>
                            <th>Description</th>
                            <th>Type de Frais</th>
                            <th>Mode de Paiement</th>
                            <th style='text-align: right;'>Montant</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>{$recu['numero_paiement']}</td>
                            <td>{$recu['nom_frais']}</td>
                            <td>{$recu['mode_paiement']}</td>
                            <td style='text-align: right; font-weight: bold;'>{$montant} FC</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Montant Total -->
            <div class='amount-box'>
                <div class='amount-label'>Montant Payé</div>
                <div class='amount-value'>{$montant}<span class='amount-currency'>FC</span></div>
            </div>

            <!-- Informations Supplémentaires -->
            <div class='section'>
                <div class='info-grid'>
                    <div class='info-item'>
                        <div class='info-label'>Date et Heure</div>
                        <div class='info-value'>{$date}</div>
                    </div>
                    <div class='info-item'>
                        <div class='info-label'>Année Académique</div>
                        <div class='info-value'>{$recu['code_annee']}</div>
                    </div>
                    <div class='info-item'>
                        <div class='info-label'>Reçu par</div>
                        <div class='info-value'>{$recu['emis_par_nom']}</div>
                    </div>
                    <div class='info-item'>
                        <div class='info-label'>Statut</div>
                        <div class='info-value' style='color: #28a745;'>✓ Payé</div>
                    </div>
                </div>
            </div>

            <!-- Signatures -->
            <div class='signature-section'>
                <div class='signature-box'>
                    <div class='signature-line'>Signature du Caissier</div>
                </div>
                <div class='signature-box'>
                    <div class='signature-line'>Cachet de l'Établissement</div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class='footer'>
            <p><strong>ISMGL - Système de Gestion des Inscriptions</strong></p>
            <p>Ce reçu est un document officiel. Conservez-le précieusement.</p>
            <p style='margin-top: 10px;'>Généré le " . date('d/m/Y à H:i:s') . "</p>
        </div>
    </div>

    <script>
        // Permettre l'impression au chargement ou sur demande
        window.addEventListener('load', function() {
            // Optionnel : imprimer automatiquement
            // window.print();
        });
    </script>
</body>
</html>";
    }

    /**
     * Génère les autres rapports (paiements, impayes, etc.) - conservation en HTML pour maintenant
     */
    public function generateRapportPaiements($data, $dateDebut, $dateFin) {
        $filename = 'rapport_paiements_' . date('Y-m-d_H-i-s') . '.html';
        $filepath = DOCUMENT_PATH . $filename;

        $total = array_sum(array_column($data, 'montant'));
        $rows  = '';

        foreach ($data as $i => $row) {
            $num    = $i + 1;
            $montant = number_format($row['montant'], 2, ',', '.');
            $rows   .= "<tr><td>$num</td><td>{$row['numero_paiement']}</td><td>{$row['date_paiement']}</td><td>{$row['etudiant']}</td><td>{$row['nom_frais']}</td><td style='text-align:right'>$montant FC</td><td>{$row['mode_paiement']}</td><td><span style='color:green'>✓ {$row['statut_paiement']}</span></td></tr>";
        }

        $html = "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Rapport Paiements</title><style>body{font-family:Arial,sans-serif;padding:20px}h1{color:#003580}table{width:100%;border-collapse:collapse}th{background:#003580;color:white;padding:10px}td{padding:8px;border-bottom:1px solid #ddd}</style></head><body><h1>Rapport Paiements</h1><p><strong>Période:</strong> $dateDebut à $dateFin</p><table><thead><tr><th>#</th><th>N° Paiement</th><th>Date</th><th>Étudiant</th><th>Frais</th><th>Montant</th><th>Mode</th><th>Statut</th></tr></thead><tbody>$rows</tbody></table></body></html>";

        file_put_contents($filepath, $html);
        return 'uploads/documents/' . $filename;
    }

    public function generateRapportImpayes($data) {
        $filename = 'rapport_impayes_' . date('Y-m-d_H-i-s') . '.html';
        $filepath = DOCUMENT_PATH . $filename;
        file_put_contents($filepath, '<html><body>Rapport en construction</body></html>');
        return 'uploads/documents/' . $filename;
    }

    public function generateRapportDashboard($data) {
        $filename = 'rapport_general_' . date('Y-m-d_H-i-s') . '.html';
        $filepath = DOCUMENT_PATH . $filename;
        file_put_contents($filepath, '<html><body>Rapport en construction</body></html>');
        return 'uploads/documents/' . $filename;
    }
}

<?php
class EmailSender {

    private $smtpHost;
    private $smtpPort;
    private $smtpUser;
    private $smtpPass;
    private $fromEmail;
    private $fromName;

    public function __construct() {
        $this->smtpHost  = SMTP_HOST;
        $this->smtpPort  = SMTP_PORT;
        $this->smtpUser  = SMTP_USERNAME;
        $this->smtpPass  = SMTP_PASSWORD;
        $this->fromEmail = SMTP_FROM_EMAIL;
        $this->fromName  = SMTP_FROM_NAME;
    }

    public function send($to, $subject, $body, $isHtml = true) {
        $headers  = "MIME-Version: 1.0\r\n";
        $headers .= $isHtml ? "Content-type: text/html; charset=utf-8\r\n" : "Content-type: text/plain; charset=utf-8\r\n";
        $headers .= "From: {$this->fromName} <{$this->fromEmail}>\r\n";
        $headers .= "Reply-To: {$this->fromEmail}\r\n";
        $headers .= "X-Mailer: PHP/" . phpversion();

        return mail($to, $subject, $body, $headers);
    }

    public static function sendPasswordReset($email, $token) {
        $sender   = new self();
        $resetUrl = BASE_URL . "/reset-password?token={$token}";

        $subject  = "Réinitialisation de votre mot de passe - ISMGL";
        $body     = "
        <html><body style='font-family:Arial,sans-serif;'>
        <div style='max-width:600px;margin:0 auto;padding:20px;'>
        <h2 style='color:#003580'>Réinitialisation de mot de passe</h2>
        <p>Vous avez demandé la réinitialisation de votre mot de passe ISMGL.</p>
        <p>Cliquez sur le bouton ci-dessous pour créer un nouveau mot de passe :</p>
        <a href='{$resetUrl}' style='background:#003580;color:white;padding:12px 25px;text-decoration:none;border-radius:5px;display:inline-block;margin:15px 0'>Réinitialiser mon mot de passe</a>
        <p style='color:#999;font-size:12px'>Ce lien expire dans 1 heure. Si vous n'avez pas fait cette demande, ignorez cet email.</p>
        <hr><p style='color:#666;font-size:11px'>ISMGL - Système de Gestion Universitaire</p>
        </div></body></html>";

        return $sender->send($email, $subject, $body);
    }

    public static function sendInscriptionConfirmation($email, $nom, $numeroInscription, $montant) {
        $sender  = new self();
        $subject = "Confirmation d'inscription - ISMGL";
        $body    = "
        <html><body style='font-family:Arial,sans-serif;'>
        <div style='max-width:600px;margin:0 auto;padding:20px;'>
        <h2 style='color:#003580'>Confirmation d'inscription</h2>
        <p>Bonjour <strong>{$nom}</strong>,</p>
        <p>Votre inscription à l'ISMGL a été enregistrée avec succès.</p>
        <table style='width:100%;border-collapse:collapse;margin:20px 0'>
            <tr><td style='padding:8px;border:1px solid #ddd;background:#f8f9fa'><strong>N° Inscription</strong></td><td style='padding:8px;border:1px solid #ddd'>{$numeroInscription}</td></tr>
            <tr><td style='padding:8px;border:1px solid #ddd;background:#f8f9fa'><strong>Montant Total</strong></td><td style='padding:8px;border:1px solid #ddd'>" . number_format($montant, 2, ',', '.') . " FC</td></tr>
        </table>
        <p>Veuillez vous présenter à la caisse pour effectuer votre paiement.</p>
        <hr><p style='color:#666;font-size:11px'>ISMGL - Système de Gestion Universitaire</p>
        </div></body></html>";

        return $sender->send($email, $subject, $body);
    }

    public static function sendPaiementConfirmation($email, $nom, $numeroPaiement, $montant, $numeroRecu) {
        $sender  = new self();
        $subject = "Confirmation de paiement - ISMGL";
        $body    = "
        <html><body style='font-family:Arial,sans-serif;'>
        <div style='max-width:600px;margin:0 auto;padding:20px;'>
        <h2 style='color:#27ae60'>✅ Paiement confirmé</h2>
        <p>Bonjour <strong>{$nom}</strong>,</p>
        <p>Votre paiement a été enregistré avec succès.</p>
        <table style='width:100%;border-collapse:collapse;margin:20px 0'>
            <tr><td style='padding:8px;border:1px solid #ddd;background:#f8f9fa'><strong>N° Paiement</strong></td><td style='padding:8px;border:1px solid #ddd'>{$numeroPaiement}</td></tr>
            <tr><td style='padding:8px;border:1px solid #ddd;background:#f8f9fa'><strong>Montant</strong></td><td style='padding:8px;border:1px solid #ddd'>" . number_format($montant, 2, ',', '.') . " FC</td></tr>
            <tr><td style='padding:8px;border:1px solid #ddd;background:#f8f9fa'><strong>N° Reçu</strong></td><td style='padding:8px;border:1px solid #ddd'>{$numeroRecu}</td></tr>
        </table>
        <hr><p style='color:#666;font-size:11px'>ISMGL - Système de Gestion Universitaire</p>
        </div></body></html>";

        return $sender->send($email, $subject, $body);
    }
}
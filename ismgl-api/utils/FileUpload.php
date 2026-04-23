<?php
class FileUpload {

    private $maxSize;
    private $allowedImageTypes;
    private $allowedDocTypes;

    public function __construct() {
        $this->maxSize           = MAX_FILE_SIZE;
        $this->allowedImageTypes = ALLOWED_IMAGE_TYPES;
        $this->allowedDocTypes   = ALLOWED_DOCUMENT_TYPES;
    }

    public function uploadImage($file, $subfolder = 'photos') {
        $this->validateFile($file, $this->allowedImageTypes);

        $extension  = $this->getExtension($file['name']);
        $filename   = $this->generateFilename($extension);
        $uploadPath = UPLOAD_PATH . $subfolder . '/';

        $this->ensureDirectory($uploadPath);

        $destination = $uploadPath . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            throw new Exception('Erreur lors de l\'upload du fichier');
        }

        return 'uploads/' . $subfolder . '/' . $filename;
    }

    public function uploadDocument($file, $subfolder = 'documents') {
        $this->validateFile($file, $this->allowedDocTypes);

        $extension  = $this->getExtension($file['name']);
        $filename   = $this->generateFilename($extension);
        $uploadPath = UPLOAD_PATH . $subfolder . '/';

        $this->ensureDirectory($uploadPath);

        $destination = $uploadPath . $filename;

        if (!move_uploaded_file($file['tmp_name'], $destination)) {
            throw new Exception('Erreur lors de l\'upload du document');
        }

        return 'uploads/' . $subfolder . '/' . $filename;
    }

    public function deleteFile($filePath) {
        $fullPath = BASE_PATH . '/' . $filePath;

        if (file_exists($fullPath)) {
            return unlink($fullPath);
        }

        return false;
    }

    private function validateFile($file, $allowedTypes) {
        if (!isset($file) || $file['error'] !== UPLOAD_ERR_OK) {
            throw new Exception('Fichier invalide ou erreur d\'upload. Code: ' . ($file['error'] ?? 'inconnu'));
        }

        if ($file['size'] > $this->maxSize) {
            $maxMB = $this->maxSize / 1048576;
            throw new Exception("Le fichier dépasse la taille maximale autorisée ({$maxMB}MB)");
        }

        $finfo    = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);

        if (!in_array($mimeType, $allowedTypes)) {
            throw new Exception('Type de fichier non autorisé: ' . $mimeType);
        }
    }

    private function generateFilename($extension) {
        return uniqid('file_', true) . '_' . time() . '.' . $extension;
    }

    private function getExtension($filename) {
        return strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    }

    private function ensureDirectory($path) {
        if (!is_dir($path)) {
            mkdir($path, 0755, true);
        }
    }
}
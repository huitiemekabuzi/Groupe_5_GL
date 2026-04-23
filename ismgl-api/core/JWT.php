<?php
class JWT {
    
    public static function encode($payload) {
        $header = json_encode(['typ' => 'JWT', 'alg' => JWT_ALGORITHM]);
        
        $payload['iat'] = time();
        $payload['exp'] = time() + JWT_EXPIRATION;
        $payload = json_encode($payload);
        
        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);
        
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, JWT_SECRET_KEY, true);
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }
    
    public static function decode($jwt) {
        $tokenParts = explode('.', $jwt);
        
        if (count($tokenParts) !== 3) {
            throw new Exception('Token invalide');
        }
        
        $header = base64_decode($tokenParts[0]);
        $payload = base64_decode($tokenParts[1]);
        $signatureProvided = $tokenParts[2];
        
        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, JWT_SECRET_KEY, true);
        $base64UrlSignature = self::base64UrlEncode($signature);
        
        if ($base64UrlSignature !== $signatureProvided) {
            throw new Exception('Signature invalide');
        }
        
        $payload = json_decode($payload, true);
        
        if (!isset($payload['exp']) || $payload['exp'] < time()) {
            throw new Exception('Token expiré');
        }
        
        return $payload;
    }
    
    public static function generateRefreshToken() {
        return bin2hex(random_bytes(32));
    }
    
    private static function base64UrlEncode($text) {
        return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($text));
    }
    
    public static function getAuthorizationToken() {
        $authHeader = self::getAuthorizationHeader();
        if (!$authHeader) {
            return null;
        }

        $authHeader = trim($authHeader);
        $matches = [];
        if (!preg_match('/^\s*Bearer\s+(.+)\s*$/i', $authHeader, $matches)) {
            return null;
        }

        $token = trim($matches[1], " \t\n\r\0\x0B\"'");
        return $token !== '' ? $token : null;
    }
    
    public static function getCurrentUser() {
        try {
            $token = self::getAuthorizationToken();
            if (!$token) {
                return null;
            }
            
            $payload = self::decode($token);
            return $payload;
        } catch (Exception $e) {
            return null;
        }
    }

    private static function getAuthorizationHeader() {
        // 1) Lire les headers HTTP sous forme insensible a la casse.
        if (function_exists('getallheaders')) {
            $headers = getallheaders();
            if (is_array($headers)) {
                foreach ($headers as $key => $value) {
                    if (strtolower((string) $key) === 'authorization' && !empty($value)) {
                        return (string) $value;
                    }
                }
            }
        }

        // 2) Fallback Apache (souvent necessaire sous Windows/XAMPP).
        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            if (is_array($headers)) {
                foreach ($headers as $key => $value) {
                    if (strtolower((string) $key) === 'authorization' && !empty($value)) {
                        return (string) $value;
                    }
                }
            }
        }

        // 3) Variables serveur frequentes selon stack web.
        $serverKeys = [
            'HTTP_AUTHORIZATION',
            'REDIRECT_HTTP_AUTHORIZATION',
            'Authorization'
        ];

        foreach ($serverKeys as $key) {
            if (!empty($_SERVER[$key])) {
                return (string) $_SERVER[$key];
            }
        }

        return null;
    }
}
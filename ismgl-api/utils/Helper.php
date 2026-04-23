<?php
class Helper {

    public static function sanitize($data) {
        if (is_array($data)) {
            return array_map([self::class, 'sanitize'], $data);
        }
        return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
    }

    public static function formatDate($date, $format = 'd/m/Y') {
        if (!$date) return 'N/A';
        return date($format, strtotime($date));
    }

    public static function formatMontant($montant, $devise = 'FC') {
        return number_format($montant, 2, ',', '.') . ' ' . $devise;
    }

    public static function generateCode($prefix, $length = 6) {
        return strtoupper($prefix) . str_pad(mt_rand(1, pow(10, $length) - 1), $length, '0', STR_PAD_LEFT);
    }

    public static function slugify($text) {
        $text = preg_replace('~[^\pL\d]+~u', '-', $text);
        $text = iconv('utf-8', 'us-ascii//TRANSLIT', $text);
        $text = preg_replace('~[^-\w]+~', '', $text);
        $text = trim($text, '-');
        $text = preg_replace('~-+~', '-', $text);
        return strtolower($text);
    }

    public static function paginate($total, $page, $pageSize) {
        return [
            'total'       => (int)$total,
            'page'        => (int)$page,
            'page_size'   => (int)$pageSize,
            'total_pages' => (int)ceil($total / $pageSize),
            'offset'      => ($page - 1) * $pageSize
        ];
    }

    public static function isValidDate($date, $format = 'Y-m-d') {
        $d = DateTime::createFromFormat($format, $date);
        return $d && $d->format($format) === $date;
    }

    public static function generatePassword($length = 12) {
        $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$!';
        return substr(str_shuffle(str_repeat($chars, ceil($length / strlen($chars)))), 0, $length);
    }

    public static function maskEmail($email) {
        [$local, $domain] = explode('@', $email);
        $masked = substr($local, 0, 2) . str_repeat('*', max(strlen($local) - 2, 1));
        return $masked . '@' . $domain;
    }

    public static function jsonResponse($success, $message, $data = null, $code = 200) {
        return [
            'success'     => $success,
            'message'     => $message,
            'data'        => $data,
            'status_code' => $code,
            'timestamp'   => date('Y-m-d H:i:s')
        ];
    }

    public static function getClientIP() {
        $keys = ['HTTP_X_FORWARDED_FOR', 'HTTP_CLIENT_IP', 'REMOTE_ADDR'];
        foreach ($keys as $key) {
            if (!empty($_SERVER[$key])) {
                return explode(',', $_SERVER[$key])[0];
            }
        }
        return '0.0.0.0';
    }
}
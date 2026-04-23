<?php
class Validator {
    private $errors = [];
    private $data = [];
    
    public function __construct($data) {
        $this->data = $data;
    }
    
    public function required($fields) {
        foreach ((array)$fields as $field) {
            if (!isset($this->data[$field]) || trim($this->data[$field]) === '') {
                $this->errors[$field] = "Le champ $field est requis";
            }
        }
        return $this;
    }
    
    public function email($field) {
        if (isset($this->data[$field]) && !filter_var($this->data[$field], FILTER_VALIDATE_EMAIL)) {
            $this->errors[$field] = "L'email n'est pas valide";
        }
        return $this;
    }
    
    public function minLength($field, $length) {
        if (isset($this->data[$field]) && strlen($this->data[$field]) < $length) {
            $this->errors[$field] = "Le champ $field doit contenir au moins $length caractères";
        }
        return $this;
    }
    
    public function maxLength($field, $length) {
        if (isset($this->data[$field]) && strlen($this->data[$field]) > $length) {
            $this->errors[$field] = "Le champ $field ne doit pas dépasser $length caractères";
        }
        return $this;
    }
    
    public function numeric($field) {
        if (isset($this->data[$field]) && !is_numeric($this->data[$field])) {
            $this->errors[$field] = "Le champ $field doit être numérique";
        }
        return $this;
    }
    
    public function min($field, $min) {
        if (isset($this->data[$field]) && $this->data[$field] < $min) {
            $this->errors[$field] = "Le champ $field doit être supérieur ou égal à $min";
        }
        return $this;
    }
    
    public function max($field, $max) {
        if (isset($this->data[$field]) && $this->data[$field] > $max) {
            $this->errors[$field] = "Le champ $field doit être inférieur ou égal à $max";
        }
        return $this;
    }
    
    public function in($field, $values) {
        if (isset($this->data[$field]) && !in_array($this->data[$field], $values)) {
            $this->errors[$field] = "Le champ $field doit être l'une des valeurs: " . implode(', ', $values);
        }
        return $this;
    }
    
    public function date($field, $format = 'Y-m-d') {
        if (isset($this->data[$field])) {
            $d = DateTime::createFromFormat($format, $this->data[$field]);
            if (!$d || $d->format($format) !== $this->data[$field]) {
                $this->errors[$field] = "Le champ $field n'est pas une date valide (format: $format)";
            }
        }
        return $this;
    }
    
    public function phone($field) {
        if (isset($this->data[$field])) {
            $pattern = '/^(\+243|0)[0-9]{9}$/';
            if (!preg_match($pattern, $this->data[$field])) {
                $this->errors[$field] = "Le numéro de téléphone n'est pas valide";
            }
        }
        return $this;
    }
    
    public function unique($field, $table, $column, $excludeId = null) {
        if (isset($this->data[$field])) {
            $db = new Database();
            $sql = "SELECT COUNT(*) FROM $table WHERE $column = ?";
            $params = [$this->data[$field]];
            
            if ($excludeId) {
                $sql .= " AND id != ?";
                $params[] = $excludeId;
            }
            
            $count = $db->fetchColumn($sql, $params);
            if ($count > 0) {
                $this->errors[$field] = "Cette valeur existe déjà";
            }
        }
        return $this;
    }
    
    public function password($field) {
        if (isset($this->data[$field])) {
            $password = $this->data[$field];
            $errors = [];
            
            if (strlen($password) < PASSWORD_MIN_LENGTH) {
                $errors[] = "au moins " . PASSWORD_MIN_LENGTH . " caractères";
            }
            if (!preg_match('/[A-Z]/', $password)) {
                $errors[] = "au moins une majuscule";
            }
            if (!preg_match('/[a-z]/', $password)) {
                $errors[] = "au moins une minuscule";
            }
            if (!preg_match('/[0-9]/', $password)) {
                $errors[] = "au moins un chiffre";
            }
            if (!preg_match('/[^A-Za-z0-9]/', $password)) {
                $errors[] = "au moins un caractère spécial";
            }
            
            if (!empty($errors)) {
                $this->errors[$field] = "Le mot de passe doit contenir " . implode(', ', $errors);
            }
        }
        return $this;
    }
    
    public function custom($field, $callback, $message) {
        if (isset($this->data[$field]) && !$callback($this->data[$field])) {
            $this->errors[$field] = $message;
        }
        return $this;
    }
    
    public function fails() {
        return !empty($this->errors);
    }
    
    public function passes() {
        return empty($this->errors);
    }
    
    public function errors() {
        return $this->errors;
    }
    
    public static function validate($data, $rules) {
        $validator = new self($data);
        
        foreach ($rules as $field => $ruleSet) {
            $ruleArray = explode('|', $ruleSet);
            
            foreach ($ruleArray as $rule) {
                if (strpos($rule, ':') !== false) {
                    list($ruleName, $ruleValue) = explode(':', $rule, 2);
                    $ruleParams = explode(',', $ruleValue);
                } else {
                    $ruleName = $rule;
                    $ruleParams = [];
                }
                
                switch ($ruleName) {
                    case 'required':
                        $validator->required($field);
                        break;
                    case 'email':
                        $validator->email($field);
                        break;
                    case 'min':
                        $validator->minLength($field, $ruleParams[0]);
                        break;
                    case 'max':
                        $validator->maxLength($field, $ruleParams[0]);
                        break;
                    case 'numeric':
                        $validator->numeric($field);
                        break;
                    case 'date':
                        $validator->date($field, $ruleParams[0] ?? 'Y-m-d');
                        break;
                    case 'phone':
                        $validator->phone($field);
                        break;
                    case 'password':
                        $validator->password($field);
                        break;
                }
            }
        }
        
        return $validator;
    }
}
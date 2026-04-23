<?php
class Router {
    private $routes = [];
    private $prefix = '';
    
    public function __construct($prefix = '') {
        $this->prefix = $prefix;
    }
    
    public function get($path, $handler, $middleware = []) {
        $this->addRoute('GET', $path, $handler, $middleware);
    }
    
    public function post($path, $handler, $middleware = []) {
        $this->addRoute('POST', $path, $handler, $middleware);
    }
    
    public function put($path, $handler, $middleware = []) {
        $this->addRoute('PUT', $path, $handler, $middleware);
    }
    
    public function delete($path, $handler, $middleware = []) {
        $this->addRoute('DELETE', $path, $handler, $middleware);
    }
    
    public function patch($path, $handler, $middleware = []) {
        $this->addRoute('PATCH', $path, $handler, $middleware);
    }
    
    private function addRoute($method, $path, $handler, $middleware) {
        $fullPath = $this->prefix . $path;
        $this->routes[] = [
            'method' => $method,
            'path' => $fullPath,
            'handler' => $handler,
            'middleware' => $middleware
        ];
    }
    
    public function group($prefix, $callback) {
        $previousPrefix = $this->prefix;
        $this->prefix .= $prefix;
        $callback($this);
        $this->prefix = $previousPrefix;
    }
    
    public function dispatch() {
        $requestMethod = $_SERVER['REQUEST_METHOD'];
        $requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
        
        // Retirer le préfixe de base si nécessaire
        $basePath = str_replace('/index.php', '', $_SERVER['SCRIPT_NAME']);
        if (strpos($requestUri, $basePath) === 0) {
            $requestUri = substr($requestUri, strlen($basePath));
        }
        
        $requestUri = rtrim($requestUri, '/');
        if (empty($requestUri)) {
            $requestUri = '/';
        }
        
        foreach ($this->routes as $route) {
            if ($route['method'] !== $requestMethod) {
                continue;
            }
            
            $pattern = $this->convertPathToRegex($route['path']);
            
            if (preg_match($pattern, $requestUri, $matches)) {
                array_shift($matches); // Retirer la correspondance complète
                
                // Exécuter les middlewares
                foreach ($route['middleware'] as $middleware) {
                    if (is_callable($middleware)) {
                        $middleware();
                    } elseif (is_string($middleware) && strpos($middleware, '@') !== false) {
                        list($class, $method) = explode('@', $middleware);
                        if (class_exists($class) && method_exists($class, $method)) {
                            call_user_func([$class, $method]);
                        }
                    }
                }
                
                // Exécuter le handler
                return $this->executeHandler($route['handler'], $matches);
            }
        }
        
        // Route non trouvée
        Response::notFound('Route non trouvée');
    }
    
    private function convertPathToRegex($path) {
        // Convertir les paramètres de route comme {id} en regex
        $pattern = preg_replace('/\{([a-zA-Z0-9_]+)\}/', '([^/]+)', $path);
        $pattern = '#^' . $pattern . '$#';
        return $pattern;
    }
    
    private function executeHandler($handler, $params = []) {
        if (is_callable($handler)) {
            return call_user_func_array($handler, $params);
        }
        
        if (is_string($handler) && strpos($handler, '@') !== false) {
            list($class, $method) = explode('@', $handler);
            
            if (class_exists($class)) {
                $controller = new $class();
                
                if (method_exists($controller, $method)) {
                    return call_user_func_array([$controller, $method], $params);
                }
            }
        }
        
        Response::serverError('Handler invalide');
    }
}
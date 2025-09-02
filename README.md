# Bootcamp PHP (3h) — Construire une micro‑API MVC avec Fat‑Free Framework (F3)

### F3 (Fat‑Free Framework) en bref — pourquoi on l’utilise aujourd’hui

* **Micro & rapide à prendre en main** : cœur unique, très peu de magie, quasi zéro boilerplate.
* **Routing clair + MVC minimal** : on visualise immédiatement le flux *route → contrôleur → modèle*.
* **Mapper SQL intégré** : Data Mapper léger (SQLite/MySQL/PostgreSQL) pour un CRUD propre sans lourdeur.
* **Productif pour une API** : réponses JSON simples, hook `beforeroute` pour la protection, structure lisible.
* **Idéal en bootcamp** : focus sur les fondamentaux PHP web (sans framework « usine à gaz »), on comprend, on expérimente, on shippe vite.

---

## Résultats attendus

* Savoir **poser une structure minimale** de projet API en PHP.
* Manipuler **routing**, **contrôleurs**, **modèles** et **SQLite** avec F3.
* Exposer un **CRUD JSON** complet sur une ressource (ex. *notes*).
* Implémenter une **authentification stateless** par **JWT (Bearer)**.
* Documenter l’API (README minimal) + **tests curl** reproductibles.

---

## Pré‑requis matériels

* PHP ≥ 8.1, Composer
* SQLite3 installé (ou embarqué via PHP pdo\_sqlite)
* Un terminal + curl (ou Postman, Insomnia)

> Si vous partez **vraiment de zéro**, commencez par l’**Étape 0** ci‑dessous (install & outillage). Les autres peuvent la **skipper**.

---

## 0) Étape 0 — Environnement & outils (optionnelle)

### 0.1 Vérifier PHP & extensions

```bash
php -v            # attendre PHP >= 8.1
php -m | grep -i sqlite   # Linux/macOS : vérifier pdo_sqlite/sqlite3
php -m | grep -i openssl  # requis pour JWT
# Windows (PowerShell) :
php -m | findstr /I sqlite
php -m | findstr /I openssl
```

> Si `sqlite` n’apparaît pas : installez/activez **sqlite3/pdo\_sqlite** (selon OS). Si `openssl` manque : activez l’extension **openssl** (php.ini).

### 0.2 Installer Composer

* **macOS (Homebrew)** : `brew install php composer`
* **Linux (globale)** :

  ```bash
  php -r "copy('https://getcomposer.org/installer','composer-setup.php');"
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  composer -V
  ```
* **Windows** : installeur graphique sur getcomposer.org (ou `choco install composer`).

### 0.3 Visual Studio Code (recommandé)

Extensions utiles (facultatif mais confort) :

* **PHP Intelephense** (Lint & IntelliSense)
* **PHP Debug** (Xdebug – non nécessaire pour ce bootcamp, mais utile)
* **REST Client** *ou* **Thunder Client** (tester l’API sans quitter VS Code)
* **EditorConfig for VS Code** (style homogène)

### 0.4 Démarrer un dossier de projet

```bash
mkdir micro-api-f3 && cd micro-api-f3
# Optionnel : versionner
git init
printf "/vendor/\n/data/*.db\n/.env\n" > .gitignore

# Initialiser Composer et ajouter les dépendances dès maintenant
composer init -n
composer require bcosca/fatfree firebase/php-jwt
```

> On utilisera l’autoload de F3 (`AUTOLOAD app/`) et l’autoloader Composer pour les libs.

### 0.5 Terminal intégré & serveur local

Dans VS Code : **View → Terminal** pour ouvrir le terminal dans le dossier.
Le serveur PHP sera lancé **après** avoir créé `public/index.php` (Étape 1) :

```bash
php -S localhost:8000 -t public
```

### 0.6 Outils de test d’API

* **curl** (en ligne de commande) :

  ```bash
  curl -i http://localhost:8000/
  ```
* **REST Client** (VS Code) : créez `requests.http` :

  ```http
  GET http://localhost:8000/

  ###
  POST http://localhost:8000/auth/login
  Content-Type: application/json

  {"email":"a@b.com","password":"secret123"}
  ```

### 0.7 Dépannage express

* `Class 'Base' not found` → F3 non installé ou autoload manquant : `composer require bcosca/fatfree` et vérifiez `require vendor/autoload.php`.
* `404` sur `/` → vérifier le **document root** `-t public` et la présence de `public/index.php`.
* JWT/openssl → activer l’extension **openssl** dans `php.ini`.
* SQLite indisponible → installez **php-sqlite3/pdo\_sqlite**.
* Port occupé → `php -S localhost:8080 -t public`.

---

## 1) Démarrage express

```
mkdir micro-api-f3 && cd micro-api-f3
composer init -n
composer require bcosca/fatfree firebase/php-jwt
mkdir -p app/Controllers app/Models app/Services config public cli data
```

**config/config.php**

```php
<?php
return [
  'debug' => 3,
  // Ne JAMAIS faire ça en prod : secret hardcodé. Ici c’est un bootcamp.
  'jwt_secret' => 'dev-secret-change-me',
];
```

**public/index.php**

```php
<?php
require __DIR__.'/../vendor/autoload.php';

$f3 = Base::instance();
$config = require __DIR__.'/../config/config.php';

$f3->set('DEBUG', $config['debug']);
$f3->set('AUTOLOAD', 'app/');

// DB SQLite
$dbPath = __DIR__.'/../data/app.db';
$f3->set('DB', new DB\SQL('sqlite:'.$dbPath));
$f3->set('JWT_SECRET', $config['jwt_secret']);

// JSON par défaut
header('Content-Type: application/json');

// CORS minimal (pour tests front)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Authorization, Content-Type');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }

require __DIR__.'/../routes.php';
$f3->run();
```

**routes.php**

```php
<?php
// Health
$f3->route('GET /', function() { echo json_encode(['ok'=>true]); });

// Auth (public)
$f3->route('POST /auth/register', 'Controllers\\AuthController->register');
$f3->route('POST /auth/login',    'Controllers\\AuthController->login');

// Notes (protégé via beforeroute du contrôleur)
$f3->route('GET    /api/v1/notes',        'Controllers\\NoteController->index');
$f3->route('GET    /api/v1/notes/@id',    'Controllers\\NoteController->show');
$f3->route('POST   /api/v1/notes',        'Controllers\\NoteController->store');
$f3->route('PUT    /api/v1/notes/@id',    'Controllers\\NoteController->update');
$f3->route('DELETE /api/v1/notes/@id',    'Controllers\\NoteController->destroy');
```

**Lancer le serveur**

```
php -S localhost:8000 -t public
# → GET http://localhost:8000/ retourne {"ok":true}
```

---

## 2) Migration rapide (création des tables)

**cli/migrate.php**

```php
<?php
require __DIR__.'/../vendor/autoload.php';
$f3 = Base::instance();
$f3->set('DB', new DB\SQL('sqlite:'.__DIR__.'/../data/app.db'));
$db = $f3->get('DB');
$db->exec('CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL
)');
$db->exec('CREATE TABLE IF NOT EXISTS notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  content TEXT DEFAULT "",
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY(user_id) REFERENCES users(id)
)');
echo "✅ Migrated\n";
```

```
php cli/migrate.php
```

---

## 3) Modèles (Mapper minimal)

**app/Models/UserModel.php**

```php
<?php
namespace Models; use DB\SQL;

class UserModel {
  private SQL $db;
  public function __construct(SQL $db) { $this->db = $db; }

  public function create(string $email, string $passwordHash): array {
    $now = gmdate('c');
    $this->db->exec('INSERT INTO users(email,password_hash,created_at) VALUES(?,?,?)', [$email,$passwordHash,$now]);
    $id = (int)$this->db->lastInsertId();
    return $this->findById($id);
  }
  public function findByEmail(string $email): ?array {
    $rows = $this->db->exec('SELECT id,email,password_hash,created_at FROM users WHERE email=?', [$email]);
    return $rows[0] ?? null;
  }
  public function findById(int $id): ?array {
    $rows = $this->db->exec('SELECT id,email,created_at FROM users WHERE id=?', [$id]);
    return $rows[0] ?? null;
  }
}
```

**app/Models/NoteModel.php**

```php
<?php
namespace Models; use DB\SQL;

class NoteModel {
  private SQL $db;
  public function __construct(SQL $db) { $this->db = $db; }

  public function allByUser(int $userId, int $limit=50, int $offset=0): array {
    return $this->db->exec('SELECT id,title,content,created_at,updated_at FROM notes WHERE user_id=? ORDER BY id DESC LIMIT ? OFFSET ?', [$userId,$limit,$offset]);
  }
  public function find(int $userId, int $id): ?array {
    $rows = $this->db->exec('SELECT id,title,content,created_at,updated_at FROM notes WHERE user_id=? AND id=?', [$userId,$id]);
    return $rows[0] ?? null;
  }
  public function create(int $userId, array $data): array {
    $now = gmdate('c');
    $title = trim($data['title'] ?? '');
    $content = (string)($data['content'] ?? '');
    $this->db->exec('INSERT INTO notes(user_id,title,content,created_at,updated_at) VALUES(?,?,?,?,?)', [$userId,$title,$content,$now,$now]);
    $id = (int)$this->db->lastInsertId();
    return $this->find($userId,$id);
  }
  public function update(int $userId, int $id, array $data): ?array {
    $note = $this->find($userId,$id); if(!$note) return null;
    $title = trim($data['title'] ?? $note['title']);
    $content = array_key_exists('content',$data) ? (string)$data['content'] : $note['content'];
    $now = gmdate('c');
    $this->db->exec('UPDATE notes SET title=?, content=?, updated_at=? WHERE id=? AND user_id=?', [$title,$content,$now,$id,$userId]);
    return $this->find($userId,$id);
  }
  public function delete(int $userId, int $id): bool {
    $res = $this->db->exec('DELETE FROM notes WHERE id=? AND user_id=?', [$id,$userId]);
    return ($res !== false);
  }
}
```

---

## 4) Service Auth (JWT)

**app/Services/AuthService.php**

```php
<?php
namespace Services; use Firebase\JWT\JWT; use Firebase\JWT\Key; use Base; use Exception;

class AuthService {
  public static function tokenFor(int $userId): string {
    $f3 = Base::instance();
    $payload = [
      'sub' => $userId,
      'iat' => time(),
      'exp' => time()+3600*8 // 8h
    ];
    return JWT::encode($payload, $f3->get('JWT_SECRET'), 'HS256');
  }

  public static function userIdOrNull(): ?int {
    $f3 = Base::instance();
    $hdr = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (!preg_match('/Bearer\s+(.*)$/i', $hdr, $m)) return null;
    try {
      $decoded = JWT::decode($m[1], new Key($f3->get('JWT_SECRET'), 'HS256'));
      return (int)($decoded->sub ?? 0) ?: null;
    } catch (Exception $e) { return null; }
  }
}
```

---

## 5) Contrôleurs

**app/Controllers/AuthController.php**

```php
<?php
namespace Controllers; use Base; use Models\UserModel; use Services\AuthService;

class AuthController {
  private UserModel $users;
  public function __construct() {
    $this->users = new UserModel(Base::instance()->get('DB'));
  }

  public function register() {
    $input = json_decode(file_get_contents('php://input'), true) ?? [];
    $email = strtolower(trim($input['email'] ?? ''));
    $pass = (string)($input['password'] ?? '');
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($pass) < 6) {
      http_response_code(422);
      echo json_encode(['error'=>'email/password invalid']); return;
    }
    if ($this->users->findByEmail($email)) {
      http_response_code(409); echo json_encode(['error'=>'email exists']); return;
    }
    $user = $this->users->create($email, password_hash($pass, PASSWORD_DEFAULT));
    $token = AuthService::tokenFor((int)$user['id']);
    echo json_encode(['token'=>$token,'user'=>$user]);
  }

  public function login() {
    $input = json_decode(file_get_contents('php://input'), true) ?? [];
    $email = strtolower(trim($input['email'] ?? ''));
    $pass = (string)($input['password'] ?? '');
    $row = (new UserModel(Base::instance()->get('DB')))->findByEmail($email);
    if (!$row || !password_verify($pass, $row['password_hash'])) {
      http_response_code(401); echo json_encode(['error'=>'invalid credentials']); return;
    }
    $user = ['id'=>$row['id'],'email'=>$row['email'],'created_at'=>$row['created_at']];
    $token = AuthService::tokenFor((int)$row['id']);
    echo json_encode(['token'=>$token,'user'=>$user]);
  }
}
```

**app/Controllers/NoteController.php**

```php
<?php
namespace Controllers; use Base; use Models\NoteModel; use Services\AuthService;

class NoteController {
  private NoteModel $notes; private ?int $userId = null;
  public function __construct(){ $this->notes = new NoteModel(Base::instance()->get('DB')); }

  // Hook appelé avant chaque action du contrôleur
  public function beforeroute() {
    $this->userId = AuthService::userIdOrNull();
    if (!$this->userId) { http_response_code(401); echo json_encode(['error'=>'unauthorized']); exit; }
  }

  public function index() {
    $f3 = Base::instance();
    $limit = (int)($f3->get('GET.limit') ?? 50);
    $offset= (int)($f3->get('GET.offset') ?? 0);
    echo json_encode($this->notes->allByUser($this->userId,$limit,$offset));
  }
  public function show($f3, $params) {
    $note = $this->notes->find($this->userId, (int)$params['id']);
    if (!$note) { http_response_code(404); echo json_encode(['error'=>'not found']); return; }
    echo json_encode($note);
  }
  public function store() {
    $in = json_decode(file_get_contents('php://input'), true) ?? [];
    if (!isset($in['title']) || trim($in['title'])==='') { http_response_code(422); echo json_encode(['error'=>'title required']); return; }
    echo json_encode($this->notes->create($this->userId, $in));
  }
  public function update($f3, $params) {
    $in = json_decode(file_get_contents('php://input'), true) ?? [];
    $note = $this->notes->update($this->userId, (int)$params['id'], $in);
    if (!$note) { http_response_code(404); echo json_encode(['error'=>'not found']); return; }
    echo json_encode($note);
  }
  public function destroy($f3, $params) {
    $ok = $this->notes->delete($this->userId, (int)$params['id']);
    if (!$ok) { http_response_code(404); echo json_encode(['error'=>'not found']); return; }
    echo json_encode(['deleted'=>true]);
  }
}
```

---

## 6) Scénario d’atelier (pas à pas)

1. **Hello F3** : route `/` qui renvoie `{ok:true}`.
2. **Migration** : exécuter `php cli/migrate.php`.
3. **Auth** : tester `POST /auth/register` puis `POST /auth/login` pour récupérer un token.
4. **CRUD Notes** (avec header `Authorization: Bearer <token>`):

   * `POST /api/v1/notes` `{ "title": "Ma 1ère note", "content": "Bonjour" }`
   * `GET  /api/v1/notes`
   * `GET  /api/v1/notes/1`
   * `PUT  /api/v1/notes/1` `{ "content": "Edit" }`
   * `DELETE /api/v1/notes/1`
5. **Durcir** : codes d’erreurs cohérents, validation, pagination `?limit=...&offset=...`, CORS.
6. **README** : endpoints, exemples curl, comment lancer.

---

## 7) Batteries de tests (copier/coller)

**Inscription & Login**

```
curl -s -X POST http://localhost:8000/auth/register \
 -H 'Content-Type: application/json' \
 -d '{"email":"alice@example.com","password":"secret123"}' | jq

TOKEN=$(curl -s -X POST http://localhost:8000/auth/login \
 -H 'Content-Type: application/json' \
 -d '{"email":"alice@example.com","password":"secret123"}' | jq -r .token)

echo $TOKEN
```

**CRUD Notes**

```
# Create
curl -s -X POST http://localhost:8000/api/v1/notes \
 -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
 -d '{"title":"Todo","content":"Acheter du café"}' | jq

# List
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/v1/notes | jq

# Show
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/v1/notes/1 | jq

# Update
curl -s -X PUT http://localhost:8000/api/v1/notes/1 \
 -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
 -d '{"content":"Café moulu"}' | jq

# Delete
curl -s -X DELETE -H "Authorization: Bearer $TOKEN" http://localhost:8000/api/v1/notes/1 | jq
```

---

## 8) Critères de réussite (évaluation rapide)

* ✅ Lancement projet + README (setup clair, migrations, run)
* ✅ Endpoints CRUD fonctionnels, codes HTTP justes, JSON propre
* ✅ Auth JWT opérationnelle (register/login, routes protégées)
* ✅ Tests curl reproductibles (copier/coller OK)
* ✅ Qualité : gestion d’erreurs, validation basique, structure lisible

**Bonus** (si temps) : recherche `q=...`, tri/pagination, `PATCH`, rate limiting simple, refresh token, tests unitaires (Pest/PhpUnit), Dockerfile, CI.

---

## 9) Variantes & pistes d’extension

* **Ressource alternative** : `tasks`, `books`, `contacts`…
* **Slim 4 + Eloquent** (option avancée) si vous voulez comparer à F3.
* **Sécurité** : règles CORS fines, hash Argon2id, verrouillage bruteforce (compteur), `SameSite` si cookies.
* **Observabilité** : logs structurés (monolog), temps de réponse, ID requête.
* **Packaging** : `.env` + Dotenv, Docker Compose (php-fpm + nginx + sqlite volume).

---

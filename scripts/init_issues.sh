#!/usr/bin/env bash
set -e

REPO="benoit-bremaud/decouverte_F3"
ME="benoit-bremaud"
PROJECT_NUM=34

echo "==> Création (idempotente) des labels"
gh label create "type:feat"  --repo "$REPO" --description "Nouvelle fonctionnalité / Feature"    --color "0E8A16" || true
gh label create "type:chore" --repo "$REPO" --description "Tâche technique / Chore"              --color "5319E7" || true
gh label create "type:docs"  --repo "$REPO" --description "Documentation / Docs"                 --color "0075CA" || true
gh label create "prio:P1"    --repo "$REPO" --description "Priorité haute / Must-have"           --color "D73A4A" || true
gh label create "prio:P2"    --repo "$REPO" --description "Priorité moyenne / Should-have"       --color "FFA500" || true
gh label create "prio:P3"    --repo "$REPO" --description "Priorité basse / Nice-to-have"        --color "FBCA04" || true

add_to_project () {
  local url="$1"
  gh project item-add "$PROJECT_NUM" --owner "$ME" --url "$url" >/dev/null
  echo "   ↳ ajoutée au Project #$PROJECT_NUM"
}

echo "==> Milestone: Boot & Environnement"

echo "1) Préparer l’environnement et le socle du projet"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Préparer l’environnement et le socle du projet" \
  --assignee "$ME" \
  --label "type:chore,prio:P1" \
  --milestone "Boot & Environnement" \
  --body $'Préparer l’environnement de dev (PHP, Composer) et initialiser la structure du projet.\n\n### Tâches\n- [ ] PHP ≥ 8.1 avec extensions sqlite3/openssl\n- [ ] Composer installé (`composer -V`)\n- [ ] `composer init -n` puis `composer require bcosca/fatfree firebase/php-jwt`\n- [ ] Créer la structure: `app/`, `public/`, `config/`, `cli/`, `data/`, `tmp/`\n- [ ] `.gitignore` (vendor/, data/*.db, .env, tmp/*)\n\n### AC\n- `php -S localhost:8000 -t public` OK\n- Endpoint racine renvoie `{ \"ok\": true }`' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "2) Docker & configuration de base (dev)"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Docker & configuration de base (dev)" \
  --assignee "$ME" \
  --label "type:chore,prio:P1" \
  --milestone "Boot & Environnement" \
  --body $'Mettre en place Docker (PHP-FPM + Nginx) et Composer.\n\n### Tâches\n- [ ] `docker-compose.yml` (services: app php-fpm, web nginx)\n- [ ] `docker/php/Dockerfile` (php:8.3-fpm + composer + ext intl/zip/sqlite)\n- [ ] `docker/nginx/default.conf` (root public/, try_files, pass php-fpm)\n- [ ] Doc rapide dans README (up/build, URLs)\n\n### AC\n- `docker compose up -d --build` → http://localhost:8080 répond\n- `docker compose exec app composer --version` OK' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "==> Milestone: Routing & Bootstrap F3"

echo "3) Initialiser F3 et ajouter la route de santé"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Initialiser F3 et ajouter la route de santé" \
  --assignee "$ME" \
  --label "type:feat,prio:P1" \
  --milestone "Routing & Bootstrap F3" \
  --body $'Installer et câbler F3, exposer un endpoint de santé.\n\n### Tâches\n- [ ] `public/index.php` (autoload composer, Base::instance(), DEBUG, JSON/CORS)\n- [ ] `config/config.php` (vars DEBUG, TEMP=tmp/, UI, JWT_SECRET dev)\n- [ ] `routes.php` chargé par index\n- [ ] Route `GET /` → `{ "ok": true }`\n\n### AC\n- `curl http://localhost:8080/` → `{ "ok": true }`' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "==> Milestone: Persistence (SQLite)"

echo "4) Mettre en place la base SQLite et le script de migration"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Mettre en place la base SQLite et le script de migration" \
  --assignee "$ME" \
  --label "type:feat,prio:P1" \
  --milestone "Persistence (SQLite)" \
  --body $'Créer le schéma et l’initialisation de la base SQLite.\n\n### Tâches\n- [ ] `cli/migrate.php` (création tables `users`, `notes`)\n- [ ] Connexion `DB\\SQL("sqlite:./data/app.db")`\n- [ ] Foreign key notes.user_id → users.id\n\n### AC\n- `php cli/migrate.php` → ✅ Migrated\n- `data/app.db` créé' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "5) Implémenter les modèles de données (User et Note)"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Implémenter les modèles de données (User et Note)" \
  --assignee "$ME" \
  --label "type:feat,prio:P1" \
  --milestone "Persistence (SQLite)" \
  --body $'Créer des modèles simples pour accéder à SQLite.\n\n### Tâches\n- [ ] `app/Models/UserModel.php` (create, findByEmail, findById)\n- [ ] `app/Models/NoteModel.php` (allByUser, find, create, update, delete)\n- [ ] Requêtes préparées, gestion erreurs\n\n### AC\n- Méthodes testées rapidement depuis un script/contrôleur' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "==> Milestone: Authentification (JWT)"

echo "6) Implémenter le service d’authentification JWT"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Implémenter le service d’authentification JWT" \
  --assignee "$ME" \
  --label "type:feat,prio:P1" \
  --milestone "Authentification (JWT)" \
  --body $'Gestion des tokens stateless (HS256, exp ~8h).\n\n### Tâches\n- [ ] `app/Services/AuthService.php` (`tokenFor(userId)`, `userIdOrNull()`)\n- [ ] Utiliser `firebase/php-jwt` et `JWT_SECRET`\n- [ ] Gérer exceptions/invalid token → null\n\n### AC\n- Génération et parsing OK dans un test simple' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "7) Implémenter les endpoints d’inscription et de login"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Implémenter les endpoints d’inscription et de login" \
  --assignee "$ME" \
  --label "type:feat,prio:P1" \
  --milestone "Authentification (JWT)" \
  --body $'Création des routes publiques pour gérer les comptes.\n\n### Tâches\n- [ ] `app/Controllers/AuthController.php` (`register()`, `login()`)\n- [ ] `POST /auth/register` : email valide, mdp ≥ 6, 409 si email existe, hash mdp, retourne `{ user, token }`\n- [ ] `POST /auth/login` : 401 si creds invalides, sinon `{ user, token }`\n- [ ] Déclarer routes dans `routes.php`\n\n### AC\n- Tests curl/.http : register/login OK, erreurs 401/409/422 cohérentes' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "==> Milestone: Ressource Notes (CRUD)"

echo "8) Implémenter l’API CRUD pour les notes (contrôleur + routes)"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Implémenter l’API CRUD pour les notes (contrôleur + routes)" \
  --assignee "$ME" \
  --label "type:feat,prio:P1" \
  --milestone "Ressource Notes (CRUD)" \
  --body $'Endpoints REST pour la ressource Notes, protégés par JWT.\n\n### Tâches\n- [ ] `app/Controllers/NoteController.php` (beforeroute → check JWT)\n- [ ] Routes: `GET /api/v1/notes`, `GET /api/v1/notes/@id`, `POST /api/v1/notes`, `PUT /api/v1/notes/@id`, `DELETE /api/v1/notes/@id`\n- [ ] `index()` (pagination ?limit=&offset=), `show`, `store` (titre requis), `update`, `destroy`\n\n### AC\n- CRUD complet OK avec Authorization: Bearer <token>\n- Codes 200/201/204/401/404/422 cohérents' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "==> Milestone: Qualité & Robustesse"

echo "9) Améliorer la validation et la gestion d’erreurs"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Améliorer la validation et la gestion d’erreurs" \
  --assignee "$ME" \
  --label "type:chore,prio:P2" \
  --milestone "Qualité & Robustesse" \
  --body $'Uniformiser les validations et les réponses d’erreur JSON.\n\n### Tâches\n- [ ] Entrées invalides → 422 (ex. titre manquant, email invalide, mdp < 6)\n- [ ] 401 sans token ou token invalide, 404 si ressource absente, 409 email en doublon\n- [ ] Format d’erreur homogène `{ "error": "message" }`\n- [ ] Cas d’erreurs testés (curl/.http)\n\n### AC\n- Réponses d’erreurs prévisibles et documentées' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "==> Milestone: Packaging & DX"

echo "10) Rédiger le README du projet (installation, endpoints, exemples)"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Rédiger le README du projet (installation, endpoints, exemples)" \
  --assignee "$ME" \
  --label "type:docs,prio:P2" \
  --milestone "Packaging & DX" \
  --body $'Documenter l’installation et l’usage de l’API.\n\n### Tâches\n- [ ] Installation (prérequis, composer, migration, serveur local)\n- [ ] Tableau des endpoints (auth + notes), formats de réponses/erreurs\n- [ ] Exemples curl/.http pour chaque endpoint\n\n### AC\n- Un dev lambda peut cloner, lancer et tester en < 5 min' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "11) Améliorer le packaging et l’expérience développeur"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Améliorer le packaging et l’expérience développeur" \
  --assignee "$ME" \
  --label "type:chore,prio:P3" \
  --milestone "Packaging & DX" \
  --body $'Confort de dev et reproductibilité.\n\n### Tâches\n- [ ] `.env` et chargement des variables (JWT_SECRET, etc.)\n- [ ] DevContainer VS Code (reopen in container)\n- [ ] (Bonus) CI GitHub Actions (composer install + smoke test)\n\n### AC\n- DX améliorée, doc mise à jour' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "==> Milestone: Extras (stretch)"

echo "12) Bonus : recherche q= sur notes et rate limiting simple"
ISSUE_URL=$(gh issue create --repo "$REPO" \
  --title "Bonus : recherche \`q=\` sur notes et rate limiting simple" \
  --assignee "$ME" \
  --label "type:feat,prio:P3" \
  --milestone "Extras (stretch)" \
  --body $'Fonctionnalités bonus.\n\n### Tâches\n- [ ] `GET /api/v1/notes?q=...` (filtre LIKE titre/contenu)\n- [ ] Tri optionnel (ex. `sort=created_at`)\n- [ ] Rate limiting basique (N req/min par IP/token) → 429 au-delà\n\n### AC\n- Recherche opérationnelle\n- 429 renvoyé en cas d’abus' \
); echo "   → $ISSUE_URL"; add_to_project "$ISSUE_URL"

echo "✅ Fini ! Toutes les issues sont créées, assignées, milestonées et ajoutées au Project #$PROJECT_NUM."

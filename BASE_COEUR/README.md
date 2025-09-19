# Stack PostgreSQL + pgAdmin (Docker) — Schéma Projet/Site/... + Unités

## Contenu
- `docker-compose.yml` : services PostgreSQL et pgAdmin.
- `.env` : variables d'environnement (base, utilisateurs, mots de passe). **Créez ce fichier avec les variables suivantes :**
  ```
  POSTGRES_DB=db_coeur
  POSTGRES_USER=postgres
  POSTGRES_PASSWORD=postgres
  PGADMIN_DEFAULT_EMAIL=admin@example.com
  PGADMIN_DEFAULT_PASSWORD=admin123
  ```
- `postgres/initdb/*.sql` : scripts d'initialisation exécutés **une seule fois** lors de la création du volume.
  L'ordre est garanti par la numérotation.

## Ordre d'exécution des scripts
1. `01_unites.sql`             — DOMAINs (m², m, €, %, qty).
2. `02_unites_table.sql`       — Table `unite` (référentiel des unités + conversions).
3. `03_schema.sql`             — Tables métier (projet/site/.../economie) avec FKs.
4. `04_views.sql`              — Vues de lecture (economie, projet, site).
5. `05_comments.sql`           — Documentation des colonnes.
6. `90_seed_unites.sql`        — Jeu minimal d'unités.

## Démarrage
```bash
docker compose up -d
```

- PostgreSQL : port `5432` (host) → `postgres:5432` (container)
- pgAdmin   : http://localhost:8080  (login et mot de passe depuis `.env`)

**Connexion pgAdmin au serveur Postgres :**
- Host: `postgres` (nom du service Docker)
- Port: `5432`
- User/Password: `${POSTGRES_USER}` / `${POSTGRES_PASSWORD}`
- DB: `${POSTGRES_DB}`

## Avertissements
- Ces scripts `initdb` s'exécutent **une seule fois** (première création de volume). Pour rejouer :
  ```bash
  docker compose down -v
  docker compose up -d
  ```
- Remplacez immédiatement les mots de passe de `.env`.
- Pour la production : ajoutez sauvegardes, chiffrement, reverse proxy HTTPS, gestion des rôles, etc.

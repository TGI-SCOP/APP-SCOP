
-- Création des rôles et comptes : admin (applicatif), read-write, read-only
-- Hypothèses :
--   - Base: celle retournée par current_database()
--   - Schéma: public
--   - Exécution après la création du schéma/objets (ordre 06_* dans initdb)
--   - Exécuter en tant que propriétaire de la base (POSTGRES_USER) ou superuser

/* =====================================================================
   0) Sécurité de base : retirer des droits à PUBLIC
   ===================================================================== */
DO $$
DECLARE db text := current_database();
BEGIN
   EXECUTE format('REVOKE ALL ON DATABASE %I FROM PUBLIC', db);
END $$;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

/* =====================================================================
   1) Rôles "groupe" (NOLOGIN) pour factoriser les privilèges
   ===================================================================== */
DO $$ BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'DB_COEUR_admin') THEN
      CREATE ROLE DB_COEUR_admin NOLOGIN;
   END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'DB_COEUR_rw') THEN
      CREATE ROLE DB_COEUR_rw NOLOGIN;
   END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'DB_COEUR_ro') THEN
      CREATE ROLE DB_COEUR_ro NOLOGIN;
   END IF;
END $$;

/* =====================================================================
   2) Comptes "LOGIN"
      - u_admin : administrateur applicatif (création rôles & DB), PAS SUPERUSER
      - u_rw    : lecture/écriture
      - u_ro    : lecture seule
   ===================================================================== */
DO $$ BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'user_admin') THEN
      CREATE ROLE u_admin LOGIN INHERIT CREATEDB CREATEROLE PASSWORD 'DB_COEUR_ADMIN123';
      -- Si vous exigez SUPERUSER (déconseillé) : ALTER ROLE u_admin WITH SUPERUSER;
   END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'user_rw') THEN
      CREATE ROLE u_rw    LOGIN INHERIT PASSWORD 'DB_COEUR_ADMIN123';
   END IF;
   IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'user_ro') THEN
      CREATE ROLE u_ro    LOGIN INHERIT PASSWORD 'DB_COEUR_ADMIN123';
   END IF;
END $$;

/* =====================================================================
   3) Appartenances aux rôles "groupe"
   ===================================================================== */
GRANT DB_COEUR_admin TO u_admin;
GRANT DB_COEUR_rw    TO u_rw;
GRANT DB_COEUR_ro    TO u_ro;

/* =====================================================================
   4) Droits au niveau base et schéma
   ===================================================================== */
DO $$
DECLARE db text := current_database();
BEGIN
   EXECUTE format('GRANT CONNECT, TEMP ON DATABASE %I TO DB_COEUR_admin, DB_COEUR_rw, DB_COEUR_ro', db);
   EXECUTE format('GRANT CREATE ON DATABASE %I TO DB_COEUR_admin', db);
END $$;

GRANT USAGE, CREATE ON SCHEMA public TO DB_COEUR_admin;
GRANT USAGE ON SCHEMA public TO DB_COEUR_rw, DB_COEUR_ro;

/* =====================================================================
   5) Droits sur les objets EXISTANTS (tables, vues, séquences, fonctions)
   ===================================================================== */
-- Tables & vues
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO DB_COEUR_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO DB_COEUR_rw;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO DB_COEUR_ro;

-- Séquences (SERIAL/IDENTITY)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO DB_COEUR_admin;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO DB_COEUR_rw;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO DB_COEUR_ro;

-- Fonctions
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO DB_COEUR_admin, DB_COEUR_rw, DB_COEUR_ro;

/* =====================================================================
   6) Droits par DÉFAUT pour les futurs objets
   NOTE : Ces privilèges par défaut s'appliqueront aux objets créés ensuite
          par l'OWNER qui exécute ce script.
   ===================================================================== */
ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT ALL PRIVILEGES ON TABLES TO DB_COEUR_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO DB_COEUR_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT SELECT ON TABLES TO DB_COEUR_ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT ALL PRIVILEGES ON SEQUENCES TO DB_COEUR_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO DB_COEUR_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT USAGE, SELECT ON SEQUENCES TO DB_COEUR_ro;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
   GRANT EXECUTE ON FUNCTIONS TO DB_COEUR_admin, DB_COEUR_rw, DB_COEUR_ro;

/* =====================================================================
   7) Recommandations
   - Changez immédiatement les mots de passe :
       ALTER ROLE u_admin WITH PASSWORD '...';
       ALTER ROLE u_rw    WITH PASSWORD '...';
       ALTER ROLE u_ro    WITH PASSWORD '...';
   - Si vous créez d'autres schémas (ex. metier), dupliquez ces GRANT/ALTER DEFAULT PRIVILEGES.
   - Exécutez ce script connecté à la base courante (current_database()) ou via initdb en 06_*.
   ===================================================================== */

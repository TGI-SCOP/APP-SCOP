
-- NOTE:
-- La base est créée par l'entrypoint Docker via la variable d'environnement POSTGRES_DB.
-- Ce script s'exécute dans la base déjà créée. Aucune création/connexion explicite ici.

CREATE SCHEMA IF NOT EXISTS public;

-- Si vous souhaitez ajouter un commentaire sur la base, utilisez un bloc dynamique:
-- DO $$
-- DECLARE db text := current_database();
-- BEGIN
--   EXECUTE format('COMMENT ON DATABASE %I IS %L', db, 'Base de données principale du système COEUR');
-- END $$;

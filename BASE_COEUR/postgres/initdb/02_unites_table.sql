-- Table de référence des unités utilisables pour ECONOMIE.quantite
CREATE TABLE unite (
  id                   SERIAL PRIMARY KEY,
  code                 TEXT NOT NULL UNIQUE,         -- ex. 'm2', 'm', 'kg', 'u', 'm3', 'L'
  libelle              TEXT NOT NULL,                -- ex. 'mètre carré', 'mètre', ...
  dimension            TEXT NOT NULL,                -- 'surface' | 'longueur' | 'masse' | 'volume' | 'compte'
  factor_to_canonical  NUMERIC(18,10) NOT NULL CHECK (factor_to_canonical > 0),
  offset_to_canonical  NUMERIC(18,10) NOT NULL DEFAULT 0
);

COMMENT ON TABLE unite IS 'Référentiel des unités, avec conversion vers l’unité canonique par dimension';
COMMENT ON COLUMN unite.code IS 'Code court unique (ex. m2, m, kg, u, m3, L)';
COMMENT ON COLUMN unite.dimension IS 'Dimension physique: surface/longueur/masse/volume/compte';
COMMENT ON COLUMN unite.factor_to_canonical IS 'Facteur multiplicatif vers l’unité canonique';
COMMENT ON COLUMN unite.offset_to_canonical IS 'Décalage additif vers l’unité canonique (souvent 0)';

CREATE INDEX IF NOT EXISTS idx_unite_dimension ON unite(dimension);

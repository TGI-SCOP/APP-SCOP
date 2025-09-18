-- Tables métier
CREATE TABLE projet (
  id SERIAL PRIMARY KEY,
  nom                VARCHAR(255),
  client             VARCHAR(255),
  surface_utile      m2,
  surface_de_planche m2,
  adresse            TEXT,
  budget_moa         eur,
  destination        VARCHAR(255)
);

CREATE TABLE site (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(255),
  projet_id INT NOT NULL REFERENCES projet(id) ON DELETE CASCADE
);

CREATE TABLE batiment (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(255),
  site_id INT NOT NULL REFERENCES site(id) ON DELETE CASCADE
);

CREATE TABLE etage (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(255),
  elevation m,
  batiment_id INT NOT NULL REFERENCES batiment(id) ON DELETE CASCADE
);

CREATE TABLE espace (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(255),
  surface m2,
  etage_id INT NOT NULL REFERENCES etage(id) ON DELETE CASCADE
);

CREATE TABLE piece (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(255),
  surface m2,
  espace_id INT NOT NULL REFERENCES espace(id) ON DELETE CASCADE
);

CREATE TABLE element (
  id SERIAL PRIMARY KEY,
  categorie   VARCHAR(100),
  designation VARCHAR(255),
  materiau    VARCHAR(100),
  notes       TEXT,
  piece_id INT NOT NULL REFERENCES piece(id) ON DELETE CASCADE
);

CREATE TABLE economie (
  id SERIAL PRIMARY KEY,
  libelle         VARCHAR(255),
  lot_theorique   VARCHAR(100),
  lot_reel        VARCHAR(100),
  description     TEXT,
  produit         VARCHAR(100),
  pu              eur,
  quantite_val    NUMERIC(12,4) NOT NULL CHECK (quantite_val >= 0),
  quantite_unite_id INT NOT NULL REFERENCES unite(id),
  tva             pct,
  localisation    VARCHAR(255),
  projet_id       INT NOT NULL REFERENCES projet(id) ON DELETE CASCADE
);

-- Index utiles
CREATE INDEX IF NOT EXISTS idx_site_projet      ON site(projet_id);
CREATE INDEX IF NOT EXISTS idx_batiment_site    ON batiment(site_id);
CREATE INDEX IF NOT EXISTS idx_etage_batiment   ON etage(batiment_id);
CREATE INDEX IF NOT EXISTS idx_espace_etage     ON espace(etage_id);
CREATE INDEX IF NOT EXISTS idx_piece_espace     ON piece(espace_id);
CREATE INDEX IF NOT EXISTS idx_element_piece    ON element(piece_id);
CREATE INDEX IF NOT EXISTS idx_economie_projet  ON economie(projet_id);
CREATE INDEX IF NOT EXISTS idx_economie_unite   ON economie(quantite_unite_id);

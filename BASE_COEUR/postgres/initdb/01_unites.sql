-- DOMAINs = unités canoniques
CREATE DOMAIN m2  AS numeric(12,2) CHECK (VALUE >= 0);
CREATE DOMAIN m   AS numeric(12,3) CHECK (VALUE >= -10000);
CREATE DOMAIN eur AS numeric(14,2) CHECK (VALUE >= 0);
CREATE DOMAIN pct AS numeric(5,2)  CHECK (VALUE BETWEEN 0 AND 100);
CREATE DOMAIN qty AS numeric(12,2) CHECK (VALUE >= 0);

COMMENT ON DOMAIN m2  IS 'Surface en mètres carrés (m²)';
COMMENT ON DOMAIN m   IS 'Longueur en mètres (m)';
COMMENT ON DOMAIN eur IS 'Montant en euros (€)';
COMMENT ON DOMAIN pct IS 'Pourcentage (0–100)';
COMMENT ON DOMAIN qty IS 'Quantité (unité métier)';

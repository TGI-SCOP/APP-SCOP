-- Jeu minimal d’unités et conversions

INSERT INTO unite(code, libelle, dimension, factor_to_canonical, offset_to_canonical) VALUES
  -- SURFACE (canonique: m2)
  ('m2',  'mètre carré',      'surface', 1,           0),
  ('cm2', 'centimètre carré', 'surface', 0.0001,      0),
  ('ft2', 'pied carré',       'surface', 0.09290304,  0),

  -- LONGUEUR (canonique: m)
  ('m',   'mètre',            'longueur', 1,          0),
  ('cm',  'centimètre',       'longueur', 0.01,       0),
  ('mm',  'millimètre',       'longueur', 0.001,      0),

  -- VOLUME (canonique: m3)
  ('m3',  'mètre cube',       'volume',   1,          0),
  ('L',   'litre',            'volume',   0.001,      0),

  -- MASSE (canonique: kg)
  ('kg',  'kilogramme',       'masse',    1,          0),
  ('g',   'gramme',           'masse',    0.001,      0),

  -- COMPTE (canonique: u)
  ('u',   'unité',            'compte',   1,          0)
ON CONFLICT (code) DO NOTHING;

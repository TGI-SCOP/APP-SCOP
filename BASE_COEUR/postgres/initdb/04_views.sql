-- 1) Vue utilitaire : économie + conversion de quantité
CREATE OR REPLACE VIEW v_economie_quantite_normalisee AS
SELECT
  e.id,
  e.projet_id,
  e.libelle,
  e.produit,
  e.lot_theorique,
  e.lot_reel,
  e.description,
  e.pu,
  e.quantite_val,
  u.code        AS quantite_unite,
  u.dimension,
  (e.quantite_val * u.factor_to_canonical + u.offset_to_canonical) AS quantite_canonique,
  CASE u.dimension
    WHEN 'surface'  THEN 'm2'
    WHEN 'longueur' THEN 'm'
    WHEN 'masse'    THEN 'kg'
    WHEN 'volume'   THEN 'm3'
    WHEN 'compte'   THEN 'u'
    ELSE 'canonique'
  END AS unite_canonique,
  e.tva,
  e.localisation,
  e.quantite_unite_id,
  e.id AS economie_id
FROM economie e
JOIN unite u ON u.id = e.quantite_unite_id;

COMMENT ON VIEW v_economie_quantite_normalisee
  IS 'Économie jointe aux unités, avec quantité convertie vers l’unité canonique.';

-- 2) Vue ECO enrichie
CREATE OR REPLACE VIEW v_economie AS
SELECT
  e.id,
  e.projet_id,
  p.nom AS projet_nom,
  e.libelle,
  e.produit,
  e.lot_theorique,
  e.lot_reel,
  e.description,
  e.pu,
  e.quantite_val,
  u.code        AS quantite_unite,
  u.dimension,
  (e.quantite_val * u.factor_to_canonical + u.offset_to_canonical) AS quantite_canonique,
  CASE u.dimension
    WHEN 'surface'  THEN 'm2'
    WHEN 'longueur' THEN 'm'
    WHEN 'masse'    THEN 'kg'
    WHEN 'volume'   THEN 'm3'
    WHEN 'compte'   THEN 'u'
    ELSE 'canonique'
  END AS unite_canonique,
  e.tva AS tva_pct,
  (e.pu * e.quantite_val)                                     AS montant_ht,
  (e.pu * e.quantite_val * (COALESCE(e.tva,0) / 100.0))       AS montant_tva,
  (e.pu * e.quantite_val * (1 + (COALESCE(e.tva,0) / 100.0))) AS montant_ttc,
  e.localisation,
  e.quantite_unite_id
FROM economie e
JOIN unite  u ON u.id = e.quantite_unite_id
JOIN projet p ON p.id = e.projet_id;

COMMENT ON VIEW v_economie
  IS 'Économie enrichie : libellés projet, unité, quantités normalisées et montants HT/TVA/TTC.';

-- 3) Vue PROJET (synthèse)
CREATE OR REPLACE VIEW v_projet AS
SELECT
  p.id,
  p.nom,
  p.client,
  p.surface_utile,
  p.surface_de_planche,
  p.adresse,
  p.budget_moa,
  p.destination,

  (SELECT COUNT(*) FROM site s WHERE s.projet_id = p.id) AS nb_sites,

  (SELECT COUNT(*)
     FROM batiment b
     JOIN site s ON s.id = b.site_id
    WHERE s.projet_id = p.id) AS nb_batiments,

  (SELECT COUNT(*)
     FROM etage et
     JOIN batiment b ON b.id = et.batiment_id
     JOIN site s     ON s.id = b.site_id
    WHERE s.projet_id = p.id) AS nb_etages,

  (SELECT COUNT(*)
     FROM espace es
     JOIN etage et   ON et.id = es.etage_id
     JOIN batiment b ON b.id = et.batiment_id
     JOIN site s     ON s.id = b.site_id
    WHERE s.projet_id = p.id) AS nb_espaces,

  (SELECT COUNT(*)
     FROM piece pi
     JOIN espace es  ON es.id = pi.espace_id
     JOIN etage et   ON et.id = es.etage_id
     JOIN batiment b ON b.id = et.batiment_id
     JOIN site s     ON s.id = b.site_id
    WHERE s.projet_id = p.id) AS nb_pieces,

  (SELECT COUNT(*)
     FROM element el
     JOIN piece pi   ON pi.id = el.piece_id
     JOIN espace es  ON es.id = pi.espace_id
     JOIN etage et   ON et.id = es.etage_id
     JOIN batiment b ON b.id = et.batiment_id
     JOIN site s     ON s.id = b.site_id
    WHERE s.projet_id = p.id) AS nb_elements,

  COALESCE( (SELECT SUM(e.pu * e.quantite_val)
               FROM economie e
              WHERE e.projet_id = p.id), 0 ) AS total_ht,

  COALESCE( (SELECT SUM(e.pu * e.quantite_val * (COALESCE(e.tva,0)/100.0))
               FROM economie e
              WHERE e.projet_id = p.id), 0 ) AS total_tva,

  COALESCE( (SELECT SUM(e.pu * e.quantite_val * (1 + (COALESCE(e.tva,0)/100.0)))
               FROM economie e
              WHERE e.projet_id = p.id), 0 ) AS total_ttc
FROM projet p;

COMMENT ON VIEW v_projet
  IS 'Synthèse projet : comptages hiérarchiques et totaux économiques (HT/TVA/TTC).';

-- 4) Vue SITE (synthèse par site)
CREATE OR REPLACE VIEW v_site AS
SELECT
  s.id,
  s.nom,
  s.projet_id,
  p.nom AS projet_nom,

  (SELECT COUNT(*) FROM batiment b WHERE b.site_id = s.id) AS nb_batiments,

  (SELECT COUNT(*)
     FROM etage et
    WHERE et.batiment_id IN (SELECT b.id FROM batiment b WHERE b.site_id = s.id)
  ) AS nb_etages,

  (SELECT COUNT(*)
     FROM espace es
     JOIN etage et ON et.id = es.etage_id
    WHERE et.batiment_id IN (SELECT b.id FROM batiment b WHERE b.site_id = s.id)
  ) AS nb_espaces,

  (SELECT COUNT(*)
     FROM piece pi
     JOIN espace es ON es.id = pi.espace_id
     JOIN etage et  ON et.id = es.etage_id
    WHERE et.batiment_id IN (SELECT b.id FROM batiment b WHERE b.site_id = s.id)
  ) AS nb_pieces,

  (SELECT COUNT(*)
     FROM element el
     JOIN piece pi  ON pi.id = el.piece_id
     JOIN espace es ON es.id = pi.espace_id
     JOIN etage et  ON et.id = es.etage_id
    WHERE et.batiment_id IN (SELECT b.id FROM batiment b WHERE b.site_id = s.id)
  ) AS nb_elements
FROM site s
JOIN projet p ON p.id = s.projet_id;

COMMENT ON VIEW v_site
  IS 'Synthèse site : rattachement au projet et comptages (bâtiments → éléments).';

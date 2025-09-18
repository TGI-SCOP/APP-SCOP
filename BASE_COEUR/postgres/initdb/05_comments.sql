-- Documentation des unités par colonne

-- PROJET
COMMENT ON COLUMN projet.surface_utile       IS 'Surface utile en m² (DOMAIN m2)';
COMMENT ON COLUMN projet.surface_de_planche  IS 'Surface de planche en m² (DOMAIN m2)';
COMMENT ON COLUMN projet.budget_moa          IS 'Budget en euros (€) (DOMAIN eur)';

-- ETAGE
COMMENT ON COLUMN etage.elevation            IS 'Élévation en mètres (m) (DOMAIN m)';

-- ESPACE
COMMENT ON COLUMN espace.surface             IS 'Surface en m² (DOMAIN m2)';

-- PIECE
COMMENT ON COLUMN piece.surface              IS 'Surface en m² (DOMAIN m2)';

-- ECONOMIE
COMMENT ON COLUMN economie.pu                IS 'Prix unitaire en euros (€) (DOMAIN eur)';
COMMENT ON COLUMN economie.quantite_val      IS 'Valeur de quantité (>=0) exprimée dans l’unité référencée par quantite_unite_id';
COMMENT ON COLUMN economie.quantite_unite_id IS 'Référence à unite.id ; conversion vers unité canonique via v_economie_quantite_normalisee';
COMMENT ON COLUMN economie.tva               IS 'Taux de TVA en % (0–100) (DOMAIN pct)';

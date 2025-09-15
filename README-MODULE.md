# README – Module (Template)

Ce document regroupe toutes les explications liées à un **module**.

---

## Module {{MODULE_NAME}}

### Rôle
- Fournit {{COURTE_DESC}}.
- S’intègre au coeur via l’API centrale et le front primaire.

### Frontend
- Dossier: `frontend/`.
- Pages: `app/(modules)/{{module_route}}` (Out) + `app/(modules)/data-entry/{{module_route}}` (In).
- Utilise `@scoping/ui-core` (design system).

### Backend
- Dossier: `backend/`.
- Routes: `src/api/`.
- Contrat: `openapi/module.yaml`.

### Base de données
- `db/migrations/` — migrations du module.
- `db/views/` — vues sécurisées (masquage champs).

### Ownership & sécurité
- `ownership/field_ownership_policy.sql` — mapping (resource, field, manager).
- `ownership/triggers_rls.sql` — RLS + triggers de scellement.
- `ownership/field_locks.sql` — option table générique de verrous.

### Lancer en local
```bash
pnpm --filter @modules/{{MODULE_PKG}} dev
```

### Variables d’environnement
- `DATABASE_URL=postgres://...`

### Migrations DB
```bash
pnpm --filter @modules/{{MODULE_PKG}} migrate
```

---

## Points de sécurité (module)
- RLS appliquée sur toutes les tables (`tenant_id`).
- Ownership par champ : libre avant, scellé après écriture du gestionnaire.
- API validée avec schémas (zod/JSON Schema).
- Secrets non commités (Vault/Sealed-Secrets).

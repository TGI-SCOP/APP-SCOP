# README – Coeur (Core Frontend & Backend)

Ce document regroupe toutes les explications liées au **coeur de l’application** : frontend principal et backend API central.

---

## Core Frontend (Next.js)

### Rôle
- Point d’entrée unique côté utilisateur.
- Fournit navigation, layout, authentification.
- Charge les modules via `(modules)`.

### Lancer en local
```bash
pnpm --filter @apps/core-frontend dev
```

### Points clés
- **Design system**: `@scoping/ui-core` via `UIProvider`.
- **Sécurité**: CSP + headers (`middleware.ts`, `security/`).
- **Auth**: `AuthProvider` (NextAuth/OIDC).
- **SDK**: `lib/api-core/client.ts` pour parler à l’API cœur.

### Arborescence
```
app/(core)      — layout, page accueil, états error/loading
app/(modules)   — pages des modules (clients, projects, ifc, ...)
components/     — AppShell, Nav, wrappers UI
lib/            — auth, api-core, config, utils
security/       — csp.ts, headers.ts
```

### Variables d’environnement
- `NEXT_PUBLIC_API_URL=https://api.{{DOMAIN}}`
- `NEXTAUTH_URL` (si NextAuth)

### Ajout de module (front)
1. Créer `app/(modules)/{{module_name}}/page.tsx`.
2. Activer la feature dans `lib/config/features.ts`.
3. Ajouter la route dans `AppShell/Nav`.

---

## Core Backend (API cœur)

### Rôle
- Point d’entrée API.
- Authentifie (OIDC/JWT), gère le registre des modules et expose des routes globales.
- Fournit un contrat API (OpenAPI) pour générer le SDK client.

### Lancer en local
```bash
pnpm --filter @apps/core-backend dev
```

### Dossiers
- `src/api/`        — routes REST/GraphQL.
- `src/auth/`       — OIDC/JWT, JWK.
- `src/policies/`   — intégration OPA (option phase 2).
- `src/ownership/`  — mapping SQL <-> claims (module courant).
- `openapi/`        — `core.yaml` (contrat API cœur).

### Variables d’environnement
- `DATABASE_URL=postgres://...`
- `OIDC_ISSUER, OIDC_CLIENT_ID, OIDC_CLIENT_SECRET`

### Migrations DB
```bash
pnpm --filter @apps/core-backend migrate
```

---

## Points de sécurité (coeur)
- Auth obligatoire (OIDC, MFA via IdP).
- RLS Postgres activée (multi-tenant).
- Triggers de scellement par champ (ownership).
- CSP et headers stricts appliqués côté front.
- Secrets gérés via Vault/Sealed-Secrets (pas en clair).

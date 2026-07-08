# Setup — comptes Supabase & Cloudflare R2

Ce guide couvre les actions **manuelles**, à faire une seule fois, dans les dashboards Supabase et Cloudflare. Le code (Flutter, Next.js, Edge Function) est déjà scaffoldé et attend juste ces clés dans des fichiers `.env` locaux (jamais commités).

## Prérequis locaux

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — nécessaire pour faire tourner Supabase en local (`supabase start`).
- Un compte [Supabase](https://supabase.com) et un compte [Cloudflare](https://dash.cloudflare.com/sign-up).

## 1. Créer le projet Supabase

1. Sur [supabase.com/dashboard](https://supabase.com/dashboard), crée un nouveau projet (choisis une région proche, ex. Europe).
2. Une fois le projet créé, va dans **Project Settings > API** et note :
   - `Project URL` → `SUPABASE_URL`
   - `anon` `public` key → `SUPABASE_ANON_KEY`
   - `service_role` key (⚠️ secret, jamais côté client) → `SUPABASE_SERVICE_ROLE_KEY`
3. Lie ce repo au projet distant (depuis la racine du repo) :

   ```bash
   npx supabase login
   npx supabase link --project-ref <ton-project-ref>
   ```

   Le `project-ref` est visible dans l'URL du dashboard (`https://supabase.com/dashboard/project/<project-ref>`).

4. Pour lancer Supabase en local pendant le développement (Docker doit tourner) :

   ```bash
   npx supabase start
   ```

## 2. Créer le bucket Cloudflare R2

1. Sur le [dashboard Cloudflare](https://dash.cloudflare.com/), va dans **R2 Object Storage** et crée un bucket, ex. `keenlead-media`.
2. Note ton **Account ID** (visible dans la sidebar R2 ou dans l'URL) → `R2_ACCOUNT_ID`.
3. Va dans **R2 > Manage API Tokens** et crée un token avec permission **Object Read & Write** sur ce bucket. Note :
   - `Access Key ID` → `R2_ACCESS_KEY_ID`
   - `Secret Access Key` → `R2_SECRET_ACCESS_KEY`
4. Pour que les fichiers publics (covers, sons publics) soient accessibles par URL directe, active un accès public au bucket (sous-domaine `r2.dev` fourni par Cloudflare, ou un domaine personnalisé branché sur le bucket) → cette URL de base devient `R2_PUBLIC_BASE_URL`.

## 3. Remplir les fichiers d'environnement

Trois fichiers à créer localement à partir de leurs `.env.example` — **aucun des trois n'est commité** (voir `.gitignore`) :

| Exemple | Fichier réel à créer | Utilisé par |
|---|---|---|
| `mobile/.env.example` | `mobile/.env` | App Flutter |
| `web/.env.example` | `web/.env.local` | App Next.js |
| — (voir ci-dessous) | secrets de l'Edge Function Supabase | `get-upload-url` |

Pour l'Edge Function (elle tourne côté Supabase, pas dans ce repo), pousse les secrets R2 avec la CLI :

```bash
npx supabase secrets set R2_ACCOUNT_ID=... R2_ACCESS_KEY_ID=... R2_SECRET_ACCESS_KEY=... R2_BUCKET_NAME=keenlead-media R2_PUBLIC_BASE_URL=https://...
```

## 4. Déployer l'Edge Function (quand tu es prêt)

```bash
npx supabase functions deploy get-upload-url
```

## Vérification

- `mobile/` : lance `flutter run`, l'écran affiche « Connexion Supabase OK ».
- `web/` : lance `npm run dev` dans `web/`, va sur `http://localhost:3000`, la page affiche « Connexion Supabase OK ».
- Si ça affiche une erreur de connexion : vérifie que les valeurs dans `.env` / `.env.local` correspondent bien à celles du dashboard Supabase (Project URL et anon key), pas d'espace ou de guillemet en trop.

## Ce qui n'est pas encore fait (prochaine étape)

Cette étape (mise en place technique) ne crée pas encore les tables métier (`tracks`, `albums`, `playlists`, etc.) ni les règles de sécurité (RLS) — c'est l'**Étape 4 — Développement du backend** du cahier des charges (`docs/cahier-des-charges.md`), qui viendra ensuite.

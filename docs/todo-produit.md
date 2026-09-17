# TODO produit

Backlog des décisions produit et techniques à traiter au-delà des étapes de migration
(`docs/plan/`). Chaque entrée : contexte, décision visée, et pourquoi.

## Architecture cible : passer d'un POC à une base scalable et testée

**Contexte.** WS1 est aujourd'hui un POC. Les écrans (ex. `src/app/(app)/clients/page.tsx`)
mélangent accès aux données (requête Supabase) et affichage (JSX) dans le même Server Component.
Acceptable pour un POC CRUD, mais l'application vise la croissance et exige robustesse + couverture
de tests.

**Structure cible (séparation en couches, un seul langage TypeScript).**

```
Composant (Server/Client)        → affichage uniquement, pas de logique métier
        ↓
Service / cas d'usage            → logique métier, testable sans base ni HTTP
        ↓
Repository (accès données)       → requêtes Supabase isolées (seule couche qui parle à la base)
        ↓
Validation (Zod) aux frontières  → garantit la conformité des données entrantes/sortantes
```

- `src/lib/repositories/` : seules fonctions autorisées à interroger Supabase. Remplaçables par un
  mock → logique testable sans vraie base.
- `src/lib/services/` : logique métier (règles, calculs, orchestration). Cible principale des tests
  unitaires. TypeScript pur, rapide.
- Composant : mince, appelle un service et affiche. Peu de logique = peu de bugs.
- **Zod** aux entrées/sorties (formulaires, réponses base, éventuels endpoints) : la robustesse vient
  de la validation à l'exécution, pas des types seuls (les types disparaissent au runtime).
- **API interne (Route Handlers `src/app/api/`)** : à ajouter seulement pour un vrai besoin
  d'exposition (appli mobile — hors périmètre actuel, webhook, client externe). Un Route Handler
  appelle alors le même service que les pages : zéro duplication. Ne pas faire appeler une Route
  Handler par un Server Component (anti-pattern : aller-retour HTTP inutile).

**Stratégie de tests (pyramide).**

| Niveau | Outil | Sur quoi | Volume |
|---|---|---|---|
| Unitaire | Vitest | Services, logique métier, utils | Beaucoup (rapides) |
| Intégration | Vitest + Supabase local | Repositories contre une base de test | Moyen |
| E2E | Playwright | Parcours utilisateur critiques | Peu |

**Autres piliers.**
- CI bloquante : `npm run build` + typecheck + lint + tests à chaque push.
- Erreurs typées et explicites (jamais de `null` silencieux dans un service).
- Frontières nettes : chaque module expose une interface publique claire (`index.ts`).

**Migration progressive suggérée (ne pas tout refactoriser d'un coup).**
1. Poser le socle de tests (Vitest + config + premier test).
2. Extraire un écran pilote (ex. `clients`) en repository + service + tests → modèle de référence.
3. Documenter le pattern ; les écrans suivants le suivent.

**Coût / arbitrage.** Cette structure ajoute des fichiers et de l'indirection. Justifiée par
l'objectif de croissance et de robustesse ; sur-ingénierie sur un POC jetable. À appliquer au cas par
cas (une requête dupliquée ou une logique qui grossit déclenche l'extraction), pas comme règle
systématique tant que la valeur n'est pas là.

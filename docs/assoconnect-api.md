# AssoConnect API

Documentation de référence pour l'intégration de l'API AssoConnect dans ce projet.
Synthèse de la [documentation officielle](https://assoconnect.notion.site/AssoConnect-API-Documentation-fran-ais-59e2aa9b8bdc401da3e1520237625796)
(la source fait foi en cas de divergence).

> Dans ce repo, le client server-only vit dans `src/lib/assoconnect.ts`.

## Présentation

L'API permet de communiquer avec le système d'AssoConnect sans passer par
l'interface : lister, consulter, créer et modifier les contacts, adhérents et
organisations.

- **Périmètre : CRM (« Communauté ») uniquement.** Les autres fonctionnalités
  d'AssoConnect ne sont pas (encore) exposées.
- **Accès contrôlé**, réservé aux abonnés de l'offre Professionnelle. Les clés
  sont fournies par AssoConnect (environnement de test + production) avec
  l'identifiant (ULID) de l'organisation principale.
- Support technique : `api@assoconnect.com`.

## Authentification

Toutes les requêtes passent en **HTTPS** et envoient la clé via le header
`X-AUTH-TOKEN`.

| Élément | Valeur |
| --- | --- |
| Base URL | `https://app.assoconnect.com/api/v1` |
| Header d'auth | `X-AUTH-TOKEN: <votre_clé>` |
| Header attendu | `Accept: application/ld+json` |
| Liste des endpoints | https://app.assoconnect.com/api_documentation |

Dans ce projet, la clé et l'ULID sont des secrets **server-only** :
`ASSOCONNECT_API_KEY` et `ASSOCONNECT_ORGANIZATION_ULID` (jamais de préfixe
`NEXT_PUBLIC_`, jamais importés dans un composant client).

## Rate limiting

**30 requêtes/seconde.** Au-delà, les requêtes sont refusées pendant une courte
période — prévoir une limitation côté intégration.

## Codes de réponse

- `2xx` : succès
- `4xx` : erreur liée aux paramètres fournis (certaines renvoient un détail)
- `5xx` : erreur côté serveurs AssoConnect

Exemple d'erreur :

```json
HTTP/1.1 404 Not Found
{
  "@context": "/api/v1/contexts/Error",
  "@type": "hydra:Error",
  "hydra:title": "An error occurred",
  "hydra:description": "Resource \"App\\Entity\\Organization\" with id \"...\" not found."
}
```

## Pagination

Les listes sont paginées : **25 résultats par défaut, 100 maximum**. Paramètres
de requête : `page` et `itemsPerPage`. La navigation se fait via le bloc
`hydra:view` (`hydra:first`, `hydra:next`, `hydra:last`) et `hydra:totalItems`.

```
GET /api/v1/organizations/{id}/contacts?page=1&itemsPerPage=10
```

## Endpoints utiles

### Consulter une organisation

```bash
curl -X GET "https://app.assoconnect.com/api/v1/organizations/{ulid}" \
  -H "Accept: application/ld+json" \
  -H "X-AUTH-TOKEN: {token}"
```

```json
{
  "@id": "/api/v1/organizations/0HXE3ZKHNZBK19GGYJYD2TP0AS",
  "@type": "Organization",
  "brand": "assoconnect",
  "isAdvanced": true,
  "isLegalIndependent": true,
  "logoUrl": "https://site.assoconnect.com/services/....",
  "name": "My Nonprofit Name",
  "parent": null,
  "phoneNumber": "+33612345678",
  "url": "https://{organization_base_url}"
}
```

### Lister les contacts d'une organisation

```
GET /api/v1/organizations/{organizationId}/contacts
```

Filtres disponibles (query string) : `type` / `type[]`, `relationType`,
`membershipDate[on]`, `membershipDate[from]`, `membershipDate[until]`.

Réponse (collection Hydra) :

```json
{
  "@type": "hydra:Collection",
  "hydra:member": [
    {
      "@id": "api/v1/crm/contacts/{contactId}",
      "@type": "Contact",
      "type": "person",
      "firstname": "Jean",
      "lastname": "ValJean",
      "email": "j.valjean@gmail.com",
      "landlinePhone": "+33123456789",
      "mobilePhone": "+33623456789",
      "relations": [
        { "type": "AFFILIATION", "organization": "api/v1/organization/...", "createdAt": "2021-01-01" }
      ]
    }
  ],
  "hydra:totalItems": 169,
  "hydra:view": {
    "hydra:first": "/api/v1/organizations/{id}/contacts?page=1",
    "hydra:next": "/api/v1/organizations/{id}/contacts?page=2",
    "hydra:last": "/api/v1/organizations/{id}/contacts?page=7"
  }
}
```

## Ressources CRM

- **Contact** : concept cœur, regroupe les **personnes** (personnes physiques) et
  les **structures** (personnes morales). Champs natifs : nom/prénom (ou nom pour
  une structure), date de naissance (personne), email, téléphone fixe, téléphone
  mobile, adresse postale. Des **champs personnalisés** (`customFields`) peuvent
  s'ajouter selon la plateforme.
- **Adhérent**, **Donateur** : types de relations d'un contact avec l'organisation.
- **Organisation** / **Réseau** : entités qui structurent une plateforme
  AssoConnect (groupes, groupes avancés).

## Au-delà

L'API propose aussi un système de **webhooks** et le **SSO** (AssoConnect comme
fournisseur d'identité). Voir la documentation officielle pour ces sujets.

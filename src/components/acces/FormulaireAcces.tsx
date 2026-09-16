"use client";

import { useActionState } from "react";
import { creerAcces, type ResultatCreation } from "@/app/(app)/parametrage/acces/actions";

const CHAMP = "rounded border bg-white px-2 py-1 text-xs dark:bg-white/5";

/** Création d'un accès : le mot de passe initial s'affiche une seule fois, ici, jamais par e-mail. */
export function FormulaireAcces() {
  const [resultat, action, enCours] = useActionState<ResultatCreation, FormData>(creerAcces, null);

  if (resultat?.ok) {
    return (
      <div className="flex flex-col gap-2 rounded border border-green-300 bg-green-50 p-3 text-xs dark:bg-green-950/30">
        <p className="font-semibold">Accès créé pour {resultat.email}. L&apos;application n&apos;a envoyé aucun e-mail : c&apos;est vous qui transmettez le mot de passe.</p>
        <p>Mot de passe initial, affiché une seule fois :</p>
        <code className="w-fit select-all rounded border bg-white px-3 py-1.5 font-mono text-sm dark:bg-black/40">{resultat.motDePasse}</code>
        <p className="opacity-70">
          Envoyez-le à la personne (idéalement séparément de l&apos;identifiant) en lui demandant de le remplacer dès sa première connexion via le bouton « Mot de passe » en haut à droite.
        </p>
      </div>
    );
  }

  return (
    <form action={action} className="flex flex-col gap-2 rounded border p-3 text-xs">
      <span className="font-semibold">Créer un accès (identifiant = e-mail, mot de passe initial affiché ici)</span>
      {resultat && !resultat.ok && <p className="rounded border border-red-300 bg-red-50 px-2 py-1 text-red-700 dark:bg-red-950/30">{resultat.erreur}</p>}
      <div className="grid gap-2 sm:grid-cols-[1fr_1fr_10rem_auto]">
        <input name="email" type="email" required placeholder="adresse@exemple.fr" autoComplete="off" className={CHAMP} />
        <input name="nom" placeholder="Nom affiché (facultatif)" className={CHAMP} />
        <select name="role" defaultValue="gestionnaire" className={CHAMP}>
          <option value="gestionnaire">gestionnaire</option>
          <option value="comptable">comptable</option>
          <option value="administrateur">administrateur</option>
        </select>
        <button type="submit" disabled={enCours} className="rounded border bg-black px-3 py-1 text-white disabled:opacity-50">
          {enCours ? "Création…" : "Créer"}
        </button>
      </div>
      <p className="opacity-70">Si une fiche « Utilisateurs &amp; Techniciens » porte déjà cette adresse, l&apos;accès lui est rattaché ; sinon un compte indépendant des données FMC est créé.</p>
    </form>
  );
}

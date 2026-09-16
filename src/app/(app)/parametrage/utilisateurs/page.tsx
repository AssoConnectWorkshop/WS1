import Link from "next/link";
import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { createClient } from "@/lib/supabase/server";
import { inviteUtilisateur, changerRole } from "./actions";

export const dynamic = "force-dynamic";

type UtilisateurRow = {
  id: number;
  nom: string | null;
  prenom: string | null;
  email: string | null;
  profil: number | null;
  immatriculation: string | null;
  code_intervenant: string | null;
  login_legacy: string | null;
  role: "gestionnaire" | "administrateur" | "comptable" | null;
  auth_user_id: string | null;
  societes: { libelle: string | null } | null;
};

const PROFILS: Record<number, string> = { 1: "Gestionnaire", 2: "Technicien", 3: "Gestionnaire(Tech)" };

/** Sous-formulaire « Utilisateurs & Techniciens » de Form_Parametrage : feuille de données avec les colonnes Access. */
export default async function UtilisateursPage({ searchParams }: { searchParams: Promise<{ erreur?: string; info?: string }> }) {
  const { erreur, info } = await searchParams;
  const current = await getCurrentUser();
  if (!current?.utilisateur) redirect("/login");
  const estAdmin = current.role === "administrateur";
  const listeBlancheActive = Boolean(process.env.EMAILS_AUTORISES?.trim());

  const supabase = await createClient();
  const { data } = await supabase
    .from("utilisateurs")
    .select("id, nom, prenom, email, profil, immatriculation, code_intervenant, login_legacy, role, auth_user_id, societes(libelle)")
    .order("nom")
    .order("prenom");

  const utilisateurs = (data ?? []) as unknown as UtilisateurRow[];

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center justify-between gap-3">
        <h1 className="text-xl font-bold">Utilisateurs &amp; Techniciens</h1>
        <div className="flex items-center gap-2">
          <span className="rounded border bg-red-600 px-3 py-1 text-xs font-semibold text-white">Si Suppression Technicien : Penser à supprimer LE MAIL et LE MOT DE PASSE</span>
          <Link href="/parametrage" className="rounded bg-red-600 px-3 py-1 text-xs text-white" title="Fermer">
            ✕
          </Link>
        </div>
      </div>
      <p className="text-xs opacity-70">
        Les gestionnaires (type 1) peuvent être invités à se connecter ; l&apos;accès à l&apos;application remplace le mot de passe Access. Le rôle « comptable » remplace le mot de passe Kadi : seul rôle, avec l&apos;administrateur, à poser les statuts de facturation réservés.
        {!estAdmin && " Consultation seule : les invitations et rôles sont réservés à l'administrateur."}
        {estAdmin && ` Une invitation n'est envoyée que si l'adresse est retapée à l'identique et figure dans la liste blanche (${listeBlancheActive ? "active" : "vide : aucun e-mail ne peut partir"}).`}
      </p>
      {erreur && <p className="rounded border border-red-300 bg-red-50 px-3 py-2 text-xs text-red-700 dark:bg-red-950/30">{erreur}</p>}
      {info && <p className="rounded border border-green-300 bg-green-50 px-3 py-2 text-xs text-green-700 dark:bg-green-950/30">{info}</p>}

      <div className="overflow-x-auto rounded border">
        <table className="w-full border-collapse text-xs">
          <thead>
            <tr className="border-b bg-black/[0.03] text-left dark:bg-white/[0.05]">
              {["Nom utilisateur", "Prénom utilisateur", "Type utilisateur", "Immat", "Intervenant", "Société", "Code FMC", "Login FMC", "Mail", "Accès application", ""].map((h) => (
                <th key={h} className="whitespace-nowrap px-2 py-1 font-medium">
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {utilisateurs.length === 0 && (
              <tr>
                <td colSpan={11} className="py-6 text-center opacity-60">
                  Aucun utilisateur.
                </td>
              </tr>
            )}
            {utilisateurs.map((u) => (
              <tr key={u.id} className="border-b last:border-0 hover:bg-blue-100 dark:hover:bg-blue-950/40">
                <td className="whitespace-nowrap px-2 py-1">{u.nom ?? ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.prenom ?? ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.profil != null ? PROFILS[u.profil] ?? u.profil : ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.immatriculation ?? ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.code_intervenant ?? ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.societes?.libelle ?? ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.code_intervenant ?? ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.login_legacy ?? ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.email ?? ""}</td>
                <td className="whitespace-nowrap px-2 py-1">{u.auth_user_id ? `invité · ${u.role ?? "gestionnaire"}` : ""}</td>
                <td className="whitespace-nowrap px-2 py-1 text-right">
                  {estAdmin && u.profil !== 2 && !u.auth_user_id && u.email && (
                    <form action={inviteUtilisateur} className="flex items-center gap-1">
                      <input type="hidden" name="utilisateurId" value={u.id} />
                      <input
                        name="confirmation"
                        type="email"
                        required
                        autoComplete="off"
                        placeholder="Retaper l'e-mail pour inviter"
                        title="Sécurité : retapez l'adresse exacte de la ligne. Elle doit aussi figurer dans la liste blanche EMAILS_AUTORISES."
                        className="w-48 rounded border px-1 py-0.5 text-[11px]"
                      />
                      <button type="submit" className="rounded border px-2 py-0.5 text-[11px]">
                        Inviter
                      </button>
                    </form>
                  )}
                  {estAdmin && u.auth_user_id && (
                    <form action={changerRole} className="flex items-center gap-1">
                      <input type="hidden" name="utilisateurId" value={u.id} />
                      <select name="role" defaultValue={u.role ?? "gestionnaire"} className="rounded border px-1 py-0.5 text-[11px]">
                        <option value="gestionnaire">gestionnaire</option>
                        <option value="comptable">comptable</option>
                        <option value="administrateur">administrateur</option>
                      </select>
                      <button type="submit" className="rounded border px-2 py-0.5 text-[11px]">
                        Changer le rôle
                      </button>
                    </form>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="text-xs opacity-70">Enr : {utilisateurs.length}</div>
    </div>
  );
}

import Link from "next/link";
import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { createClient } from "@/lib/supabase/server";
import { masterAdmins } from "@/lib/acces";
import { formatNom } from "@/lib/format";
import { FormulaireAcces } from "@/components/acces/FormulaireAcces";
import { changerRoleAcces, revoquerAcces } from "./actions";

export const dynamic = "force-dynamic";

type Compte = {
  id: number;
  nom: string | null;
  prenom: string | null;
  email: string | null;
  role: string | null;
  compte_application: boolean;
  profil: number | null;
};

const PETIT = "rounded border px-1 py-0.5 text-[11px]";

/** Accès à l'application, découplés du personnel FMC : master admins (Vercel), comptes créés sans e-mail, rôles, révocation. */
export default async function AccesPage({ searchParams }: { searchParams: Promise<{ erreur?: string; info?: string }> }) {
  const { erreur, info } = await searchParams;
  const current = await getCurrentUser();
  if (!current?.utilisateur) redirect("/login");
  if (current.role !== "administrateur") redirect("/parametrage");
  const moi = current.utilisateur.id;

  const supabase = await createClient();
  const { data } = await supabase
    .from("utilisateurs")
    .select("id, nom, prenom, email, role, compte_application, profil")
    .not("auth_user_id", "is", null)
    .order("email");
  const comptes = (data ?? []) as Compte[];
  const masters = masterAdmins();

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center justify-between gap-3">
        <h1 className="text-xl font-bold">Accès application</h1>
        <Link href="/parametrage" className="rounded bg-red-600 px-3 py-1 text-xs text-white" title="Fermer">
          ✕
        </Link>
      </div>
      <p className="text-xs opacity-70">
        Qui peut se connecter (identifiant = e-mail), indépendamment des fiches « Utilisateurs &amp; Techniciens ». L&apos;application n&apos;envoie aucun e-mail automatique : le mot de passe initial s&apos;affiche à l&apos;écran, une seule fois, et vous le transmettez vous-même. Chacun le remplace ensuite via « Mot de passe » en haut à droite.
      </p>
      {erreur && <p className="rounded border border-red-300 bg-red-50 px-3 py-2 text-xs text-red-700 dark:bg-red-950/30">{erreur}</p>}
      {info && <p className="rounded border border-green-300 bg-green-50 px-3 py-2 text-xs text-green-700 dark:bg-green-950/30">{info}</p>}

      <div className="rounded border p-3 text-xs">
        <span className="font-semibold">Master admins</span>
        <span className="opacity-70"> (variable Vercel MASTER_ADMINS : toujours administrateur, non révocables ici)</span>
        {masters.length === 0 ? (
          <p className="mt-1 text-red-700">Aucun master admin défini : renseignez MASTER_ADMINS sur Vercel.</p>
        ) : (
          <ul className="mt-1 flex flex-wrap gap-2">
            {masters.map((m) => (
              <li key={m} className="rounded border bg-amber-50 px-2 py-0.5 dark:bg-amber-950/30">
                {m}
              </li>
            ))}
          </ul>
        )}
      </div>

      <FormulaireAcces />

      <div className="overflow-x-auto rounded border">
        <table className="w-full border-collapse text-xs">
          <thead>
            <tr className="border-b bg-black/[0.03] text-left dark:bg-white/[0.05]">
              {["E-mail", "Nom", "Origine", "Rôle", ""].map((h) => (
                <th key={h} className="whitespace-nowrap px-2 py-1 font-medium">
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {comptes.length === 0 && (
              <tr>
                <td colSpan={5} className="py-6 text-center opacity-60">
                  Aucun compte actif.
                </td>
              </tr>
            )}
            {comptes.map((c) => {
              const master = !!c.email && masters.includes(c.email.trim().toLowerCase());
              return (
                <tr key={c.id} className="border-b last:border-0 hover:bg-blue-100 dark:hover:bg-blue-950/40">
                  <td className="whitespace-nowrap px-2 py-1">{c.email ?? ""}</td>
                  <td className="whitespace-nowrap px-2 py-1">{c.compte_application && c.nom === c.email ? "" : formatNom(c.prenom, c.nom)}</td>
                  <td className="whitespace-nowrap px-2 py-1">{master ? "master admin" : c.compte_application ? "compte application" : "fiche FMC"}</td>
                  <td className="whitespace-nowrap px-2 py-1">
                    {master ? (
                      "administrateur"
                    ) : (
                      <form action={changerRoleAcces} className="flex items-center gap-1">
                        <input type="hidden" name="id" value={c.id} />
                        <select name="role" defaultValue={c.role ?? "gestionnaire"} className={PETIT}>
                          <option value="gestionnaire">gestionnaire</option>
                          <option value="comptable">comptable</option>
                          <option value="administrateur">administrateur</option>
                        </select>
                        <button type="submit" className={PETIT}>
                          Changer
                        </button>
                      </form>
                    )}
                  </td>
                  <td className="whitespace-nowrap px-2 py-1 text-right">
                    {!master && c.id !== moi && (
                      <form action={revoquerAcces} className="flex items-center justify-end gap-1">
                        <input type="hidden" name="id" value={c.id} />
                        <input name="confirmation" type="email" required autoComplete="off" placeholder="Retaper l'e-mail pour révoquer" className={`${PETIT} w-52`} />
                        <button type="submit" className={`${PETIT} text-red-700`}>
                          Révoquer
                        </button>
                      </form>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

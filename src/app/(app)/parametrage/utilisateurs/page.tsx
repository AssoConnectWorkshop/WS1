import { redirect } from "next/navigation";
import { getCurrentUser } from "@/lib/auth";
import { createClient } from "@/lib/supabase/server";
import { inviteUtilisateur, changerRole } from "./actions";

type UtilisateurRow = {
  id: number;
  nom: string | null;
  prenom: string | null;
  email: string | null;
  role: "gestionnaire" | "administrateur" | null;
  auth_user_id: string | null;
};

export default async function UtilisateursPage() {
  const current = await getCurrentUser();
  if (!current?.utilisateur) redirect("/login");
  if (current.role !== "administrateur") redirect("/");

  const supabase = await createClient();
  const { data } = await supabase
    .from("utilisateurs")
    .select("id, nom, prenom, email, role, auth_user_id")
    .eq("profil", 1)
    .order("nom");

  const utilisateurs = (data ?? []) as UtilisateurRow[];

  return (
    <div className="mx-auto flex max-w-3xl flex-col gap-6 p-8">
      <h1 className="text-2xl font-bold">Utilisateurs</h1>
      <p className="text-sm opacity-70">
        Gestionnaires FMC (profil = 1). Les techniciens ne sont pas invités à cette étape.
      </p>

      <table className="w-full border-collapse text-sm">
        <thead>
          <tr className="border-b text-left">
            <th className="py-2">Nom</th>
            <th>E-mail</th>
            <th>Rôle</th>
            <th>Compte</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {utilisateurs.length === 0 && (
            <tr>
              <td colSpan={5} className="py-6 text-center opacity-60">
                Aucun utilisateur (données transférées à l&apos;étape 2 ?).
              </td>
            </tr>
          )}
          {utilisateurs.map((u) => (
            <tr key={u.id} className="border-b">
              <td className="py-2">{[u.prenom, u.nom].filter(Boolean).join(" ") || "—"}</td>
              <td>{u.email ?? "—"}</td>
              <td>{u.role ?? "—"}</td>
              <td>{u.auth_user_id ? "invité" : "non invité"}</td>
              <td className="py-2 text-right">
                {!u.auth_user_id && u.email && (
                  <form action={inviteUtilisateur}>
                    <input type="hidden" name="utilisateurId" value={u.id} />
                    <button type="submit" className="rounded-md border px-2 py-1 text-xs">
                      Inviter
                    </button>
                  </form>
                )}
                {u.auth_user_id && (
                  <form action={changerRole}>
                    <input type="hidden" name="utilisateurId" value={u.id} />
                    <input
                      type="hidden"
                      name="role"
                      value={u.role === "administrateur" ? "gestionnaire" : "administrateur"}
                    />
                    <button type="submit" className="rounded-md border px-2 py-1 text-xs">
                      Passer {u.role === "administrateur" ? "gestionnaire" : "administrateur"}
                    </button>
                  </form>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

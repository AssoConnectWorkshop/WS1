import Link from "next/link";
import { Champ, CHAMP } from "@/components/ui/Champ";
import { EmptyState } from "@/components/ui/EmptyState";
import { formatNom } from "@/lib/format";
import { enregistrerContact, supprimerContact } from "@/app/(app)/tiers/actions";

export type Contact = {
  id: number;
  nom: string | null;
  prenom: string | null;
  civilite: string | null;
  fonction: string | null;
  email: string | null;
  telephone: string | null;
  mobile: string | null;
  fax: string | null;
  observations: string | null;
};

type Parent = { client_id?: number; donneur_ordre_id?: number };

/** Liste des contacts d'un client ou d'un donneur d'ordre, avec ajout et édition en ligne
 * (le contact à modifier est désigné par `?modifier=<id>` pour rester sans JavaScript). */
export function Contacts({ contacts, parent, modifierId, retour }: { contacts: Contact[]; parent: Parent; modifierId?: string; retour: string }) {
  const hidden = (
    <>
      {parent.client_id && <input type="hidden" name="client_id" value={parent.client_id} />}
      {parent.donneur_ordre_id && <input type="hidden" name="donneur_ordre_id" value={parent.donneur_ordre_id} />}
      <input type="hidden" name="retour" value={retour} />
    </>
  );

  return (
    <div className="flex flex-col gap-4">
      {contacts.length === 0 && <EmptyState message="Aucun contact." />}
      <ul className="flex flex-col gap-2">
        {contacts.map((c) =>
          String(c.id) === modifierId ? (
            <li key={c.id} className="rounded-lg border p-3">
              <FormulaireContact contact={c} hidden={hidden} retour={retour} />
            </li>
          ) : (
            <li key={c.id} className="flex items-start justify-between gap-3 rounded-lg border p-3 text-sm">
              <div>
                <div className="font-medium">
                  {[c.civilite, formatNom(c.prenom, c.nom)].filter(Boolean).join(" ")}
                  {c.fonction ? ` · ${c.fonction}` : ""}
                </div>
                <div className="opacity-70">{[c.email, c.telephone, c.mobile].filter(Boolean).join(" · ") || "—"}</div>
                {c.observations && <div className="mt-1 text-xs opacity-60">{c.observations}</div>}
              </div>
              <div className="flex shrink-0 items-center gap-3">
                <Link href={`${retour}${retour.includes("?") ? "&" : "?"}modifier=${c.id}`} className="text-xs underline">
                  Modifier
                </Link>
                <form action={supprimerContact}>
                  {hidden}
                  <input type="hidden" name="contact_id" value={c.id} />
                  <button type="submit" className="text-xs text-red-700 underline">
                    Supprimer
                  </button>
                </form>
              </div>
            </li>
          ),
        )}
      </ul>

      <div className="rounded-xl border p-4">
        <h2 className="mb-3 text-sm font-semibold opacity-70">Ajouter un contact</h2>
        <FormulaireContact hidden={hidden} retour={retour} />
      </div>
    </div>
  );
}

function FormulaireContact({ contact, hidden, retour }: { contact?: Contact; hidden: React.ReactNode; retour: string }) {
  return (
    <form action={enregistrerContact} className="flex flex-col gap-3">
      {hidden}
      {contact && <input type="hidden" name="contact_id" value={contact.id} />}
      <div className="grid grid-cols-3 gap-3">
        <Champ label="Civilité">
          <input name="civilite" defaultValue={contact?.civilite ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Prénom">
          <input name="prenom" defaultValue={contact?.prenom ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Nom *">
          <input name="nom" required defaultValue={contact?.nom ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Champ label="Fonction">
          <input name="fonction" defaultValue={contact?.fonction ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="E-mail">
          <input name="email" type="email" defaultValue={contact?.email ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Téléphone">
          <input name="telephone" defaultValue={contact?.telephone ?? ""} className={CHAMP} />
        </Champ>
        <Champ label="Mobile">
          <input name="mobile" defaultValue={contact?.mobile ?? ""} className={CHAMP} />
        </Champ>
      </div>
      <Champ label="Observations">
        <textarea name="observations" rows={2} defaultValue={contact?.observations ?? ""} className={CHAMP} />
      </Champ>
      <div className="flex items-center gap-3">
        <button type="submit" className="w-fit rounded-md bg-black px-4 py-1.5 text-sm text-white">
          {contact ? "Enregistrer" : "Ajouter"}
        </button>
        {contact && (
          <Link href={retour} className="text-sm underline">
            Annuler
          </Link>
        )}
      </div>
    </form>
  );
}

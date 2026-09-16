"use server";

import { z } from "zod";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { enregistrerJournal } from "@/lib/journal";
import { requireUtilisateur, redirectWithError } from "@/lib/action-utils";
import { booleen, entier, identifiant, nombre, obligatoire, texte, premiereErreur } from "@/lib/zod-form";

const DOUBLON = "23505";

function retourSur(formData: FormData, defaut: string) {
  const retour = String(formData.get("retour") ?? "");
  return retour.startsWith("/") ? retour : defaut;
}

const ClientSchema = z.object({
  nom: obligatoire("Le nom du client est obligatoire."),
  adresse: texte,
  code_postal: texte,
  ville: texte,
  telephone: texte,
  fax: texte,
  contact_principal: texte,
  email: texte,
  delai_intervention_heures: nombre,
  numero_esabora_maint: texte,
  numero_esabora_clim: texte,
  tarif_heure_mo: nombre,
  tarif_deplacement: nombre,
  actif: booleen,
});

export async function creerClient(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = ClientSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError("/clients/nouveau", premiereErreur(parsed));

  const supabase = await createClient();
  const { data: created, error } = await supabase.from("clients").insert(parsed.data).select("id").single();
  if (error?.code === DOUBLON) redirectWithError("/clients/nouveau", "Un client porte déjà ce nom.");
  if (error || !created) redirectWithError("/clients/nouveau", "La création du client a échoué.");

  await enregistrerJournal(supabase, "clients", created.id, utilisateur.id, { action: "creation" });
  revalidatePath("/clients");
  redirect(`/clients/${created.id}`);
}

export async function mettreAJourClient(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const clientId = Number(formData.get("client_id"));
  const parsed = ClientSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(`/clients/${clientId}`, premiereErreur(parsed));

  const supabase = await createClient();
  const { error } = await supabase.from("clients").update(parsed.data).eq("id", clientId);
  if (error?.code === DOUBLON) redirectWithError(`/clients/${clientId}`, "Un client porte déjà ce nom.");
  if (error) redirectWithError(`/clients/${clientId}`, "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "clients", clientId, utilisateur.id, { action: "maj" });
  revalidatePath("/clients");
  revalidatePath(`/clients/${clientId}`);
  redirect(`/clients/${clientId}?info=${encodeURIComponent("Client enregistré.")}`);
}

const DonneurSchema = z.object({
  nom: obligatoire("Le nom du donneur d'ordre est obligatoire."),
  adresse: texte,
  code_postal: texte,
  ville: texte,
  telephone: texte,
  fax: texte,
  contact_principal: texte,
  email: texte,
  delai_intervention_heures: nombre,
  logo_chemin: texte,
  pied_page_ligne_1: texte,
  pied_page_ligne_2: texte,
  pied_page_ligne_3: texte,
  actif: booleen,
  saisie_simplifiee_tablette: booleen,
});

export async function creerDonneur(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const parsed = DonneurSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError("/donneurs-ordre/nouveau", premiereErreur(parsed));

  const supabase = await createClient();
  const { data: created, error } = await supabase.from("donneurs_ordre").insert(parsed.data).select("id").single();
  if (error || !created) redirectWithError("/donneurs-ordre/nouveau", "La création a échoué.");

  await enregistrerJournal(supabase, "donneurs_ordre", created.id, utilisateur.id, { action: "creation" });
  revalidatePath("/donneurs-ordre");
  redirect(`/donneurs-ordre/${created.id}`);
}

export async function mettreAJourDonneur(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const donneurId = Number(formData.get("donneur_ordre_id"));
  const parsed = DonneurSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(`/donneurs-ordre/${donneurId}`, premiereErreur(parsed));

  const supabase = await createClient();
  const { error } = await supabase.from("donneurs_ordre").update(parsed.data).eq("id", donneurId);
  if (error) redirectWithError(`/donneurs-ordre/${donneurId}`, "La mise à jour a échoué.");

  await enregistrerJournal(supabase, "donneurs_ordre", donneurId, utilisateur.id, { action: "maj" });
  revalidatePath("/donneurs-ordre");
  revalidatePath(`/donneurs-ordre/${donneurId}`);
  redirect(`/donneurs-ordre/${donneurId}?info=${encodeURIComponent("Donneur d'ordre enregistré.")}`);
}

const ContactSchema = z.object({
  contact_id: entier,
  client_id: entier,
  donneur_ordre_id: entier,
  nom: obligatoire("Le nom du contact est obligatoire."),
  prenom: texte,
  civilite: texte,
  fonction: texte,
  email: texte,
  telephone: texte,
  mobile: texte,
  fax: texte,
  observations: texte,
});

/** Contact d'un client ou d'un donneur d'ordre : création si `contact_id` est vide, sinon mise à jour. */
export async function enregistrerContact(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const retour = retourSur(formData, "/clients");
  const parsed = ContactSchema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) redirectWithError(retour, premiereErreur(parsed));
  const { contact_id, ...contact } = parsed.data;
  if (!contact.client_id && !contact.donneur_ordre_id) redirectWithError(retour, "Le contact doit être rattaché à un client ou à un donneur d'ordre.");

  const supabase = await createClient();
  if (contact_id) {
    const { error } = await supabase.from("contacts").update(contact).eq("id", contact_id);
    if (error) redirectWithError(retour, "La mise à jour du contact a échoué.");
    await enregistrerJournal(supabase, "contacts", contact_id, utilisateur.id, { action: "maj" });
  } else {
    const { data: created, error } = await supabase.from("contacts").insert(contact).select("id").single();
    if (error || !created) redirectWithError(retour, "La création du contact a échoué.");
    await enregistrerJournal(supabase, "contacts", created.id, utilisateur.id, { action: "creation" });
  }

  revalidatePath(retour);
  redirect(retour);
}

export async function supprimerContact(formData: FormData) {
  const { utilisateur } = await requireUtilisateur();
  const retour = retourSur(formData, "/clients");
  const contactId = identifiant.safeParse(formData.get("contact_id"));
  if (!contactId.success) redirectWithError(retour, "Contact introuvable.");

  const supabase = await createClient();
  const { error } = await supabase.from("contacts").delete().eq("id", contactId.data);
  if (error) redirectWithError(retour, "La suppression du contact a échoué (il est peut-être référencé par une intervention).");

  await enregistrerJournal(supabase, "contacts", contactId.data, utilisateur.id, { action: "suppression" });
  revalidatePath(retour);
  redirect(retour);
}

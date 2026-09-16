import { createClient } from "@/lib/supabase/server";
import { genererCerfaPdf } from "@/lib/cerfa-pdf";
import { exigerUtilisateur } from "@/lib/action-utils";

export const dynamic = "force-dynamic";

/** Aperçu du certificat d'étanchéité d'un équipement (sans archivage ni marquage). */
export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const refus = await exigerUtilisateur(supabase);
  if (refus) return refus;

  const { cerfa, erreurs } = await genererCerfaPdf(supabase, Number(id));
  if (!cerfa) return new Response(`Certificat non générable :\n- ${erreurs.join("\n- ")}`, { status: 422, headers: { "Content-Type": "text/plain; charset=utf-8" } });

  return new Response(Buffer.from(cerfa.octets), {
    headers: { "Content-Type": "application/pdf", "Content-Disposition": `inline; filename="${encodeURIComponent(cerfa.nomFichier)}"`, "Cache-Control": "no-store" },
  });
}

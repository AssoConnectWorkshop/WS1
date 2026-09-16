import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { genererBonPdf } from "@/lib/bon-pdf";

export const dynamic = "force-dynamic";

/** Rendu à la volée du rapport d'intervention ; la version archivée est dans Storage (`chemin_bon_pdf`). */
export async function GET(_request: Request, { params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return new Response("Non autorisé", { status: 401 });

  let admin = null;
  try {
    admin = createAdminClient();
  } catch {
    admin = null;
  }

  const bon = await genererBonPdf(supabase, admin, Number(id));
  if (!bon) return new Response("Intervention introuvable", { status: 404 });

  return new Response(Buffer.from(bon.octets), {
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="${encodeURIComponent(bon.nomFichier)}"`,
      "Cache-Control": "no-store",
    },
  });
}

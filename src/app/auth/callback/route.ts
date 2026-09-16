import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { cheminInterne } from "@/lib/redirections";

/**
 * Échange le code envoyé par e-mail (invitation ou réinitialisation de mot de passe)
 * contre une session. URL à déclarer dans Supabase Auth : voir README / docs/plan/etape-3.md.
 */
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = cheminInterne(searchParams.get("next"));

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(`${origin}${next}`);
    }
  }

  return NextResponse.redirect(`${origin}/login?error=auth_callback`);
}

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { BOUTON_PRIMAIRE, BOUTON_SECONDAIRE } from "@/components/ui/boutons";

const ERROR_MESSAGES: Record<string, string> = {
  missing_fields: "E-mail et mot de passe requis.",
  invalid_credentials: "E-mail ou mot de passe incorrect.",
  auth_callback: "Le lien a expiré ou est invalide. Demandez un nouveau lien.",
  unavailable: "Le service est momentanément indisponible. Réessayez dans un instant.",
};

async function login(formData: FormData) {
  "use server";
  const email = formData.get("email");
  const password = formData.get("password");
  const next = formData.get("next");

  if (typeof email !== "string" || typeof password !== "string" || !email || !password) {
    redirect("/login?error=missing_fields");
  }

  // Le SDK Supabase peut lever (réseau, service indisponible) plutôt que renvoyer
  // { error } : on isole l'appel pour ne jamais laisser planter la Server Action et
  // afficher la page d'erreur générique de Next.js à la place du message en français.
  let errorCode: string | null = null;
  try {
    const supabase = await createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) errorCode = "invalid_credentials";
  } catch {
    errorCode = "unavailable";
  }

  if (errorCode) {
    redirect(`/login?error=${errorCode}`);
  }

  redirect(typeof next === "string" && next.startsWith("/") ? next : "/");
}

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string; next?: string }>;
}) {
  const { error, next } = await searchParams;

  return (
    <main className="flex min-h-screen items-center justify-center p-8">
      <form action={login} className="flex w-full max-w-sm flex-col gap-4 rounded-xl border p-8">
        <h1 className="text-2xl font-bold">ClimAccess</h1>
        <p className="text-sm opacity-70">Connexion gestionnaires FMC</p>

        {error && (
          <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">
            {ERROR_MESSAGES[error] ?? "Une erreur est survenue. Réessayez."}
          </p>
        )}

        {next && <input type="hidden" name="next" value={next} />}

        <label className="flex flex-col gap-1 text-sm">
          E-mail
          <input
            name="email"
            type="email"
            required
            autoComplete="email"
            className="rounded-md border px-3 py-2"
          />
        </label>

        <label className="flex flex-col gap-1 text-sm">
          Mot de passe
          <input
            name="password"
            type="password"
            required
            autoComplete="current-password"
            className="rounded-md border px-3 py-2"
          />
        </label>

        <button type="submit" className={BOUTON_PRIMAIRE}>
          Se connecter
        </button>

        <a href="/reset-password" className={BOUTON_SECONDAIRE}>
          Mot de passe oublié ?
        </a>
      </form>
    </main>
  );
}

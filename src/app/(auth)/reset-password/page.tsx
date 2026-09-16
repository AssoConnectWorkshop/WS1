import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { emailAutorise } from "@/lib/garde-emails";

async function requestReset(formData: FormData) {
  "use server";
  const email = formData.get("email");
  if (typeof email !== "string" || !email) {
    redirect("/reset-password?error=missing_email");
  }

  const site = process.env.NEXT_PUBLIC_SITE_URL ?? "https://assoconnect-ws1.vercel.app";
  // Ne jamais révéler si l'e-mail existe ou non (évite l'énumération de comptes) :
  // le message affiché est identique quel que soit le résultat, y compris en cas
  // d'erreur réseau/service (le SDK peut lever plutôt que renvoyer { error }).
  // Liste blanche EMAILS_AUTORISES : hors liste, même message affiché mais rien n'est envoyé.
  if (!emailAutorise(email)) redirect("/reset-password?sent=1");

  try {
    const supabase = await createClient();
    await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${site}/auth/callback?next=/reset-password`,
    });
  } catch {
    // volontairement ignoré, cf. commentaire ci-dessus.
  }

  redirect("/reset-password?sent=1");
}

async function updatePassword(formData: FormData) {
  "use server";
  const password = formData.get("password");
  const confirmation = formData.get("confirmation");

  if (typeof password !== "string" || password.length < 8) {
    redirect("/reset-password?error=weak_password");
  }
  if (password !== confirmation) {
    redirect("/reset-password?error=mismatch");
  }

  let failed = false;
  try {
    const supabase = await createClient();
    const { error } = await supabase.auth.updateUser({ password });
    failed = Boolean(error);
  } catch {
    failed = true;
  }

  if (failed) {
    redirect("/reset-password?error=update_failed");
  }

  redirect("/");
}

const ERROR_MESSAGES: Record<string, string> = {
  missing_email: "Indiquez votre e-mail.",
  weak_password: "Le mot de passe doit contenir au moins 8 caractères.",
  mismatch: "Les deux mots de passe ne correspondent pas.",
  update_failed: "Impossible de mettre à jour le mot de passe. Redemandez un lien.",
};

export default async function ResetPasswordPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string; sent?: string }>;
}) {
  const { error, sent } = await searchParams;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const errorMessage = error ? (ERROR_MESSAGES[error] ?? "Une erreur est survenue. Réessayez.") : null;

  // Une session de récupération existe (l'utilisateur vient de cliquer le lien reçu par e-mail) :
  // on lui propose de choisir son nouveau mot de passe.
  if (user) {
    return (
      <main className="flex min-h-screen items-center justify-center p-8">
        <form action={updatePassword} className="flex w-full max-w-sm flex-col gap-4 rounded-xl border p-8">
          <h1 className="text-2xl font-bold">Nouveau mot de passe</h1>
          {errorMessage && (
            <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{errorMessage}</p>
          )}
          <label className="flex flex-col gap-1 text-sm">
            Nouveau mot de passe
            <input
              name="password"
              type="password"
              required
              minLength={8}
              autoComplete="new-password"
              className="rounded-md border px-3 py-2"
            />
          </label>
          <label className="flex flex-col gap-1 text-sm">
            Confirmation
            <input
              name="confirmation"
              type="password"
              required
              minLength={8}
              autoComplete="new-password"
              className="rounded-md border px-3 py-2"
            />
          </label>
          <button type="submit" className="rounded-md bg-black py-2 font-medium text-white">
            Valider
          </button>
        </form>
      </main>
    );
  }

  // Pas de session : formulaire de demande de lien de réinitialisation.
  return (
    <main className="flex min-h-screen items-center justify-center p-8">
      <form action={requestReset} className="flex w-full max-w-sm flex-col gap-4 rounded-xl border p-8">
        <h1 className="text-2xl font-bold">Mot de passe oublié</h1>
        {errorMessage && (
          <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{errorMessage}</p>
        )}
        {sent && (
          <p className="rounded-md bg-green-50 p-3 text-sm text-green-700">
            Si un compte existe pour cet e-mail, un lien de réinitialisation vient de vous être
            envoyé.
          </p>
        )}
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
        <button type="submit" className="rounded-md bg-black py-2 font-medium text-white">
          Envoyer le lien
        </button>
        <a href="/login" className="text-center text-sm underline opacity-70">
          Retour à la connexion
        </a>
      </form>
    </main>
  );
}

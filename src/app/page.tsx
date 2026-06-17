import { getOrganization, getFirstContact } from "@/lib/assoconnect";
import { createClient } from "@/lib/supabase/server";
import { siteConfig } from "@/config/site";

export const dynamic = "force-dynamic";

export default async function Home() {
  let organizationName: string | null = null;
  let adminFirstName: string | null = null;
  let prenoms: string[] = [];

  try {
    const org = await getOrganization();
    organizationName = org.name;
  } catch {
    organizationName = null;
  }

  try {
    const contact = await getFirstContact();
    adminFirstName = contact?.firstname ?? null;
  } catch {
    adminFirstName = null;
  }

  try {
    const supabase = await createClient();
    const { data } = await supabase.from("prenoms").select("nom").order("id");
    prenoms = data?.map((r) => r.nom) ?? [];
  } catch {
    prenoms = [];
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 p-8">
      <h1 className="text-4xl font-bold">Welcome Poplico</h1>
{organizationName && (
        <p className="text-2xl font-medium">{organizationName}</p>
      )}
      {adminFirstName && (
        <p className="text-xl">Admin : {adminFirstName}</p>
      )}
      {prenoms.length > 0 && (
        <ul className="text-lg">
          {prenoms.map((nom) => (
            <li key={nom}>{nom}</li>
          ))}
        </ul>
      )}
      <p className="text-lg opacity-70">{siteConfig.description}</p>
    </main>
  );
}

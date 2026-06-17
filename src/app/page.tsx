import { getOrganization } from "@/lib/assoconnect";
import { siteConfig } from "@/config/site";

export const dynamic = "force-dynamic";

export default async function Home() {
  let organizationName: string | null = null;
  try {
    const org = await getOrganization();
    organizationName = org.name;
  } catch {
    organizationName = null;
  }

  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 p-8">
      <h1 className="text-4xl font-bold">Welcome Poplico</h1>
      <p className="text-3xl">Babar</p>
      {organizationName && (
        <p className="text-2xl font-medium">{organizationName}</p>
      )}
      <p className="text-lg opacity-70">{siteConfig.description}</p>
    </main>
  );
}

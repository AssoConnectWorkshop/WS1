import { siteConfig } from "@/config/site";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 p-8">
      <h1 className="text-4xl font-bold">{siteConfig.name}</h1>
      <p className="text-lg opacity-70">{siteConfig.description}</p>
    </main>
  );
}

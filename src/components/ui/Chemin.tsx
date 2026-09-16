import { hyperlienAccess } from "@/lib/format";

/** Chemin réseau, URL ou hyperlien Access (`texte#adresse`) : lien si http(s), sinon affichage monospace. */
export function Chemin({ value }: { value: string | null | undefined }) {
  const { libelle, chemin } = hyperlienAccess(value);
  if (!chemin) return <>—</>;
  if (/^https?:\/\//i.test(chemin)) {
    return (
      <a href={chemin} target="_blank" rel="noreferrer" className="underline">
        {libelle || chemin}
      </a>
    );
  }
  return (
    <span className="font-mono text-xs" title={chemin}>
      {chemin}
    </span>
  );
}

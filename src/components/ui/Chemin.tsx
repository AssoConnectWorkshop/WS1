/** Chemin réseau ou URL : lien si http(s), sinon affichage monospace. */
export function Chemin({ value }: { value: string | null | undefined }) {
  if (!value) return <>—</>;
  if (/^https?:\/\//i.test(value)) {
    return (
      <a href={value} target="_blank" rel="noreferrer" className="underline">
        {value}
      </a>
    );
  }
  return <span className="font-mono text-xs">{value}</span>;
}

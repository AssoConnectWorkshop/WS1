/** Bandeaux erreur / avertissement / info portés par l'URL après une Server Action. */
export function Messages({ sp }: { sp: Record<string, string | undefined> }) {
  return (
    <>
      {sp.erreur && <p className="rounded-md bg-red-50 p-3 text-sm text-red-700">{sp.erreur}</p>}
      {sp.avertissement && <p className="rounded-md bg-yellow-50 p-3 text-sm text-yellow-800">{sp.avertissement}</p>}
      {sp.info && <p className="rounded-md bg-blue-50 p-3 text-sm text-blue-800">{sp.info}</p>}
    </>
  );
}

/** Champ monétaire : suffixe « € » dans la zone de saisie, comme les tarifs affichés dans Access (« 65,00 € »). */
export function Euro({ children }: { children: React.ReactNode }) {
  return (
    <span className="relative inline-flex w-full items-center">
      {children}
      <span className="pointer-events-none absolute right-2 text-xs opacity-60">€</span>
    </span>
  );
}

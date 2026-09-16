"use client";

import { useRouter } from "next/navigation";

/** Ligne de tableau ouvrable au double-clic (comme la feuille de données Access). */
export function LigneOuvrable({ href, className, children }: { href: string | null | undefined; className?: string; children: React.ReactNode }) {
  const router = useRouter();
  return (
    <tr
      className={className}
      title={href ? "Double-clic pour ouvrir" : undefined}
      onDoubleClick={(e) => {
        if (!href) return;
        const cible = e.target as HTMLElement;
        if (cible.closest("a, button, input, select, textarea")) return;
        router.push(href);
      }}
    >
      {children}
    </tr>
  );
}

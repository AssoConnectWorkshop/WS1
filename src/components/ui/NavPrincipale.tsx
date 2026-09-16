"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export type ElementNav = { href: string; label: string };

/** Barre de navigation : l'entrée de la section courante est surlignée (fond bleu clair). */
export function NavPrincipale({ items }: { items: ElementNav[] }) {
  const pathname = usePathname();
  // Correspondance la plus longue : /taches/tech surligne « Todo tech », pas « Todo product ».
  const actif = items
    .filter((i) => (i.href === "/" ? pathname === "/" : pathname === i.href || pathname.startsWith(`${i.href}/`)))
    .sort((a, b) => b.href.length - a.href.length)[0];

  return (
    <nav className="flex flex-wrap gap-1 text-sm">
      {items.map((item) => (
        <Link
          key={item.href}
          href={item.href}
          aria-current={actif?.href === item.href ? "page" : undefined}
          className={`rounded px-2 py-1 hover:bg-black/5 dark:hover:bg-white/10 ${actif?.href === item.href ? "bg-sky-100 font-medium text-sky-900 dark:bg-sky-900/40 dark:text-sky-100" : ""}`}
        >
          {item.label}
        </Link>
      ))}
    </nav>
  );
}

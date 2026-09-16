"use client";

import { useState } from "react";

/**
 * Bouton « Vers Fichier » d'Access : ouvre l'URL si http(s), sinon copie le chemin réseau
 * (le navigateur ne peut pas ouvrir un partage de fichiers).
 */
export function BoutonVersFichier({ chemin, className }: { chemin: string | null | undefined; className?: string }) {
  const [copie, setCopie] = useState(false);
  if (!chemin) return <span className={`${className} cursor-default opacity-50`}>Vers Fichier</span>;
  if (/^https?:\/\//i.test(chemin)) {
    return (
      <a href={chemin} target="_blank" rel="noreferrer" className={className}>
        Vers Fichier
      </a>
    );
  }
  return (
    <button
      type="button"
      title={chemin}
      className={className}
      onClick={() => {
        void navigator.clipboard?.writeText(chemin);
        setCopie(true);
        setTimeout(() => setCopie(false), 1500);
      }}
    >
      {copie ? "Chemin copié" : "Vers Fichier"}
    </button>
  );
}

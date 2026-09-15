import type { Tone } from "@/components/ui/Badge";

/** Couleurs des types d'intervention, comme dans Access (legacy/analysis/02_interventions.md §1.1). */
export function typeInterventionTone(code: number | null | undefined): Tone {
  switch (code) {
    case 1:
    case 13:
      return "blue"; // Entretien, Maintenance chaudière
    case 2:
      return "green"; // Dépannage
    case 6:
    case 7:
    case 8:
      return "purple"; // En création, Désenfumage, Réalisée attente devis signé
    case 5:
      return "orange"; // En travaux
    case 3:
    case 4:
    case 9:
    case 12:
    case 14:
      return "pink"; // Devis SAV, Autre, Audit, Devis SAV (TR), Appel
    default:
      return "gray";
  }
}

/** Statut de devis : 1 jaune, 3 bleu, 5 gris, 6 rouge (brief étape 4 §4.8). Autres codes en gris. */
export function statutDevisTone(code: number | null | undefined): Tone {
  switch (code) {
    case 1:
      return "yellow";
    case 3:
      return "blue";
    case 5:
      return "gray";
    case 6:
      return "green";
    case 4:
      return "orange";
    case 2:
      return "gray";
    default:
      return "gray";
  }
}

export function statutInterventionTone(code: number | null | undefined): Tone {
  switch (code) {
    case 9:
      return "orange"; // réalisé, à valider
    case 7:
      return "green"; // clôturé
    case 8:
    case 20:
      return "gray"; // annulé
    case -1:
    case 2:
      return "red"; // matériel
    case 17:
      return "red"; // ne pas intervenir
    case 1:
      return "blue"; // à planifier
    default:
      return "gray";
  }
}

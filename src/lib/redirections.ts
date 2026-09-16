/**
 * N'accepte qu'un chemin interne pour une redirection après connexion : refuse les URL absolues,
 * les `//hote` (protocole relatif), les `/\hote` et tout ce qui contient un schéma.
 */
export function cheminInterne(valeur: unknown, defaut = "/"): string {
  if (typeof valeur !== "string" || valeur.length === 0 || valeur.length > 2000) return defaut;
  if (!valeur.startsWith("/") || valeur.startsWith("//") || valeur.startsWith("/\\")) return defaut;
  if (/[\r\n]|:\/\//.test(valeur)) return defaut;
  return valeur;
}

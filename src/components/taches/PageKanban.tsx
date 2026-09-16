import { createClient } from "@/lib/supabase/server";
import { Messages } from "@/components/ui/Messages";
import { Kanban, type Tache } from "@/components/taches/Kanban";
import { toStringParams } from "@/lib/list-params";
import type { Tableau } from "@/lib/taches";

/** Kanban « À faire » (projet) ou « Todo tech » (développement) selon le tableau. */
export async function PageKanban({ tableau, searchParams }: { tableau: Tableau; searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = toStringParams(await searchParams);
  const supabase = await createClient();
  const { data, error } = await supabase.from("taches").select("id, titre, description, colonne, ordre, created_at, updated_at").eq("tableau", tableau).order("ordre").order("id");

  return (
    <div className="flex flex-col gap-3 p-4">
      <Messages sp={sp} />
      {error && <div className="rounded border border-red-300 bg-red-50 p-3 text-sm text-red-800">Erreur : {error.message}</div>}
      <Kanban taches={(data ?? []) as Tache[]} tableau={tableau} />
    </div>
  );
}


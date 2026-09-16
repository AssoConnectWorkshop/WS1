import { PageKanban } from "@/components/taches/PageKanban";

export const dynamic = "force-dynamic";

export default function TodoTechPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  return <PageKanban tableau="tech" searchParams={searchParams} />;
}

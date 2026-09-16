import { PageKanban } from "@/components/taches/PageKanban";

export const dynamic = "force-dynamic";

export default function TachesPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  return <PageKanban tableau="projet" searchParams={searchParams} />;
}

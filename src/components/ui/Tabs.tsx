import Link from "next/link";

export function Tabs({
  tabs,
  active,
  searchParams,
}: {
  tabs: { key: string; label: string }[];
  active: string;
  searchParams?: Record<string, string | undefined>;
}) {
  return (
    <div className="flex gap-1 overflow-x-auto border-b">
      {tabs.map((tab) => {
        const params = new URLSearchParams();
        for (const [k, v] of Object.entries(searchParams ?? {})) {
          if (v && k !== "onglet") params.set(k, v);
        }
        params.set("onglet", tab.key);
        const isActive = tab.key === active;
        return (
          <Link
            key={tab.key}
            href={`?${params.toString()}`}
            className={`whitespace-nowrap border-b-2 px-3 py-2 text-sm ${
              isActive ? "border-black font-medium dark:border-white" : "border-transparent opacity-60 hover:opacity-100"
            }`}
          >
            {tab.label}
          </Link>
        );
      })}
    </div>
  );
}

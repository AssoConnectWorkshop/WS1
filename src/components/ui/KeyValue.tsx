export function KeyValue({ items }: { items: { label: string; value: React.ReactNode }[] }) {
  return (
    <dl className="grid grid-cols-1 gap-x-6 gap-y-2 sm:grid-cols-2">
      {items.map((item, i) => (
        <div key={i} className="flex flex-col gap-0.5 border-b pb-1 text-sm sm:border-0 sm:pb-0">
          <dt className="text-xs font-medium uppercase tracking-wide opacity-60">{item.label}</dt>
          <dd>{item.value ?? "—"}</dd>
        </div>
      ))}
    </dl>
  );
}

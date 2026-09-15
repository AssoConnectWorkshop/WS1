export type FilterField =
  | { type: "text"; name: string; label: string; placeholder?: string }
  | { type: "select"; name: string; label: string; options: { value: string; label: string }[] }
  | { type: "multiselect"; name: string; label: string; options: { value: string; label: string }[] }
  | { type: "checkbox"; name: string; label: string }
  | { type: "date"; name: string; label: string };

export function FilterBar({
  fields,
  values,
  multiValues,
}: {
  fields: FilterField[];
  values: Record<string, string | undefined>;
  multiValues?: Record<string, string[] | undefined>;
}) {
  return (
    <form method="GET" className="flex flex-wrap items-end gap-3 rounded-lg border p-3 text-sm">
      {fields.map((f) => {
        if (f.type === "checkbox") {
          return (
            <label key={f.name} className="flex items-center gap-1.5 pb-1.5">
              <input type="checkbox" name={f.name} value="1" defaultChecked={values[f.name] === "1"} />
              {f.label}
            </label>
          );
        }
        if (f.type === "select") {
          return (
            <label key={f.name} className="flex flex-col gap-1">
              <span className="text-xs opacity-60">{f.label}</span>
              <select
                name={f.name}
                defaultValue={values[f.name] ?? ""}
                className="rounded-md border px-2 py-1"
              >
                <option value="">Tous</option>
                {f.options.map((o) => (
                  <option key={o.value} value={o.value}>
                    {o.label}
                  </option>
                ))}
              </select>
            </label>
          );
        }
        if (f.type === "multiselect") {
          return (
            <label key={f.name} className="flex flex-col gap-1">
              <span className="text-xs opacity-60">{f.label}</span>
              <select
                name={f.name}
                multiple
                defaultValue={multiValues?.[f.name] ?? []}
                className="min-w-32 rounded-md border px-2 py-1"
                size={3}
              >
                {f.options.map((o) => (
                  <option key={o.value} value={o.value}>
                    {o.label}
                  </option>
                ))}
              </select>
            </label>
          );
        }
        return (
          <label key={f.name} className="flex flex-col gap-1">
            <span className="text-xs opacity-60">{f.label}</span>
            <input
              type={f.type === "date" ? "date" : "text"}
              name={f.name}
              defaultValue={values[f.name] ?? ""}
              placeholder={f.type === "text" ? f.placeholder : undefined}
              className="rounded-md border px-2 py-1"
            />
          </label>
        );
      })}
      <button type="submit" className="rounded-md bg-black px-3 py-1.5 text-white">
        Filtrer
      </button>
      <a href="?" className="rounded-md border px-3 py-1.5">
        Réinitialiser
      </a>
    </form>
  );
}

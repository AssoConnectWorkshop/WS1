export const CHAMP = "rounded-md border px-3 py-2";

export function Champ({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="flex flex-col gap-1 text-sm">
      {label}
      {children}
    </label>
  );
}

export function Section({ titre, children }: { titre: string; children: React.ReactNode }) {
  return (
    <fieldset className="flex flex-col gap-3 rounded-xl border p-4">
      <legend className="px-1 text-sm font-semibold opacity-70">{titre}</legend>
      {children}
    </fieldset>
  );
}

export function Case({ name, label, checked, disabled }: { name: string; label: string; checked?: boolean | null; disabled?: boolean }) {
  return (
    <label className="flex items-center gap-1.5 text-sm">
      <input type="checkbox" name={name} value="1" defaultChecked={!!checked} disabled={disabled} />
      {label}
    </label>
  );
}

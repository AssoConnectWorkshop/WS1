export type Tone = "blue" | "green" | "pink" | "orange" | "purple" | "gray" | "red" | "yellow";

const TONE_CLASSES: Record<Tone, string> = {
  blue: "bg-blue-100 text-blue-800 dark:bg-blue-900/40 dark:text-blue-200",
  green: "bg-green-100 text-green-800 dark:bg-green-900/40 dark:text-green-200",
  pink: "bg-pink-100 text-pink-800 dark:bg-pink-900/40 dark:text-pink-200",
  orange: "bg-orange-100 text-orange-800 dark:bg-orange-900/40 dark:text-orange-200",
  purple: "bg-purple-100 text-purple-800 dark:bg-purple-900/40 dark:text-purple-200",
  gray: "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-200",
  red: "bg-red-100 text-red-800 dark:bg-red-900/40 dark:text-red-200",
  yellow: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/40 dark:text-yellow-200",
};

export function Badge({ tone = "gray", children }: { tone?: Tone; children: React.ReactNode }) {
  return (
    <span className={`inline-block whitespace-nowrap rounded-full px-2 py-0.5 text-xs font-medium ${TONE_CLASSES[tone]}`}>
      {children}
    </span>
  );
}

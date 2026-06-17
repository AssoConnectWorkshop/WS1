export type NavItem = {
  label: string;
  href: string;
};

export const siteConfig = {
  name: "WS1",
  description: "Next.js + Supabase app deployed on Netlify.",
  nav: [
    { label: "Home", href: "/" },
    { label: "Organization", href: "/organization" },
  ] satisfies NavItem[],
};

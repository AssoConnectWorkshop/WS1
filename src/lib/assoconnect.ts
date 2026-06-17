import "server-only";

const BASE_URL = "https://app.assoconnect.com/api/v1";

export type Organization = {
  "@id": string;
  "@type": string;
  brand: string;
  isAdvanced: boolean;
  isLegalIndependent: boolean;
  logoUrl: string;
  name: string;
  parent: string | null;
  phoneNumber: string;
  url: string;
};

async function request<T>(path: string): Promise<T> {
  const token = process.env.ASSOCONNECT_API_KEY;
  if (!token) {
    throw new Error("ASSOCONNECT_API_KEY is not set");
  }

  const res = await fetch(`${BASE_URL}${path}`, {
    headers: {
      Accept: "application/ld+json",
      "X-AUTH-TOKEN": token,
    },
    cache: "no-store",
  });

  if (!res.ok) {
    throw new Error(`AssoConnect ${path} failed: ${res.status} ${res.statusText}`);
  }

  return res.json() as Promise<T>;
}

export function getOrganization(ulid = process.env.ASSOCONNECT_ORGANIZATION_ULID) {
  if (!ulid) {
    throw new Error("ASSOCONNECT_ORGANIZATION_ULID is not set");
  }
  return request<Organization>(`/organizations/${ulid}`);
}

export type Contact = {
  "@id": string;
  "@type": string;
  type: "person" | "structure";
  firstname?: string;
  lastname?: string;
  email?: string;
};

type ContactCollection = {
  "hydra:member": Contact[];
};

export async function getFirstContact(): Promise<Contact | null> {
  const ulid = process.env.ASSOCONNECT_ORGANIZATION_ULID;
  if (!ulid) throw new Error("ASSOCONNECT_ORGANIZATION_ULID is not set");

  const data = await request<ContactCollection>(
    `/organizations/${ulid}/contacts?type=person&itemsPerPage=1`
  );
  return data["hydra:member"]?.[0] ?? null;
}

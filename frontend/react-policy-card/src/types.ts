export type PolicyCardStatus = "eligible" | "maybe" | "ineligible" | "saved";

export type PolicyBenefit = {
  label: string;
  value: string;
};

export type PolicyCardData = {
  id: string;
  title: string;
  summary?: string;
  benefits: PolicyBenefit[];
  location?: string;
  educationBackground?: string;
  status: PolicyCardStatus;
  sourceUrl?: string;
  updatedAtISO: string; // for cache freshness + UI
};


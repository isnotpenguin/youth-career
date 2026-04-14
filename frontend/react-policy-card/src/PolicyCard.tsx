import React from "react";
import type { PolicyCardData, PolicyCardStatus } from "./types";
import { cachePolicyCard } from "./policyCardCache";

function statusColors(status: PolicyCardStatus) {
  switch (status) {
    case "eligible":
      return { bg: "#E8F7EE", fg: "#166534", border: "#BBF7D0" };
    case "maybe":
      return { bg: "#FFF7ED", fg: "#9A3412", border: "#FED7AA" };
    case "ineligible":
      return { bg: "#FEF2F2", fg: "#991B1B", border: "#FECACA" };
    case "saved":
      return { bg: "#EEF2FF", fg: "#3730A3", border: "#C7D2FE" };
  }
}

export type PolicyCardProps = {
  card: PolicyCardData;
  onToggleSave?: (nextSaved: boolean) => void | Promise<void>;
};

export function PolicyCard({ card, onToggleSave }: PolicyCardProps) {
  const [isOnline, setIsOnline] = React.useState<boolean>(
    typeof navigator === "undefined" ? true : navigator.onLine
  );
  const [saving, setSaving] = React.useState(false);
  const isSaved = card.status === "saved";
  const colors = statusColors(card.status);

  React.useEffect(() => {
    function onOnline() {
      setIsOnline(true);
    }
    function onOffline() {
      setIsOnline(false);
    }
    window.addEventListener("online", onOnline);
    window.addEventListener("offline", onOffline);
    return () => {
      window.removeEventListener("online", onOnline);
      window.removeEventListener("offline", onOffline);
    };
  }, []);

  async function toggleSave() {
    setSaving(true);
    try {
      const nextSaved = !isSaved;
      const nextCard: PolicyCardData = {
        ...card,
        status: nextSaved ? "saved" : "maybe",
        updatedAtISO: new Date().toISOString(),
      };
      // Always cache locally so the UI works offline.
      await cachePolicyCard(nextCard);
      await onToggleSave?.(nextSaved);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div style={styles.card}>
      {!isOnline && (
        <div style={styles.offlineBanner}>
          Offline mode: showing cached policy cards
        </div>
      )}

      <div style={styles.headerRow}>
        <div style={{ minWidth: 0 }}>
          <div style={styles.title}>{card.title}</div>
          {card.summary ? <div style={styles.summary}>{card.summary}</div> : null}
          <div style={styles.metaRow}>
            {card.location ? <span style={styles.metaChip}>{card.location}</span> : null}
            {card.educationBackground ? (
              <span style={styles.metaChip}>{card.educationBackground}</span>
            ) : null}
            <span style={styles.metaText}>
              Updated {new Date(card.updatedAtISO).toLocaleDateString()}
            </span>
          </div>
        </div>

        <div
          style={{
            ...styles.statusPill,
            background: colors.bg,
            color: colors.fg,
            borderColor: colors.border,
          }}
          aria-label={`status:${card.status}`}
        >
          {card.status}
        </div>
      </div>

      <div style={styles.benefits}>
        {card.benefits.map((b, idx) => (
          <div key={idx} style={styles.benefitRow}>
            <div style={styles.benefitLabel}>{b.label}</div>
            <div style={styles.benefitValue}>{b.value}</div>
          </div>
        ))}
      </div>

      <div style={styles.footerRow}>
        <button
          onClick={toggleSave}
          disabled={saving}
          style={{
            ...styles.saveButton,
            background: isSaved ? "#111827" : "#2563EB",
          }}
        >
          {saving ? "Saving…" : isSaved ? "Saved" : "Save"}
        </button>

        {card.sourceUrl ? (
          <a href={card.sourceUrl} target="_blank" rel="noreferrer" style={styles.link}>
            View source
          </a>
        ) : (
          <span />
        )}
      </div>
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  card: {
    border: "1px solid #E5E7EB",
    borderRadius: 16,
    padding: 16,
    background: "#FFFFFF",
    boxShadow: "0 1px 2px rgba(0,0,0,0.06)",
    display: "flex",
    flexDirection: "column",
    gap: 12,
    maxWidth: 720,
  },
  offlineBanner: {
    background: "#FFFBEB",
    color: "#92400E",
    border: "1px solid #FDE68A",
    borderRadius: 12,
    padding: "8px 10px",
    fontSize: 13,
  },
  headerRow: { display: "flex", gap: 12, alignItems: "flex-start", justifyContent: "space-between" },
  title: { fontSize: 18, fontWeight: 700, color: "#111827", lineHeight: 1.25 },
  summary: { fontSize: 14, color: "#374151", marginTop: 6, lineHeight: 1.35 },
  metaRow: { marginTop: 10, display: "flex", gap: 8, flexWrap: "wrap", alignItems: "center" },
  metaChip: {
    fontSize: 12,
    padding: "3px 8px",
    background: "#F3F4F6",
    border: "1px solid #E5E7EB",
    borderRadius: 999,
    color: "#111827",
  },
  metaText: { fontSize: 12, color: "#6B7280" },
  statusPill: {
    fontSize: 12,
    padding: "5px 10px",
    borderRadius: 999,
    border: "1px solid",
    textTransform: "capitalize",
    whiteSpace: "nowrap",
  },
  benefits: { display: "flex", flexDirection: "column", gap: 10 },
  benefitRow: {
    display: "flex",
    gap: 12,
    alignItems: "baseline",
    justifyContent: "space-between",
    borderTop: "1px solid #F3F4F6",
    paddingTop: 10,
  },
  benefitLabel: { fontSize: 13, color: "#6B7280", flex: 1 },
  benefitValue: { fontSize: 14, color: "#111827", fontWeight: 600, textAlign: "right", flex: 1 },
  footerRow: { display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: 4 },
  saveButton: {
    border: "none",
    color: "white",
    padding: "10px 12px",
    borderRadius: 12,
    fontWeight: 700,
    cursor: "pointer",
    minWidth: 110,
  },
  link: { fontSize: 13, color: "#2563EB", textDecoration: "none" },
};


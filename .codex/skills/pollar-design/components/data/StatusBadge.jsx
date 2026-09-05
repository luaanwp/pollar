import React from "react";
import { Icon } from "../core/Icon.jsx";

const TONES = {
  neutral: { fg: "var(--text-secondary)", bg: "var(--neutral-soft)", bd: "var(--border)" },
  info: { fg: "var(--info)", bg: "var(--info-soft)", bd: "transparent" },
  success: { fg: "var(--positive)", bg: "var(--positive-soft)", bd: "transparent" },
  warning: { fg: "var(--warning)", bg: "var(--warning-soft)", bd: "transparent" },
  danger: { fg: "var(--negative)", bg: "var(--negative-soft)", bd: "transparent" },
};

export function StatusBadge({ tone = "neutral", icon, children, size = "standard", style, ...rest }) {
  const t = TONES[tone] || TONES.neutral;
  const compact = size === "compact";
  return (
    <span
      style={{
        display: "inline-flex", alignItems: "center", gap: 6,
        height: compact ? 20 : 24, padding: compact ? "0 8px" : "0 10px",
        borderRadius: "var(--radius-pill)",
        background: t.bg, color: t.fg, border: "1px solid " + t.bd,
        fontSize: compact ? 11 : "var(--text-caption)",
        fontWeight: 600, lineHeight: 1, whiteSpace: "nowrap", ...style,
      }}
      {...rest}
    >
      {icon && <Icon name={icon} size={compact ? 12 : 14} />}
      {children}
    </span>
  );
}

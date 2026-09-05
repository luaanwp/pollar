import React from "react";
import { Icon } from "../core/Icon.jsx";

const TONES = {
  info: { fg: "var(--info)", bg: "var(--info-soft)", icon: "info" },
  success: { fg: "var(--positive)", bg: "var(--positive-soft)", icon: "circle-check" },
  warning: { fg: "var(--warning)", bg: "var(--warning-soft)", icon: "triangle-alert" },
  danger: { fg: "var(--negative)", bg: "var(--negative-soft)", icon: "circle-alert" },
  neutral: { fg: "var(--text-secondary)", bg: "var(--neutral-soft)", icon: "info" },
};

export function Banner({ tone = "info", title, children, icon, actions, onDismiss, style, ...rest }) {
  const t = TONES[tone] || TONES.info;
  return (
    <div
      role={tone === "danger" ? "alert" : "status"}
      style={{
        display: "flex", alignItems: "flex-start", gap: 12,
        padding: "12px 14px", background: t.bg,
        border: "1px solid var(--border)", borderRadius: "var(--radius-md)",
        ...style,
      }}
      {...rest}
    >
      <Icon name={icon || t.icon} size={18} color={t.fg} style={{ marginTop: 1 }} />
      <div style={{ flex: 1, minWidth: 0, display: "flex", flexDirection: "column", gap: 4 }}>
        {title && <span style={{ fontSize: 14, fontWeight: 600, color: "var(--text-primary)" }}>{title}</span>}
        {children && <span style={{ fontSize: 13, lineHeight: 1.5, color: "var(--text-secondary)" }}>{children}</span>}
        {actions && <div style={{ display: "flex", gap: 8, marginTop: 4 }}>{actions}</div>}
      </div>
      {onDismiss && (
        <button type="button" onClick={onDismiss} aria-label="Fechar aviso"
          style={{ background: "none", border: "none", padding: 4, cursor: "pointer", color: "var(--text-muted)", lineHeight: 0 }}>
          <Icon name="x" size={16} />
        </button>
      )}
    </div>
  );
}

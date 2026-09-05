import React from "react";
import { Icon } from "../core/Icon.jsx";

const TONES = { success: { fg: "var(--positive)", icon: "circle-check" }, info: { fg: "var(--info)", icon: "info" }, warning: { fg: "var(--warning)", icon: "triangle-alert" } };

export function Toast({ tone = "success", message, actionLabel, onAction, onDismiss, style, ...rest }) {
  const t = TONES[tone] || TONES.success;
  return (
    <div
      role="status"
      aria-live="polite"
      style={{
        display: "inline-flex", alignItems: "center", gap: 12,
        padding: "12px 14px", maxWidth: 420,
        background: "var(--surface-canvas)",
        border: "1px solid var(--border)", borderRadius: "var(--radius-md)",
        boxShadow: "var(--elevation-2)",
        animation: "fin-toast-in var(--duration-panel) var(--ease-decelerate)",
        ...style,
      }}
      {...rest}
    >
      <Icon name={t.icon} size={18} color={t.fg} />
      <span style={{ flex: 1, fontSize: 14, color: "var(--text-primary)" }}>{message}</span>
      {actionLabel && (
        <button type="button" onClick={onAction}
          style={{ background: "none", border: "none", padding: 0, font: "inherit", fontSize: 13, fontWeight: 600, color: "var(--primary)", cursor: "pointer" }}>
          {actionLabel}
        </button>
      )}
      {onDismiss && (
        <button type="button" onClick={onDismiss} aria-label="Fechar" style={{ background: "none", border: "none", padding: 2, cursor: "pointer", color: "var(--text-muted)", lineHeight: 0 }}>
          <Icon name="x" size={14} />
        </button>
      )}
    </div>
  );
}

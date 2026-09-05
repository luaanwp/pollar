import React from "react";
import { Icon } from "../core/Icon.jsx";

export function Dialog({ open = true, title, description, tone = "default", icon, children, actions, onClose, width = 440, inline = false, style, ...rest }) {
  if (!open) return null;
  const accent = tone === "danger" ? "var(--negative)" : "var(--primary)";
  const panel = (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={title}
      style={{
        width, maxWidth: "100%",
        background: "var(--surface-canvas)",
        border: "1px solid var(--border)",
        borderRadius: "var(--radius-lg)",
        boxShadow: "var(--elevation-3)",
        overflow: "hidden",
        animation: "fin-dialog-in var(--duration-panel) var(--ease-decelerate)",
        ...style,
      }}
      {...rest}
    >
      <div style={{ display: "flex", alignItems: "flex-start", gap: 12, padding: "20px 20px 0" }}>
        {(icon || tone === "danger") && (
          <span style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 36, height: 36, flex: "none", borderRadius: "var(--radius-md)", background: tone === "danger" ? "var(--negative-soft)" : "var(--primary-soft)", color: accent }}>
            <Icon name={icon || "triangle-alert"} size={20} />
          </span>
        )}
        <div style={{ flex: 1, minWidth: 0 }}>
          {title && <div style={{ fontSize: "var(--text-h3)", fontWeight: "var(--fw-h3)", lineHeight: "var(--lh-h3)", color: "var(--text-primary)" }}>{title}</div>}
          {description && <div style={{ marginTop: 6, fontSize: 14, lineHeight: 1.5, color: "var(--text-secondary)" }}>{description}</div>}
        </div>
        {onClose && (
          <button type="button" onClick={onClose} aria-label="Fechar" style={{ background: "none", border: "none", padding: 4, cursor: "pointer", color: "var(--text-muted)", lineHeight: 0 }}>
            <Icon name="x" size={18} />
          </button>
        )}
      </div>
      {children && <div style={{ padding: "16px 20px 0" }}>{children}</div>}
      {actions && (
        <div style={{ display: "flex", justifyContent: "flex-end", gap: 12, padding: "20px", marginTop: 4 }}>{actions}</div>
      )}
    </div>
  );
  if (inline) return panel;
  return (
    <div style={{ position: "fixed", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", padding: 24, background: "rgba(19,32,29,.36)", zIndex: 60 }} onClick={onClose}>
      <div onClick={(e) => e.stopPropagation()}>{panel}</div>
    </div>
  );
}

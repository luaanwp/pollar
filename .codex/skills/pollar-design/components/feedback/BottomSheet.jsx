import React from "react";
import { Icon } from "../core/Icon.jsx";

export function BottomSheet({ open = true, title, children, actions, onClose, inline = false, style, ...rest }) {
  if (!open) return null;
  const panel = (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={title}
      style={{
        width: "100%",
        background: "var(--surface-canvas)",
        borderTopLeftRadius: "var(--radius-lg)",
        borderTopRightRadius: "var(--radius-lg)",
        borderTop: "1px solid var(--border)",
        boxShadow: "var(--elevation-3)",
        animation: "fin-sheet-in var(--duration-panel) var(--ease-decelerate)",
        ...style,
      }}
      {...rest}
    >
      <div style={{ display: "flex", justifyContent: "center", padding: "8px 0 4px" }}>
        <span style={{ width: 36, height: 4, borderRadius: 999, background: "var(--border-strong)" }} />
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "4px 16px 12px" }}>
        <span style={{ flex: 1, fontSize: "var(--text-h3)", fontWeight: "var(--fw-h3)", color: "var(--text-primary)" }}>{title}</span>
        {onClose && (
          <button type="button" onClick={onClose} aria-label="Fechar" style={{ background: "none", border: "none", padding: 8, cursor: "pointer", color: "var(--text-muted)", lineHeight: 0 }}>
            <Icon name="x" size={20} />
          </button>
        )}
      </div>
      <div style={{ padding: "0 16px", borderTop: "1px solid var(--border)" }}>{children}</div>
      {actions && <div style={{ display: "flex", flexDirection: "column", gap: 8, padding: 16 }}>{actions}</div>}
    </div>
  );
  if (inline) return panel;
  return (
    <div style={{ position: "fixed", inset: 0, display: "flex", alignItems: "flex-end", background: "rgba(19,32,29,.36)", zIndex: 60 }} onClick={onClose}>
      <div style={{ width: "100%" }} onClick={(e) => e.stopPropagation()}>{panel}</div>
    </div>
  );
}

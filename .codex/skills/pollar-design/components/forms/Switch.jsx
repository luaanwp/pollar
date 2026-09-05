import React from "react";

export function Switch({ label, description, checked = false, disabled = false, onChange, style, ...rest }) {
  return (
    <label style={{ display: "inline-flex", alignItems: "center", gap: 12, cursor: disabled ? "not-allowed" : "pointer", opacity: disabled ? 0.5 : 1, ...style }}>
      <input type="checkbox" role="switch" checked={checked} disabled={disabled} onChange={onChange} style={{ position: "absolute", opacity: 0, width: 1, height: 1 }} {...rest} />
      <span
        aria-hidden="true"
        style={{
          position: "relative", width: 40, height: 24, flex: "none",
          borderRadius: "var(--radius-pill)",
          background: checked ? "var(--primary)" : "var(--color-neutral-300)",
          transition: "background var(--duration-standard) var(--ease-standard)",
        }}
      >
        <span style={{
          position: "absolute", top: 3, left: checked ? 19 : 3,
          width: 18, height: 18, borderRadius: "var(--radius-pill)", background: "#fff",
          boxShadow: "var(--elevation-1)",
          transition: "left var(--duration-standard) var(--ease-standard)",
        }} />
      </span>
      {(label || description) && (
        <span style={{ display: "flex", flexDirection: "column", gap: 2 }}>
          {label && <span style={{ fontSize: 14, color: "var(--text-primary)" }}>{label}</span>}
          {description && <span style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>{description}</span>}
        </span>
      )}
    </label>
  );
}

import React from "react";
import { Icon } from "../core/Icon.jsx";

export function Checkbox({ label, checked = false, indeterminate = false, disabled = false, onChange, style, ...rest }) {
  const on = checked || indeterminate;
  return (
    <label
      style={{
        display: "inline-flex", alignItems: "center", gap: 8, minHeight: 24,
        cursor: disabled ? "not-allowed" : "pointer", opacity: disabled ? 0.5 : 1,
        fontSize: 14, color: "var(--text-primary)", ...style,
      }}
    >
      <input type="checkbox" checked={checked} disabled={disabled} onChange={onChange} style={{ position: "absolute", opacity: 0, width: 1, height: 1 }} {...rest} />
      <span
        aria-hidden="true"
        style={{
          display: "inline-flex", alignItems: "center", justifyContent: "center",
          width: 18, height: 18, flex: "none",
          borderRadius: "var(--radius-sm)",
          border: "1px solid " + (on ? "var(--primary)" : "var(--border-strong)"),
          background: on ? "var(--primary)" : "var(--surface-canvas)",
          transition: "background var(--duration-fast) var(--ease-standard)",
        }}
      >
        {on && <Icon name={indeterminate ? "minus" : "check"} size={14} color="var(--on-primary)" />}
      </span>
      {label && <span>{label}</span>}
    </label>
  );
}

import React from "react";
import { Icon } from "../core/Icon.jsx";

const H = { compact: 32, standard: 40, prominent: 48 };

export function Select({ label, hint, error, options = [], size = "standard", disabled = false, id, style, ...rest }) {
  const [focus, setFocus] = React.useState(false);
  const uid = React.useMemo(() => id || "fin-sel-" + Math.random().toString(36).slice(2, 7), [id]);
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 6, minWidth: 0, ...style }}>
      {label && <label htmlFor={uid} style={{ fontSize: "var(--text-label)", fontWeight: "var(--fw-label)", color: "var(--text-secondary)" }}>{label}</label>}
      <div style={{ position: "relative", display: "flex", alignItems: "center" }}>
        <select
          id={uid}
          disabled={disabled}
          onFocus={() => setFocus(true)}
          onBlur={() => setFocus(false)}
          style={{
            appearance: "none", width: "100%", height: H[size] || 40,
            padding: "0 34px 0 12px",
            fontFamily: "var(--font-sans)", fontSize: 14, color: "var(--text-primary)",
            background: disabled ? "var(--surface-alt)" : "var(--surface-canvas)",
            border: "1px solid " + (error ? "var(--negative)" : focus ? "var(--primary)" : "var(--border)"),
            borderRadius: "var(--radius-md)",
            outline: focus ? "2px solid var(--focus-ring)" : "none", outlineOffset: 2,
            opacity: disabled ? 0.6 : 1, cursor: disabled ? "not-allowed" : "pointer",
          }}
          {...rest}
        >
          {options.map((o) => {
            const v = typeof o === "string" ? o : o.value;
            const l = typeof o === "string" ? o : o.label;
            return <option key={v} value={v}>{l}</option>;
          })}
        </select>
        <Icon name="chevron-down" size={16} color="var(--text-muted)" style={{ position: "absolute", right: 10, pointerEvents: "none" }} />
      </div>
      {(error || hint) && <span style={{ fontSize: "var(--text-caption)", color: error ? "var(--negative)" : "var(--text-muted)" }}>{error || hint}</span>}
    </div>
  );
}

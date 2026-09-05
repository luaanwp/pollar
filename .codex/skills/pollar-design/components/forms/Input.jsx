import React from "react";
import { Icon } from "../core/Icon.jsx";

const H = { compact: 32, standard: 40, prominent: 48 };

export function Input({
  label, hint, error, success, prefix, suffix, iconLeft,
  size = "standard", readOnly = false, disabled = false,
  align = "left", id, style, ...rest
}) {
  const [focus, setFocus] = React.useState(false);
  const [hover, setHover] = React.useState(false);
  const uid = React.useMemo(() => id || "fin-in-" + Math.random().toString(36).slice(2, 7), [id]);
  const state = error ? "error" : success ? "success" : "default";
  const borderColor = state === "error" ? "var(--negative)"
    : state === "success" ? "var(--positive)"
    : focus ? "var(--primary)"
    : hover && !disabled ? "var(--border-strong)" : "var(--border)";
  const msg = error || success || hint;
  const msgColor = error ? "var(--negative)" : success ? "var(--positive)" : "var(--text-muted)";
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 6, minWidth: 0, ...style }}>
      {label && (
        <label htmlFor={uid} style={{ fontSize: "var(--text-label)", fontWeight: "var(--fw-label)", lineHeight: "var(--lh-label)", color: "var(--text-secondary)" }}>
          {label}
        </label>
      )}
      <div
        onMouseEnter={() => setHover(true)}
        onMouseLeave={() => setHover(false)}
        style={{
          display: "flex", alignItems: "center", gap: 8,
          height: H[size] || 40, padding: "0 12px",
          background: disabled ? "var(--surface-alt)" : readOnly ? "var(--surface-alt)" : "var(--surface-canvas)",
          border: "1px solid " + borderColor,
          borderRadius: "var(--radius-md)",
          outline: focus ? "2px solid var(--focus-ring)" : "none",
          outlineOffset: 2,
          transition: "border-color var(--duration-fast) var(--ease-standard)",
          opacity: disabled ? 0.6 : 1,
        }}
      >
        {iconLeft && <Icon name={iconLeft} size={16} color="var(--text-muted)" />}
        {prefix && <span className="fin-tnum" style={{ fontSize: 14, color: "var(--text-muted)" }}>{prefix}</span>}
        <input
          id={uid}
          readOnly={readOnly}
          disabled={disabled}
          style={{
            flex: 1, minWidth: 0, border: "none", outline: "none", background: "transparent",
            fontFamily: "var(--font-sans)", fontSize: 14, color: "var(--text-primary)",
            textAlign: align,
            fontVariantNumeric: align === "right" ? "tabular-nums" : undefined,
          }}
          {...rest}
        />
        {suffix && <span className="fin-tnum" style={{ fontSize: 14, color: "var(--text-muted)" }}>{suffix}</span>}
        {state === "error" && <Icon name="circle-alert" size={16} color="var(--negative)" />}
        {state === "success" && <Icon name="circle-check" size={16} color="var(--positive)" />}
      </div>
      {msg && <span style={{ fontSize: "var(--text-caption)", lineHeight: "var(--lh-caption)", color: msgColor }}>{msg}</span>}
    </div>
  );
}

import React from "react";
import { Icon } from "./Icon.jsx";

const BOX = { compact: 32, standard: 40, prominent: 48 };

export function IconButton({ icon, label, size = "standard", variant = "ghost", selected = false, disabled = false, style, ...rest }) {
  const [hover, setHover] = React.useState(false);
  const box = BOX[size] || 40;
  const bg = selected ? "var(--primary-soft)" : hover && !disabled ? "var(--surface-alt)" : variant === "outline" ? "var(--surface-canvas)" : "transparent";
  return (
    <button
      type="button"
      title={label}
      aria-label={label}
      aria-pressed={selected || undefined}
      disabled={disabled}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        width: box,
        height: box,
        minWidth: box,
        borderRadius: "var(--radius-md)",
        border: variant === "outline" ? "1px solid var(--border-strong)" : "1px solid transparent",
        background: bg,
        color: selected ? "var(--primary)" : "var(--text-secondary)",
        cursor: disabled ? "not-allowed" : "pointer",
        opacity: disabled ? 0.5 : 1,
        transition: "background var(--duration-fast) var(--ease-standard)",
        ...style,
      }}
      {...rest}
    >
      <Icon name={icon} size={size === "compact" ? 16 : 20} />
    </button>
  );
}

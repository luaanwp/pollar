import React from "react";
import { Icon } from "./Icon.jsx";

const HEIGHTS = { compact: 32, standard: 40, prominent: 48 };
const PAD = { compact: "0 10px", standard: "0 14px", prominent: "0 18px" };
const FONT = { compact: 13, standard: 14, prominent: 16 };

function skin(variant) {
  switch (variant) {
    case "secondary":
      return { background: "var(--surface-canvas)", color: "var(--text-primary)", border: "1px solid var(--border-strong)" };
    case "ghost":
      return { background: "transparent", color: "var(--text-secondary)", border: "1px solid transparent" };
    case "danger":
      return { background: "var(--negative)", color: "#fff", border: "1px solid var(--negative)" };
    default:
      return { background: "var(--primary)", color: "var(--on-primary)", border: "1px solid var(--primary)" };
  }
}

export function Button({
  variant = "primary",
  size = "standard",
  iconLeft,
  iconRight,
  loading = false,
  disabled = false,
  fullWidth = false,
  children,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  const [active, setActive] = React.useState(false);
  const s = skin(variant);
  const off = disabled || loading;
  let bg = s.background, bd = s.border, fg = s.color;
  if (hover && !off) {
    if (variant === "primary") { bg = "var(--primary-hover)"; bd = "1px solid var(--primary-hover)"; }
    else if (variant === "danger") { bg = "#AE3131"; bd = "1px solid #AE3131"; }
    else { bg = "var(--surface-alt)"; fg = "var(--text-primary)"; }
  }
  const iconSize = size === "compact" ? 16 : 20;
  return (
    <button
      type="button"
      disabled={off}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => { setHover(false); setActive(false); }}
      onMouseDown={() => setActive(true)}
      onMouseUp={() => setActive(false)}
      style={{
        display: fullWidth ? "flex" : "inline-flex",
        width: fullWidth ? "100%" : undefined,
        alignItems: "center",
        justifyContent: "center",
        gap: 8,
        height: HEIGHTS[size] || HEIGHTS.standard,
        padding: PAD[size] || PAD.standard,
        minWidth: 0,
        font: "inherit",
        fontFamily: "var(--font-sans)",
        fontSize: FONT[size] || 14,
        fontWeight: 600,
        lineHeight: 1,
        borderRadius: "var(--radius-md)",
        background: bg,
        color: fg,
        border: bd,
        cursor: off ? "not-allowed" : "pointer",
        opacity: off ? 0.5 : 1,
        transform: active && !off ? "translateY(0.5px)" : "none",
        transition: "background var(--duration-fast) var(--ease-standard),color var(--duration-fast) var(--ease-standard),border-color var(--duration-fast) var(--ease-standard)",
        ...style,
      }}
      {...rest}
    >
      {loading && <Icon name="loader-circle" size={iconSize} style={{ animation: "fin-spin 900ms linear infinite" }} />}
      {!loading && iconLeft && <Icon name={iconLeft} size={iconSize} />}
      <span style={{ whiteSpace: "nowrap" }}>{children}</span>
      {iconRight && <Icon name={iconRight} size={iconSize} />}
    </button>
  );
}

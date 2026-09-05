import React from "react";

const PADS = { none: 0, sm: 12, md: 16, lg: 20 };

export function Card({ padding = "lg", interactive = false, tone = "canvas", children, style, ...rest }) {
  const [hover, setHover] = React.useState(false);
  return (
    <div
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{
        background: tone === "alt" ? "var(--surface-alt)" : "var(--surface-canvas)",
        border: "1px solid var(--border)",
        borderRadius: "var(--radius-lg)",
        padding: PADS[padding] ?? 20,
        boxShadow: interactive && hover ? "var(--elevation-1)" : "none",
        borderColor: interactive && hover ? "var(--border-strong)" : "var(--border)",
        transition: "box-shadow var(--duration-standard) var(--ease-standard),border-color var(--duration-standard) var(--ease-standard)",
        minWidth: 0,
        ...style,
      }}
      {...rest}
    >
      {children}
    </div>
  );
}

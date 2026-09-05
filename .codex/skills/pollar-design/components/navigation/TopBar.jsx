import React from "react";
import { Icon } from "../core/Icon.jsx";

export function TopBar({ title, subtitle, breadcrumb, search = true, searchPlaceholder = "Buscar transações, contas, categorias", actions, style, ...rest }) {
  const [focus, setFocus] = React.useState(false);
  return (
    <header
      style={{
        display: "flex", alignItems: "center", gap: 16,
        height: 60, padding: "0 var(--gutter-desktop)", flex: "none",
        background: "var(--surface-canvas)", borderBottom: "1px solid var(--border)",
        ...style,
      }}
      {...rest}
    >
      <div style={{ minWidth: 0, display: "flex", flexDirection: "column", gap: 1 }}>
        {breadcrumb && <span style={{ fontSize: 11, color: "var(--text-muted)" }}>{breadcrumb}</span>}
        {title && <span style={{ fontSize: 16, fontWeight: 650, color: "var(--text-primary)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{title}</span>}
        {subtitle && <span style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>{subtitle}</span>}
      </div>
      <span style={{ flex: 1 }} />
      {search && (
        <label style={{
          display: "flex", alignItems: "center", gap: 8,
          height: 34, width: 300, padding: "0 10px",
          background: "var(--surface-alt)",
          border: "1px solid " + (focus ? "var(--primary)" : "transparent"),
          borderRadius: "var(--radius-md)",
        }}>
          <Icon name="search" size={16} color="var(--text-muted)" />
          <input
            placeholder={searchPlaceholder}
            onFocus={() => setFocus(true)}
            onBlur={() => setFocus(false)}
            style={{ flex: 1, minWidth: 0, border: "none", background: "transparent", outline: "none", fontFamily: "var(--font-sans)", fontSize: 13, color: "var(--text-primary)" }}
          />
          <span className="fin-tnum" style={{ fontSize: 11, color: "var(--text-muted)", border: "1px solid var(--border)", borderRadius: 4, padding: "0 4px" }}>⌘K</span>
        </label>
      )}
      {actions}
    </header>
  );
}

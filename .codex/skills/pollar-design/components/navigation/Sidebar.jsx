import React from "react";
import { Icon } from "../core/Icon.jsx";

export function Sidebar({ items = [], activeId, onSelect, collapsed = false, brand = "Pollar", footer, style, ...rest }) {
  return (
    <nav
      aria-label="Navegação principal"
      style={{
        width: collapsed ? "var(--size-sidebar-collapsed)" : "var(--size-sidebar-expanded)",
        flex: "none",
        display: "flex", flexDirection: "column",
        background: "var(--surface-canvas)",
        borderRight: "1px solid var(--border)",
        transition: "width var(--duration-panel) var(--ease-standard)",
        overflow: "hidden",
        ...style,
      }}
      {...rest}
    >
      <div style={{ display: "flex", alignItems: "center", gap: 10, height: 60, padding: collapsed ? "0 0 0 24px" : "0 16px", flex: "none" }}>
        <span style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 24, height: 24, flex: "none", borderRadius: 7, background: "var(--primary)", color: "var(--on-primary)" }}>
          <Icon name="chart-no-axes-column-increasing" size={15} />
        </span>
        {!collapsed && <span style={{ fontSize: 16, fontWeight: 650, letterSpacing: "-0.01em", color: "var(--text-primary)" }}>{brand}</span>}
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 2, padding: collapsed ? "4px 12px" : "4px 8px", flex: 1, overflowY: "auto" }}>
        {items.map((it) =>
          it.section ? (
            !collapsed && <div key={it.section} style={{ padding: "16px 8px 6px", fontSize: 11, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase", color: "var(--text-muted)" }}>{it.section}</div>
          ) : (
            <SideItem key={it.id} item={it} active={activeId === it.id} collapsed={collapsed} onSelect={onSelect} />
          )
        )}
      </div>
      {footer && <div style={{ padding: collapsed ? 12 : 12, borderTop: "1px solid var(--border)", flex: "none" }}>{footer}</div>}
    </nav>
  );
}

function SideItem({ item, active, collapsed, onSelect }) {
  const [hover, setHover] = React.useState(false);
  return (
    <button
      type="button"
      title={collapsed ? item.label : undefined}
      aria-current={active ? "page" : undefined}
      onClick={() => onSelect && onSelect(item.id)}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{
        display: "flex", alignItems: "center", gap: 10,
        width: "100%", height: 38, padding: collapsed ? 0 : "0 10px",
        justifyContent: collapsed ? "center" : "flex-start",
        border: "none", borderRadius: "var(--radius-md)",
        background: active ? "var(--primary-soft)" : hover ? "var(--surface-alt)" : "transparent",
        color: active ? "var(--primary)" : "var(--text-secondary)",
        font: "inherit", fontSize: 14, fontWeight: active ? 600 : 450,
        cursor: "pointer", textAlign: "left",
        transition: "background var(--duration-fast) var(--ease-standard)",
      }}
    >
      <Icon name={item.icon} size={20} />
      {!collapsed && <span style={{ flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{item.label}</span>}
      {!collapsed && item.badge && (
        <span className="fin-tnum" style={{ fontSize: 11, fontWeight: 600, color: "var(--text-muted)", background: "var(--surface-alt)", borderRadius: 999, padding: "1px 7px" }}>{item.badge}</span>
      )}
    </button>
  );
}

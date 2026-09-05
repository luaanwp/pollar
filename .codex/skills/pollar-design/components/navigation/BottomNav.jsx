import React from "react";
import { Icon } from "../core/Icon.jsx";

export function BottomNav({ items = [], activeId, onSelect, quickAdd, onQuickAdd, style, ...rest }) {
  const list = items.slice(0, 5);
  return (
    <nav
      aria-label="Navegação"
      style={{
        position: "relative",
        display: "flex", alignItems: "stretch",
        height: 64, flex: "none",
        background: "var(--surface-canvas)",
        borderTop: "1px solid var(--border)",
        paddingBottom: 0,
        ...style,
      }}
      {...rest}
    >
      {list.map((it) => {
        const active = activeId === it.id;
        return (
          <button
            key={it.id}
            type="button"
            aria-current={active ? "page" : undefined}
            onClick={() => onSelect && onSelect(it.id)}
            style={{
              flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 4,
              minWidth: 44, minHeight: 44,
              background: "none", border: "none", padding: 0, cursor: "pointer",
              color: active ? "var(--primary)" : "var(--text-muted)",
              font: "inherit",
            }}
          >
            <Icon name={it.icon} size={24} />
            <span style={{ fontSize: 11, fontWeight: active ? 600 : 500 }}>{it.label}</span>
          </button>
        );
      })}
      {quickAdd && (
        <button
          type="button"
          aria-label={typeof quickAdd === "string" ? quickAdd : "Adicionar"}
          onClick={onQuickAdd}
          style={{
            position: "absolute", right: 16, top: -28,
            width: 56, height: 56, borderRadius: "var(--radius-pill)",
            display: "flex", alignItems: "center", justifyContent: "center",
            background: "var(--primary)", color: "var(--on-primary)",
            border: "3px solid var(--surface-background)",
            boxShadow: "var(--elevation-2)", cursor: "pointer",
          }}
        >
          <Icon name="plus" size={24} />
        </button>
      )}
    </nav>
  );
}

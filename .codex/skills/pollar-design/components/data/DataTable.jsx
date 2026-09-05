import React from "react";
import { Icon } from "../core/Icon.jsx";
import { Checkbox } from "../forms/Checkbox.jsx";

export function DataTable({
  columns = [], rows = [], selectable = false, selectedIds = [], onToggleRow, onToggleAll,
  sortKey, sortDir = "asc", onSort, onRowClick, activeId, stickyHeader = true, emptyLabel = "Nenhum registro encontrado", style, ...rest
}) {
  const allSelected = rows.length > 0 && selectedIds.length === rows.length;
  const someSelected = selectedIds.length > 0 && !allSelected;
  const gridCols = (selectable ? "40px " : "") + columns.map(c => c.width || "1fr").join(" ");
  return (
    <div
      style={{
        border: "1px solid var(--border)", borderRadius: "var(--radius-md)",
        background: "var(--surface-canvas)", overflow: "hidden", ...style,
      }}
      {...rest}
    >
      <div style={{
        display: "grid", gridTemplateColumns: gridCols, alignItems: "center",
        gap: 12, padding: "0 16px", height: 44,
        background: "var(--surface-alt)", borderBottom: "1px solid var(--border)",
        position: stickyHeader ? "sticky" : "static", top: 0, zIndex: 1,
      }}>
        {selectable && <Checkbox checked={allSelected} indeterminate={someSelected} onChange={onToggleAll} aria-label="Selecionar todos" />}
        {columns.map((c) => {
          const active = sortKey === c.key;
          return (
            <button
              key={c.key}
              type="button"
              onClick={c.sortable === false || !onSort ? undefined : () => onSort(c.key)}
              style={{
                display: "flex", alignItems: "center", gap: 4,
                justifyContent: c.align === "right" ? "flex-end" : "flex-start",
                background: "none", border: "none", padding: 0,
                font: "inherit", fontSize: 11, fontWeight: 600, letterSpacing: "0.06em",
                textTransform: "uppercase", color: active ? "var(--text-primary)" : "var(--text-muted)",
                cursor: c.sortable === false || !onSort ? "default" : "pointer",
              }}
            >
              {c.label}
              {active && <Icon name={sortDir === "asc" ? "arrow-up" : "arrow-down"} size={12} />}
            </button>
          );
        })}
      </div>
      {rows.length === 0 && (
        <div style={{ padding: "32px 16px", textAlign: "center", fontSize: 14, color: "var(--text-muted)" }}>{emptyLabel}</div>
      )}
      {rows.map((r) => {
        const sel = selectedIds.includes(r.id);
        return (
          <Row
            key={r.id}
            row={r}
            columns={columns}
            gridCols={gridCols}
            selectable={selectable}
            selected={sel}
            active={activeId === r.id}
            onToggleRow={onToggleRow}
            onRowClick={onRowClick}
          />
        );
      })}
    </div>
  );
}

function Row({ row, columns, gridCols, selectable, selected, active, onToggleRow, onRowClick }) {
  const [hover, setHover] = React.useState(false);
  return (
    <div
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      onClick={onRowClick ? () => onRowClick(row) : undefined}
      tabIndex={onRowClick ? 0 : undefined}
      style={{
        display: "grid", gridTemplateColumns: gridCols, alignItems: "center",
        gap: 12, padding: "0 16px", minHeight: 48,
        borderBottom: "1px solid var(--border)",
        background: active || selected ? "var(--primary-soft)" : hover ? "var(--surface-alt)" : "transparent",
        cursor: onRowClick ? "pointer" : "default",
        transition: "background var(--duration-fast) var(--ease-standard)",
      }}
    >
      {selectable && <Checkbox checked={selected} onChange={() => onToggleRow && onToggleRow(row.id)} aria-label={"Selecionar " + (row.id)} />}
      {columns.map((c) => (
        <div
          key={c.key}
          className={c.align === "right" ? "fin-tnum" : undefined}
          style={{
            fontSize: 14, color: "var(--text-primary)", minWidth: 0,
            display: "flex", alignItems: "center", gap: 8,
            justifyContent: c.align === "right" ? "flex-end" : "flex-start",
            overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap",
          }}
        >
          {c.render ? c.render(row) : row[c.key]}
        </div>
      ))}
    </div>
  );
}

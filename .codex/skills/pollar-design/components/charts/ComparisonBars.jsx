import React from "react";
import { formatMoney } from "../data/money.js";

/* Grouped bars: income vs. expenses, or budget vs. actual. Zero baseline mandatory. */
export function ComparisonBars({ groups = [], series = [], height = 160, valueFormatter, showLegend = true, style, ...rest }) {
  const fmt = valueFormatter || (v => formatMoney(v));
  const max = Math.max(1, ...groups.flatMap(g => g.values.map(v => Math.abs(v))));
  return (
    <figure style={{ margin: 0, display: "flex", flexDirection: "column", gap: 12, minWidth: 0, ...style }} {...rest}>
      {showLegend && (
        <div style={{ display: "flex", gap: 16, flexWrap: "wrap" }}>
          {series.map((s, i) => (
            <span key={i} style={{ display: "inline-flex", alignItems: "center", gap: 6, fontSize: "var(--text-caption)", color: "var(--text-secondary)" }}>
              <span style={{ width: 10, height: 10, borderRadius: 3, background: s.color, flex: "none" }} />
              {s.label}
            </span>
          ))}
        </div>
      )}
      <div style={{ display: "flex", alignItems: "flex-end", gap: 16, height, borderBottom: "1px solid var(--border-strong)", paddingBottom: 0 }}
        role="img" aria-label={groups.map(g => `${g.label}: ${g.values.map((v, i) => `${series[i] ? series[i].label : ""} ${fmt(v)}`).join(", ")}`).join("; ")}>
        {groups.map((g, gi) => (
          <div key={gi} style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "flex-end", alignItems: "center", gap: 6, height: "100%" }}>
            <div style={{ display: "flex", alignItems: "flex-end", gap: 4, height: "100%", width: "100%", justifyContent: "center" }}>
              {g.values.map((v, i) => (
                <div key={i} title={`${g.label} · ${series[i] ? series[i].label : ""} · ${fmt(v)}`}
                  style={{
                    width: 18, height: Math.max(2, (Math.abs(v) / max) * 100) + "%",
                    background: series[i] ? series[i].color : "var(--chart-1)",
                    borderRadius: "var(--radius-sm) var(--radius-sm) 0 0",
                    transition: "height var(--duration-panel) var(--ease-decelerate)",
                  }} />
              ))}
            </div>
          </div>
        ))}
      </div>
      <div style={{ display: "flex", gap: 16 }}>
        {groups.map((g, gi) => (
          <span key={gi} style={{ flex: 1, textAlign: "center", fontSize: 11, color: "var(--text-muted)" }}>{g.label}</span>
        ))}
      </div>
    </figure>
  );
}

import React from "react";
import { formatMoney } from "../data/money.js";

/* Donut for category composition — only with few categories; otherwise use sorted bars. */
export function CategoryDonut({ slices = [], size = 132, thickness = 16, centerLabel, centerValue, valueFormatter, style, ...rest }) {
  const fmt = valueFormatter || (v => formatMoney(v));
  const total = slices.reduce((a, s) => a + Math.abs(s.value), 0) || 1;
  const r = (size - thickness) / 2;
  const c = 2 * Math.PI * r;
  let offset = 0;
  return (
    <figure style={{ margin: 0, display: "flex", alignItems: "center", gap: 20, minWidth: 0, flexWrap: "wrap", ...style }} {...rest}>
      <div style={{ position: "relative", width: size, height: size, flex: "none" }}>
        <svg width={size} height={size} role="img" aria-label={slices.map(s => `${s.label}: ${fmt(s.value)}`).join("; ")} style={{ transform: "rotate(-90deg)" }}>
          <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="var(--surface-alt)" strokeWidth={thickness} />
          {slices.map((s, i) => {
            const len = (Math.abs(s.value) / total) * c;
            const el = (
              <circle key={i} cx={size / 2} cy={size / 2} r={r} fill="none"
                stroke={s.color || `var(--chart-${(i % 8) + 1})`}
                strokeWidth={thickness} strokeDasharray={`${len} ${c - len}`} strokeDashoffset={-offset} />
            );
            offset += len;
            return el;
          })}
        </svg>
        {(centerLabel || centerValue) && (
          <div style={{ position: "absolute", inset: 0, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 2 }}>
            {centerLabel && <span style={{ fontSize: 11, color: "var(--text-muted)" }}>{centerLabel}</span>}
            {centerValue && <span className="fin-tnum" style={{ fontSize: 15, fontWeight: 600, color: "var(--text-primary)" }}>{centerValue}</span>}
          </div>
        )}
      </div>
      <table style={{ borderCollapse: "collapse", fontSize: 13, minWidth: 200, flex: 1 }}>
        <tbody>
          {slices.map((s, i) => (
            <tr key={i}>
              <td style={{ padding: "3px 8px 3px 0", width: 14 }}>
                <span style={{ display: "block", width: 10, height: 10, borderRadius: 3, background: s.color || `var(--chart-${(i % 8) + 1})` }} />
              </td>
              <td style={{ padding: "3px 12px 3px 0", color: "var(--text-secondary)" }}>{s.label}</td>
              <td className="fin-tnum" style={{ padding: "3px 12px 3px 0", textAlign: "right", color: "var(--text-primary)", fontWeight: 600 }}>{fmt(s.value)}</td>
              <td className="fin-tnum" style={{ padding: "3px 0", textAlign: "right", color: "var(--text-muted)" }}>{Math.round((Math.abs(s.value) / total) * 100)}%</td>
            </tr>
          ))}
        </tbody>
      </table>
    </figure>
  );
}

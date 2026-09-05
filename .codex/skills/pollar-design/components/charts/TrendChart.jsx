import React from "react";
import { formatMoney } from "../data/money.js";

/* Line/area chart for cash flow or balance over time. Zero baseline included. */
export function TrendChart({ data = [], height = 140, tone = "var(--chart-1)", showArea = true, valueFormatter, style, ...rest }) {
  const vals = data.map(d => d.value);
  const max = Math.max(0, ...vals);
  const min = Math.min(0, ...vals);
  const span = max - min || 1;
  const W = 100, H = 100;
  const pts = data.map((d, i) => {
    const x = data.length === 1 ? 0 : (i / (data.length - 1)) * W;
    const y = H - ((d.value - min) / span) * H;
    return [x, y];
  });
  const line = pts.map((p, i) => (i ? "L" : "M") + p[0].toFixed(2) + " " + p[1].toFixed(2)).join(" ");
  const zeroY = H - ((0 - min) / span) * H;
  const area = pts.length ? line + ` L${W} ${zeroY} L0 ${zeroY} Z` : "";
  const fmt = valueFormatter || (v => formatMoney(v));
  const last = data[data.length - 1];
  return (
    <figure style={{ margin: 0, display: "flex", flexDirection: "column", gap: 8, minWidth: 0, ...style }} {...rest}>
      <svg viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none" role="img"
        aria-label={data.map(d => `${d.label}: ${fmt(d.value)}`).join("; ")}
        style={{ width: "100%", height, display: "block", overflow: "visible" }}>
        <line x1="0" y1={zeroY} x2={W} y2={zeroY} stroke="var(--border)" strokeWidth="0.6" vectorEffect="non-scaling-stroke" />
        {showArea && <path d={area} fill={tone} opacity="0.10" />}
        <path d={line} fill="none" stroke={tone} strokeWidth="2" vectorEffect="non-scaling-stroke" strokeLinejoin="round" strokeLinecap="round" />
        {pts.length > 0 && <circle cx={pts[pts.length - 1][0]} cy={pts[pts.length - 1][1]} r="3" fill={tone} vectorEffect="non-scaling-stroke" />}
      </svg>
      <div style={{ display: "flex", justifyContent: "space-between", gap: 8 }}>
        {data.map((d, i) => (
          <span key={i} style={{ fontSize: 11, color: "var(--text-muted)" }}>{d.label}</span>
        ))}
      </div>
      {last && (
        <figcaption className="fin-tnum" style={{ fontSize: "var(--text-caption)", color: "var(--text-secondary)" }}>
          Último ponto — {last.label}: {fmt(last.value)}
        </figcaption>
      )}
    </figure>
  );
}

import React from "react";

const TONES = { primary: "var(--primary)", success: "var(--positive)", warning: "var(--warning)", danger: "var(--negative)", info: "var(--info)" };

export function ProgressMeter({ value = 0, label, valueLabel, tone = "primary", height = 8, style, ...rest }) {
  const pct = Math.max(0, Math.min(100, value));
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 6, minWidth: 0, ...style }} {...rest}>
      {(label || valueLabel) && (
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          {label && <span style={{ fontSize: "var(--text-caption)", color: "var(--text-secondary)", flex: 1 }}>{label}</span>}
          {valueLabel && <span className="fin-tnum" style={{ fontSize: "var(--text-caption)", fontWeight: 600, color: "var(--text-primary)" }}>{valueLabel}</span>}
        </div>
      )}
      <div
        role="progressbar"
        aria-valuenow={pct}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-label={label}
        style={{ height, borderRadius: "var(--radius-pill)", background: "var(--surface-alt)", border: "1px solid var(--border)", overflow: "hidden" }}
      >
        <div style={{ width: pct + "%", height: "100%", background: TONES[tone] || TONES.primary, transition: "width var(--duration-panel) var(--ease-decelerate)" }} />
      </div>
    </div>
  );
}

import React from "react";
import { Icon } from "../core/Icon.jsx";
import { MoneyText } from "../data/MoneyText.jsx";
import { ProgressMeter } from "../charts/ProgressMeter.jsx";

export function BudgetProgress({ category, icon = "circle", spentMinor = 0, limitMinor = 1, style, ...rest }) {
  const pct = Math.min(999, Math.round((Math.abs(spentMinor) / Math.max(1, limitMinor)) * 100));
  const tone = pct >= 100 ? "danger" : pct >= 85 ? "warning" : "primary";
  const remaining = limitMinor - Math.abs(spentMinor);
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 8, minWidth: 0, ...style }} {...rest}>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        <Icon name={icon} size={16} color="var(--text-secondary)" />
        <span style={{ fontSize: 14, fontWeight: 550, color: "var(--text-primary)", flex: 1, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{category}</span>
        <span className="fin-tnum" style={{ fontSize: 13, color: "var(--text-secondary)" }}>
          <MoneyText minor={-Math.abs(spentMinor)} size="compact" style={{ fontWeight: 600 }} />
          <span style={{ color: "var(--text-muted)", fontWeight: 400 }}> de </span>
          <MoneyText minor={limitMinor} size="compact" style={{ fontWeight: 400, color: "var(--text-muted)" }} />
        </span>
      </div>
      <ProgressMeter value={pct} tone={tone} />
      <div style={{ display: "flex", alignItems: "center", gap: 6, fontSize: "var(--text-caption)", color: tone === "primary" ? "var(--text-muted)" : tone === "warning" ? "var(--warning)" : "var(--negative)" }}>
        {tone !== "primary" && <Icon name={tone === "danger" ? "circle-alert" : "triangle-alert"} size={12} />}
        <span className="fin-tnum">{pct}% usado</span>
        <span>·</span>
        <span>{remaining >= 0 ? "Restam " : "Excedido em "}<MoneyText minor={Math.abs(remaining)} size="compact" style={{ fontSize: "var(--text-caption)", fontWeight: 600, color: "inherit" }} /></span>
      </div>
    </div>
  );
}

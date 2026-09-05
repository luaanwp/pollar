import React from "react";
import { Card } from "./Card.jsx";
import { Icon } from "../core/Icon.jsx";
import { PrivacyAmount } from "../data/PrivacyAmount.jsx";
import { MoneyText } from "../data/MoneyText.jsx";

export function MetricCard({
  title, helper, action, minor, size = "hero", comparisonMinor, comparisonLabel,
  privacyHidden = false, children, style, ...rest
}) {
  const up = (comparisonMinor || 0) >= 0;
  return (
    <Card style={{ display: "flex", flexDirection: "column", gap: 12, ...style }} {...rest}>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        <span style={{ fontSize: "var(--text-label)", fontWeight: "var(--fw-label)", color: "var(--text-secondary)", flex: 1 }}>{title}</span>
        {helper && <span style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>{helper}</span>}
        {action}
      </div>
      <PrivacyAmount minor={minor} hidden={privacyHidden} size={size} />
      {comparisonMinor !== undefined && (
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <Icon name={up ? "trending-up" : "trending-down"} size={16} color={up ? "var(--positive)" : "var(--negative)"} />
          <MoneyText minor={comparisonMinor} size="compact" tone="semantic" showSign />
          {comparisonLabel && <span style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>{comparisonLabel}</span>}
        </div>
      )}
      {children}
    </Card>
  );
}

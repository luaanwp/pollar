import React from "react";
import { Card } from "./Card.jsx";
import { Icon } from "../core/Icon.jsx";
import { MoneyText } from "../data/MoneyText.jsx";
import { StatusBadge } from "../data/StatusBadge.jsx";
import { ProgressMeter } from "../charts/ProgressMeter.jsx";

export function StatementSummary({
  cardName, brand, last4, period, status = "Aberta", statusTone = "neutral", statusIcon = "circle",
  totalMinor = 0, paidMinor = 0, dueDate, limitMinor, actions, style, ...rest
}) {
  const outstanding = totalMinor - paidMinor;
  const utilization = limitMinor ? Math.min(100, Math.round((Math.abs(totalMinor) / limitMinor) * 100)) : null;
  return (
    <Card style={{ display: "flex", flexDirection: "column", gap: 16, ...style }} {...rest}>
      <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
        <span style={{ display: "inline-flex", alignItems: "center", justifyContent: "center", width: 40, height: 40, borderRadius: "var(--radius-md)", background: "var(--primary-soft)", color: "var(--primary)", flex: "none" }}>
          <Icon name="credit-card" size={20} />
        </span>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: "var(--text-h3)", fontWeight: "var(--fw-h3)", color: "var(--text-primary)" }}>{cardName}</div>
          <div className="fin-tnum" style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>
            {[brand, last4 ? "•••• " + last4 : null, period].filter(Boolean).join(" · ")}
          </div>
        </div>
        <StatusBadge tone={statusTone} icon={statusIcon}>{status}</StatusBadge>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(3,minmax(0,1fr))", gap: 12, padding: "12px 0", borderTop: "1px solid var(--border)", borderBottom: "1px solid var(--border)" }}>
        <Field label="Total da fatura"><MoneyText minor={totalMinor} size="standard" /></Field>
        <Field label="Pago"><MoneyText minor={paidMinor} size="standard" tone={paidMinor ? "semantic" : undefined} /></Field>
        <Field label="Em aberto"><MoneyText minor={outstanding} size="standard" /></Field>
      </div>

      <div style={{ display: "flex", alignItems: "center", gap: 12, flexWrap: "wrap" }}>
        {dueDate && (
          <span style={{ display: "inline-flex", alignItems: "center", gap: 6, fontSize: 13, color: "var(--text-secondary)" }}>
            <Icon name="calendar-clock" size={16} color="var(--text-muted)" />
            Vence em <strong className="fin-tnum" style={{ fontWeight: 600, color: "var(--text-primary)" }}>{dueDate}</strong>
          </span>
        )}
        <span style={{ flex: 1 }} />
        {actions}
      </div>

      {utilization !== null && (
        <ProgressMeter label="Limite utilizado" value={utilization} valueLabel={utilization + "%"} tone={utilization > 85 ? "warning" : "primary"} />
      )}
    </Card>
  );
}

function Field({ label, children }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 2, minWidth: 0 }}>
      <span style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>{label}</span>
      {children}
    </div>
  );
}

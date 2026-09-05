import React from "react";
import { Icon } from "../core/Icon.jsx";
import { MoneyText } from "./MoneyText.jsx";
import { PrivacyAmount } from "./PrivacyAmount.jsx";
import { StatusBadge } from "./StatusBadge.jsx";

const KIND = {
  expense: { icon: "arrow-down-left", color: "var(--text-secondary)" },
  income: { icon: "arrow-up-right", color: "var(--positive)" },
  transfer: { icon: "arrow-left-right", color: "var(--info)" },
  cardPayment: { icon: "credit-card", color: "var(--info)" },
};

export function TransactionTile({
  title, category, account, date, minor, kind = "expense",
  installment, status, statusTone = "neutral", statusIcon,
  icon, privacyHidden = false, selected = false, onClick, style, ...rest
}) {
  const [hover, setHover] = React.useState(false);
  const k = KIND[kind] || KIND.expense;
  const meta = [category, account].filter(Boolean).join(" · ");
  return (
    <div
      role={onClick ? "button" : undefined}
      tabIndex={onClick ? 0 : undefined}
      onClick={onClick}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{
        display: "flex", alignItems: "center", gap: 12,
        padding: "12px 16px", minHeight: 64,
        background: selected ? "var(--primary-soft)" : hover && onClick ? "var(--surface-alt)" : "var(--surface-canvas)",
        borderBottom: "1px solid var(--border)",
        cursor: onClick ? "pointer" : "default",
        transition: "background var(--duration-fast) var(--ease-standard)",
        ...style,
      }}
      {...rest}
    >
      <span style={{
        display: "inline-flex", alignItems: "center", justifyContent: "center",
        width: 36, height: 36, flex: "none", borderRadius: "var(--radius-md)",
        background: "var(--surface-alt)", color: k.color,
      }}>
        <Icon name={icon || k.icon} size={18} />
      </span>
      <span style={{ display: "flex", flexDirection: "column", gap: 2, minWidth: 0, flex: 1 }}>
        <span style={{ display: "flex", alignItems: "center", gap: 8, minWidth: 0 }}>
          <span style={{ fontSize: 14, fontWeight: 550, color: "var(--text-primary)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{title}</span>
          {installment && <span className="fin-tnum" style={{ fontSize: 11, fontWeight: 600, color: "var(--text-muted)", background: "var(--surface-alt)", borderRadius: "var(--radius-sm)", padding: "1px 6px", flex: "none" }}>{installment}</span>}
        </span>
        <span style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{meta}</span>
      </span>
      <span style={{ display: "flex", flexDirection: "column", alignItems: "flex-end", gap: 4, flex: "none" }}>
        {privacyHidden
          ? <PrivacyAmount minor={minor} hidden size="standard" maskDigits={5} />
          : <MoneyText minor={minor} size="standard" tone={kind === "income" ? "semantic" : undefined} showSign={kind === "income"} />}
        <span style={{ display: "flex", alignItems: "center", gap: 8 }}>
          {date && <span className="fin-tnum" style={{ fontSize: "var(--text-caption)", color: "var(--text-muted)" }}>{date}</span>}
          {status && <StatusBadge tone={statusTone} icon={statusIcon} size="compact">{status}</StatusBadge>}
        </span>
      </span>
    </div>
  );
}

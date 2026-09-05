import React from "react";
import { MoneyText } from "./MoneyText.jsx";
import { maskMoney } from "./money.js";

export function PrivacyAmount({ minor = 0, hidden = false, size = "standard", currency = "BRL", locale = "pt-BR", maskDigits = 6, style, ...rest }) {
  if (!hidden) return <MoneyText minor={minor} size={size} currency={currency} locale={locale} style={style} {...rest} />;
  const sizeStyle = size === "hero"
    ? { fontSize: "var(--text-amount-hero)", fontWeight: 650, lineHeight: "var(--lh-amount-hero)" }
    : size === "compact" ? { fontSize: 14, fontWeight: 600, lineHeight: 1.3 }
    : { fontSize: "var(--text-amount)", fontWeight: 600, lineHeight: "var(--lh-amount)" };
  return (
    <span
      className="fin-tnum"
      aria-label="valor oculto pelo modo privacidade"
      style={{ color: "var(--text-secondary)", letterSpacing: "0.04em", whiteSpace: "nowrap", ...sizeStyle, ...style }}
      {...rest}
    >
      {maskMoney({ currency, locale, digits: maskDigits })}
    </span>
  );
}

import React from "react";
import { formatMoney } from "./money.js";

const SIZES = {
  hero: { fontSize: "var(--text-amount-hero)", fontWeight: 650, lineHeight: "var(--lh-amount-hero)", letterSpacing: "-0.01em" },
  standard: { fontSize: "var(--text-amount)", fontWeight: 600, lineHeight: "var(--lh-amount)" },
  compact: { fontSize: 14, fontWeight: 600, lineHeight: 1.3 },
};

export function MoneyText({
  minor = 0, size = "standard", polarity = "auto", locale = "pt-BR",
  currency = "BRL", showSign = false, tone, style, ...rest
}) {
  let color = "var(--text-primary)";
  const p = polarity === "auto" ? (minor > 0 ? "positive" : minor < 0 ? "negative" : "neutral") : polarity;
  if (tone === "semantic") color = p === "positive" ? "var(--positive)" : p === "negative" ? "var(--negative)" : "var(--text-primary)";
  if (tone === "muted") color = "var(--text-muted)";
  const text = formatMoney(minor, { locale, currency, sign: showSign ? "always" : "auto" });
  const srPolarity = p === "positive" ? "entrada" : p === "negative" ? "saída" : "";
  return (
    <span
      className="fin-tnum"
      aria-label={`${srPolarity} ${text}`.trim()}
      style={{ color, fontFamily: "var(--font-sans)", whiteSpace: "nowrap", ...SIZES[size], ...style }}
      {...rest}
    >
      {text}
    </span>
  );
}

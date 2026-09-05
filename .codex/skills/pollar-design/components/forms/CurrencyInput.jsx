import React from "react";
import { Input } from "./Input.jsx";

/* Integer minor units beneath the formatting — never a float. */
function formatMinor(minor, locale = "pt-BR", currency = "BRL") {
  const abs = Math.abs(minor);
  const s = new Intl.NumberFormat(locale, { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(abs / 100);
  return (minor < 0 ? "\u2212" : "") + s;
}

export function CurrencyInput({
  label = "Valor", valueMinor = 0, onChangeMinor, currencySymbol = "R$",
  locale = "pt-BR", hint, error, installments, size = "standard", align = "right", ...rest
}) {
  const [text, setText] = React.useState(formatMinor(valueMinor, locale));
  React.useEffect(() => { setText(formatMinor(valueMinor, locale)); }, [valueMinor, locale]);

  function handle(e) {
    const digits = (e.target.value.match(/\d/g) || []).join("");
    const minor = digits ? parseInt(digits, 10) : 0;
    setText(formatMinor(minor, locale));
    if (onChangeMinor) onChangeMinor(minor);
  }
  const preview = installments && installments > 1
    ? `${installments}x de ${currencySymbol} ${formatMinor(Math.round(valueMinor / installments), locale)}`
    : null;

  return (
    <Input
      label={label}
      prefix={currencySymbol}
      value={text}
      onChange={handle}
      inputMode="decimal"
      align={align}
      size={size}
      error={error}
      hint={error ? undefined : preview || hint}
      {...rest}
    />
  );
}

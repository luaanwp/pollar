/* Pollar money formatting — integer minor units only, never floats. */
export function formatMoney(minor, { locale = "pt-BR", currency = "BRL", sign = "auto", symbol = true } = {}) {
  const abs = Math.abs(minor);
  const num = new Intl.NumberFormat(locale, { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(abs / 100);
  const sym = symbol ? (currency === "BRL" ? "R$ " : new Intl.NumberFormat(locale, { style: "currency", currency }).formatToParts(0).filter(p => p.type === "currency").map(p => p.value).join("") + " ") : "";
  let prefix = "";
  if (minor < 0) prefix = "\u2212";
  else if (sign === "always" && minor > 0) prefix = "+";
  return prefix + sym + num;
}

export function maskMoney({ locale = "pt-BR", currency = "BRL", digits = 6 } = {}) {
  const sym = currency === "BRL" ? "R$ " : "";
  return sym + "\u2022".repeat(digits);
}

export function formatDateShort(date, locale = "pt-BR") {
  const d = date instanceof Date ? date : new Date(date);
  return new Intl.DateTimeFormat(locale, { day: "numeric", month: "short", year: "numeric" })
    .format(d).replace(/\./g, "");
}

export function formatInstallment(current, total, style = "compact") {
  return style === "prose" ? `${current} de ${total}` : `${current}/${total}`;
}

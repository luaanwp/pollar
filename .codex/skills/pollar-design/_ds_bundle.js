/* @ds-bundle: {"format":4,"namespace":"PollarDesignSystem_efbbc4","components":[{"name":"CategoryDonut","sourcePath":"components/charts/CategoryDonut.jsx"},{"name":"ComparisonBars","sourcePath":"components/charts/ComparisonBars.jsx"},{"name":"ProgressMeter","sourcePath":"components/charts/ProgressMeter.jsx"},{"name":"TrendChart","sourcePath":"components/charts/TrendChart.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Icon","sourcePath":"components/core/Icon.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"DataTable","sourcePath":"components/data/DataTable.jsx"},{"name":"MoneyText","sourcePath":"components/data/MoneyText.jsx"},{"name":"PrivacyAmount","sourcePath":"components/data/PrivacyAmount.jsx"},{"name":"StatusBadge","sourcePath":"components/data/StatusBadge.jsx"},{"name":"TransactionTile","sourcePath":"components/data/TransactionTile.jsx"},{"name":"Banner","sourcePath":"components/feedback/Banner.jsx"},{"name":"BottomSheet","sourcePath":"components/feedback/BottomSheet.jsx"},{"name":"Dialog","sourcePath":"components/feedback/Dialog.jsx"},{"name":"Toast","sourcePath":"components/feedback/Toast.jsx"},{"name":"Checkbox","sourcePath":"components/forms/Checkbox.jsx"},{"name":"CurrencyInput","sourcePath":"components/forms/CurrencyInput.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"},{"name":"Select","sourcePath":"components/forms/Select.jsx"},{"name":"Switch","sourcePath":"components/forms/Switch.jsx"},{"name":"BottomNav","sourcePath":"components/navigation/BottomNav.jsx"},{"name":"Sidebar","sourcePath":"components/navigation/Sidebar.jsx"},{"name":"TopBar","sourcePath":"components/navigation/TopBar.jsx"},{"name":"BudgetProgress","sourcePath":"components/surfaces/BudgetProgress.jsx"},{"name":"Card","sourcePath":"components/surfaces/Card.jsx"},{"name":"MetricCard","sourcePath":"components/surfaces/MetricCard.jsx"},{"name":"StatementSummary","sourcePath":"components/surfaces/StatementSummary.jsx"}],"sourceHashes":{"components/charts/CategoryDonut.jsx":"1647142e5589","components/charts/ComparisonBars.jsx":"a9e0c7f5d6cc","components/charts/ProgressMeter.jsx":"e22020fdb926","components/charts/TrendChart.jsx":"92498af08fc7","components/core/Button.jsx":"d4ba04fc2841","components/core/Icon.jsx":"883906bc61ed","components/core/IconButton.jsx":"db65ebead875","components/data/DataTable.jsx":"fc250d39e2e9","components/data/MoneyText.jsx":"0540dd50f018","components/data/PrivacyAmount.jsx":"1991d1d08149","components/data/StatusBadge.jsx":"869c28eae790","components/data/TransactionTile.jsx":"f005082417d8","components/data/money.js":"ea7798708566","components/feedback/Banner.jsx":"d0bafae2dde9","components/feedback/BottomSheet.jsx":"84b56b05a248","components/feedback/Dialog.jsx":"478af0fe7d09","components/feedback/Toast.jsx":"35eaeb5e212a","components/forms/Checkbox.jsx":"546acef7820f","components/forms/CurrencyInput.jsx":"f7d48069b332","components/forms/Input.jsx":"bc50e7cee1cf","components/forms/Select.jsx":"8a02100bf54a","components/forms/Switch.jsx":"09bb2e88ad9e","components/navigation/BottomNav.jsx":"cfedc349e983","components/navigation/Sidebar.jsx":"5fecf4eaf212","components/navigation/TopBar.jsx":"e45a985c94b3","components/surfaces/BudgetProgress.jsx":"656363cac6fa","components/surfaces/Card.jsx":"2c234dfdcc68","components/surfaces/MetricCard.jsx":"24e08ba918a0","components/surfaces/StatementSummary.jsx":"a4489b99d46f","ui_kits/desktop/DesktopScreens.jsx":"ad545a310a1d","ui_kits/desktop/data.js":"f164a139eaaa","ui_kits/mobile/MobileScreens.jsx":"4cf73f2b435f"},"inlinedExternals":[],"unexposedExports":[{"name":"formatDateShort","sourcePath":"components/data/money.js"},{"name":"formatInstallment","sourcePath":"components/data/money.js"},{"name":"formatMoney","sourcePath":"components/data/money.js"},{"name":"maskMoney","sourcePath":"components/data/money.js"}]} */

(() => {

const __ds_ns = (window.PollarDesignSystem_efbbc4 = window.PollarDesignSystem_efbbc4 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/charts/ProgressMeter.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const TONES = {
  primary: "var(--primary)",
  success: "var(--positive)",
  warning: "var(--warning)",
  danger: "var(--negative)",
  info: "var(--info)"
};
function ProgressMeter({
  value = 0,
  label,
  valueLabel,
  tone = "primary",
  height = 8,
  style,
  ...rest
}) {
  const pct = Math.max(0, Math.min(100, value));
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6,
      minWidth: 0,
      ...style
    }
  }, rest), (label || valueLabel) && /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8
    }
  }, label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-secondary)",
      flex: 1
    }
  }, label), valueLabel && /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: "var(--text-caption)",
      fontWeight: 600,
      color: "var(--text-primary)"
    }
  }, valueLabel)), /*#__PURE__*/React.createElement("div", {
    role: "progressbar",
    "aria-valuenow": pct,
    "aria-valuemin": 0,
    "aria-valuemax": 100,
    "aria-label": label,
    style: {
      height,
      borderRadius: "var(--radius-pill)",
      background: "var(--surface-alt)",
      border: "1px solid var(--border)",
      overflow: "hidden"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: pct + "%",
      height: "100%",
      background: TONES[tone] || TONES.primary,
      transition: "width var(--duration-panel) var(--ease-decelerate)"
    }
  })));
}
Object.assign(__ds_scope, { ProgressMeter });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/charts/ProgressMeter.jsx", error: String((e && e.message) || e) }); }

// components/core/Icon.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* Lucide (rounded-outline family, per spec §7) delivered from the lucide-static CDN
   and tinted with currentColor via a CSS mask, so a single wrapper covers all glyphs. */
const CDN = "https://unpkg.com/lucide-static@0.462.0/icons/";
function Icon({
  name,
  size = 20,
  strokeWidth,
  color = "currentColor",
  label,
  style,
  ...rest
}) {
  const url = `url("${CDN}${name}.svg")`;
  return /*#__PURE__*/React.createElement("span", _extends({
    role: label ? "img" : "presentation",
    "aria-label": label,
    "aria-hidden": label ? undefined : true,
    title: label,
    style: {
      display: "inline-block",
      flex: "none",
      width: size,
      height: size,
      backgroundColor: color,
      WebkitMaskImage: url,
      maskImage: url,
      WebkitMaskRepeat: "no-repeat",
      maskRepeat: "no-repeat",
      WebkitMaskSize: "contain",
      maskSize: "contain",
      WebkitMaskPosition: "center",
      maskPosition: "center",
      ...style
    }
  }, rest));
}
Object.assign(__ds_scope, { Icon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Icon.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const HEIGHTS = {
  compact: 32,
  standard: 40,
  prominent: 48
};
const PAD = {
  compact: "0 10px",
  standard: "0 14px",
  prominent: "0 18px"
};
const FONT = {
  compact: 13,
  standard: 14,
  prominent: 16
};
function skin(variant) {
  switch (variant) {
    case "secondary":
      return {
        background: "var(--surface-canvas)",
        color: "var(--text-primary)",
        border: "1px solid var(--border-strong)"
      };
    case "ghost":
      return {
        background: "transparent",
        color: "var(--text-secondary)",
        border: "1px solid transparent"
      };
    case "danger":
      return {
        background: "var(--negative)",
        color: "#fff",
        border: "1px solid var(--negative)"
      };
    default:
      return {
        background: "var(--primary)",
        color: "var(--on-primary)",
        border: "1px solid var(--primary)"
      };
  }
}
function Button({
  variant = "primary",
  size = "standard",
  iconLeft,
  iconRight,
  loading = false,
  disabled = false,
  fullWidth = false,
  children,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  const [active, setActive] = React.useState(false);
  const s = skin(variant);
  const off = disabled || loading;
  let bg = s.background,
    bd = s.border,
    fg = s.color;
  if (hover && !off) {
    if (variant === "primary") {
      bg = "var(--primary-hover)";
      bd = "1px solid var(--primary-hover)";
    } else if (variant === "danger") {
      bg = "#AE3131";
      bd = "1px solid #AE3131";
    } else {
      bg = "var(--surface-alt)";
      fg = "var(--text-primary)";
    }
  }
  const iconSize = size === "compact" ? 16 : 20;
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    disabled: off,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => {
      setHover(false);
      setActive(false);
    },
    onMouseDown: () => setActive(true),
    onMouseUp: () => setActive(false),
    style: {
      display: fullWidth ? "flex" : "inline-flex",
      width: fullWidth ? "100%" : undefined,
      alignItems: "center",
      justifyContent: "center",
      gap: 8,
      height: HEIGHTS[size] || HEIGHTS.standard,
      padding: PAD[size] || PAD.standard,
      minWidth: 0,
      font: "inherit",
      fontFamily: "var(--font-sans)",
      fontSize: FONT[size] || 14,
      fontWeight: 600,
      lineHeight: 1,
      borderRadius: "var(--radius-md)",
      background: bg,
      color: fg,
      border: bd,
      cursor: off ? "not-allowed" : "pointer",
      opacity: off ? 0.5 : 1,
      transform: active && !off ? "translateY(0.5px)" : "none",
      transition: "background var(--duration-fast) var(--ease-standard),color var(--duration-fast) var(--ease-standard),border-color var(--duration-fast) var(--ease-standard)",
      ...style
    }
  }, rest), loading && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "loader-circle",
    size: iconSize,
    style: {
      animation: "fin-spin 900ms linear infinite"
    }
  }), !loading && iconLeft && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: iconLeft,
    size: iconSize
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      whiteSpace: "nowrap"
    }
  }, children), iconRight && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: iconRight,
    size: iconSize
  }));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const BOX = {
  compact: 32,
  standard: 40,
  prominent: 48
};
function IconButton({
  icon,
  label,
  size = "standard",
  variant = "ghost",
  selected = false,
  disabled = false,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  const box = BOX[size] || 40;
  const bg = selected ? "var(--primary-soft)" : hover && !disabled ? "var(--surface-alt)" : variant === "outline" ? "var(--surface-canvas)" : "transparent";
  return /*#__PURE__*/React.createElement("button", _extends({
    type: "button",
    title: label,
    "aria-label": label,
    "aria-pressed": selected || undefined,
    disabled: disabled,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      width: box,
      height: box,
      minWidth: box,
      borderRadius: "var(--radius-md)",
      border: variant === "outline" ? "1px solid var(--border-strong)" : "1px solid transparent",
      background: bg,
      color: selected ? "var(--primary)" : "var(--text-secondary)",
      cursor: disabled ? "not-allowed" : "pointer",
      opacity: disabled ? 0.5 : 1,
      transition: "background var(--duration-fast) var(--ease-standard)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size === "compact" ? 16 : 20
  }));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/data/StatusBadge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const TONES = {
  neutral: {
    fg: "var(--text-secondary)",
    bg: "var(--neutral-soft)",
    bd: "var(--border)"
  },
  info: {
    fg: "var(--info)",
    bg: "var(--info-soft)",
    bd: "transparent"
  },
  success: {
    fg: "var(--positive)",
    bg: "var(--positive-soft)",
    bd: "transparent"
  },
  warning: {
    fg: "var(--warning)",
    bg: "var(--warning-soft)",
    bd: "transparent"
  },
  danger: {
    fg: "var(--negative)",
    bg: "var(--negative-soft)",
    bd: "transparent"
  }
};
function StatusBadge({
  tone = "neutral",
  icon,
  children,
  size = "standard",
  style,
  ...rest
}) {
  const t = TONES[tone] || TONES.neutral;
  const compact = size === "compact";
  return /*#__PURE__*/React.createElement("span", _extends({
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 6,
      height: compact ? 20 : 24,
      padding: compact ? "0 8px" : "0 10px",
      borderRadius: "var(--radius-pill)",
      background: t.bg,
      color: t.fg,
      border: "1px solid " + t.bd,
      fontSize: compact ? 11 : "var(--text-caption)",
      fontWeight: 600,
      lineHeight: 1,
      whiteSpace: "nowrap",
      ...style
    }
  }, rest), icon && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: compact ? 12 : 14
  }), children);
}
Object.assign(__ds_scope, { StatusBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/StatusBadge.jsx", error: String((e && e.message) || e) }); }

// components/data/money.js
try { (() => {
/* Pollar money formatting — integer minor units only, never floats. */
function formatMoney(minor, {
  locale = "pt-BR",
  currency = "BRL",
  sign = "auto",
  symbol = true
} = {}) {
  const abs = Math.abs(minor);
  const num = new Intl.NumberFormat(locale, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(abs / 100);
  const sym = symbol ? currency === "BRL" ? "R$ " : new Intl.NumberFormat(locale, {
    style: "currency",
    currency
  }).formatToParts(0).filter(p => p.type === "currency").map(p => p.value).join("") + " " : "";
  let prefix = "";
  if (minor < 0) prefix = "\u2212";else if (sign === "always" && minor > 0) prefix = "+";
  return prefix + sym + num;
}
function maskMoney({
  locale = "pt-BR",
  currency = "BRL",
  digits = 6
} = {}) {
  const sym = currency === "BRL" ? "R$ " : "";
  return sym + "\u2022".repeat(digits);
}
function formatDateShort(date, locale = "pt-BR") {
  const d = date instanceof Date ? date : new Date(date);
  return new Intl.DateTimeFormat(locale, {
    day: "numeric",
    month: "short",
    year: "numeric"
  }).format(d).replace(/\./g, "");
}
function formatInstallment(current, total, style = "compact") {
  return style === "prose" ? `${current} de ${total}` : `${current}/${total}`;
}
Object.assign(__ds_scope, { formatMoney, maskMoney, formatDateShort, formatInstallment });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/money.js", error: String((e && e.message) || e) }); }

// components/charts/CategoryDonut.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* Donut for category composition — only with few categories; otherwise use sorted bars. */
function CategoryDonut({
  slices = [],
  size = 132,
  thickness = 16,
  centerLabel,
  centerValue,
  valueFormatter,
  style,
  ...rest
}) {
  const fmt = valueFormatter || (v => __ds_scope.formatMoney(v));
  const total = slices.reduce((a, s) => a + Math.abs(s.value), 0) || 1;
  const r = (size - thickness) / 2;
  const c = 2 * Math.PI * r;
  let offset = 0;
  return /*#__PURE__*/React.createElement("figure", _extends({
    style: {
      margin: 0,
      display: "flex",
      alignItems: "center",
      gap: 20,
      minWidth: 0,
      flexWrap: "wrap",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      width: size,
      height: size,
      flex: "none"
    }
  }, /*#__PURE__*/React.createElement("svg", {
    width: size,
    height: size,
    role: "img",
    "aria-label": slices.map(s => `${s.label}: ${fmt(s.value)}`).join("; "),
    style: {
      transform: "rotate(-90deg)"
    }
  }, /*#__PURE__*/React.createElement("circle", {
    cx: size / 2,
    cy: size / 2,
    r: r,
    fill: "none",
    stroke: "var(--surface-alt)",
    strokeWidth: thickness
  }), slices.map((s, i) => {
    const len = Math.abs(s.value) / total * c;
    const el = /*#__PURE__*/React.createElement("circle", {
      key: i,
      cx: size / 2,
      cy: size / 2,
      r: r,
      fill: "none",
      stroke: s.color || `var(--chart-${i % 8 + 1})`,
      strokeWidth: thickness,
      strokeDasharray: `${len} ${c - len}`,
      strokeDashoffset: -offset
    });
    offset += len;
    return el;
  })), (centerLabel || centerValue) && /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      inset: 0,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      gap: 2
    }
  }, centerLabel && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11,
      color: "var(--text-muted)"
    }
  }, centerLabel), centerValue && /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 15,
      fontWeight: 600,
      color: "var(--text-primary)"
    }
  }, centerValue))), /*#__PURE__*/React.createElement("table", {
    style: {
      borderCollapse: "collapse",
      fontSize: 13,
      minWidth: 200,
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("tbody", null, slices.map((s, i) => /*#__PURE__*/React.createElement("tr", {
    key: i
  }, /*#__PURE__*/React.createElement("td", {
    style: {
      padding: "3px 8px 3px 0",
      width: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "block",
      width: 10,
      height: 10,
      borderRadius: 3,
      background: s.color || `var(--chart-${i % 8 + 1})`
    }
  })), /*#__PURE__*/React.createElement("td", {
    style: {
      padding: "3px 12px 3px 0",
      color: "var(--text-secondary)"
    }
  }, s.label), /*#__PURE__*/React.createElement("td", {
    className: "fin-tnum",
    style: {
      padding: "3px 12px 3px 0",
      textAlign: "right",
      color: "var(--text-primary)",
      fontWeight: 600
    }
  }, fmt(s.value)), /*#__PURE__*/React.createElement("td", {
    className: "fin-tnum",
    style: {
      padding: "3px 0",
      textAlign: "right",
      color: "var(--text-muted)"
    }
  }, Math.round(Math.abs(s.value) / total * 100), "%"))))));
}
Object.assign(__ds_scope, { CategoryDonut });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/charts/CategoryDonut.jsx", error: String((e && e.message) || e) }); }

// components/charts/ComparisonBars.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* Grouped bars: income vs. expenses, or budget vs. actual. Zero baseline mandatory. */
function ComparisonBars({
  groups = [],
  series = [],
  height = 160,
  valueFormatter,
  showLegend = true,
  style,
  ...rest
}) {
  const fmt = valueFormatter || (v => __ds_scope.formatMoney(v));
  const max = Math.max(1, ...groups.flatMap(g => g.values.map(v => Math.abs(v))));
  return /*#__PURE__*/React.createElement("figure", _extends({
    style: {
      margin: 0,
      display: "flex",
      flexDirection: "column",
      gap: 12,
      minWidth: 0,
      ...style
    }
  }, rest), showLegend && /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16,
      flexWrap: "wrap"
    }
  }, series.map((s, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 6,
      fontSize: "var(--text-caption)",
      color: "var(--text-secondary)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 10,
      height: 10,
      borderRadius: 3,
      background: s.color,
      flex: "none"
    }
  }), s.label))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "flex-end",
      gap: 16,
      height,
      borderBottom: "1px solid var(--border-strong)",
      paddingBottom: 0
    },
    role: "img",
    "aria-label": groups.map(g => `${g.label}: ${g.values.map((v, i) => `${series[i] ? series[i].label : ""} ${fmt(v)}`).join(", ")}`).join("; ")
  }, groups.map((g, gi) => /*#__PURE__*/React.createElement("div", {
    key: gi,
    style: {
      flex: 1,
      display: "flex",
      flexDirection: "column",
      justifyContent: "flex-end",
      alignItems: "center",
      gap: 6,
      height: "100%"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "flex-end",
      gap: 4,
      height: "100%",
      width: "100%",
      justifyContent: "center"
    }
  }, g.values.map((v, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    title: `${g.label} · ${series[i] ? series[i].label : ""} · ${fmt(v)}`,
    style: {
      width: 18,
      height: Math.max(2, Math.abs(v) / max * 100) + "%",
      background: series[i] ? series[i].color : "var(--chart-1)",
      borderRadius: "var(--radius-sm) var(--radius-sm) 0 0",
      transition: "height var(--duration-panel) var(--ease-decelerate)"
    }
  })))))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16
    }
  }, groups.map((g, gi) => /*#__PURE__*/React.createElement("span", {
    key: gi,
    style: {
      flex: 1,
      textAlign: "center",
      fontSize: 11,
      color: "var(--text-muted)"
    }
  }, g.label))));
}
Object.assign(__ds_scope, { ComparisonBars });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/charts/ComparisonBars.jsx", error: String((e && e.message) || e) }); }

// components/charts/TrendChart.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* Line/area chart for cash flow or balance over time. Zero baseline included. */
function TrendChart({
  data = [],
  height = 140,
  tone = "var(--chart-1)",
  showArea = true,
  valueFormatter,
  style,
  ...rest
}) {
  const vals = data.map(d => d.value);
  const max = Math.max(0, ...vals);
  const min = Math.min(0, ...vals);
  const span = max - min || 1;
  const W = 100,
    H = 100;
  const pts = data.map((d, i) => {
    const x = data.length === 1 ? 0 : i / (data.length - 1) * W;
    const y = H - (d.value - min) / span * H;
    return [x, y];
  });
  const line = pts.map((p, i) => (i ? "L" : "M") + p[0].toFixed(2) + " " + p[1].toFixed(2)).join(" ");
  const zeroY = H - (0 - min) / span * H;
  const area = pts.length ? line + ` L${W} ${zeroY} L0 ${zeroY} Z` : "";
  const fmt = valueFormatter || (v => __ds_scope.formatMoney(v));
  const last = data[data.length - 1];
  return /*#__PURE__*/React.createElement("figure", _extends({
    style: {
      margin: 0,
      display: "flex",
      flexDirection: "column",
      gap: 8,
      minWidth: 0,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("svg", {
    viewBox: `0 0 ${W} ${H}`,
    preserveAspectRatio: "none",
    role: "img",
    "aria-label": data.map(d => `${d.label}: ${fmt(d.value)}`).join("; "),
    style: {
      width: "100%",
      height,
      display: "block",
      overflow: "visible"
    }
  }, /*#__PURE__*/React.createElement("line", {
    x1: "0",
    y1: zeroY,
    x2: W,
    y2: zeroY,
    stroke: "var(--border)",
    strokeWidth: "0.6",
    vectorEffect: "non-scaling-stroke"
  }), showArea && /*#__PURE__*/React.createElement("path", {
    d: area,
    fill: tone,
    opacity: "0.10"
  }), /*#__PURE__*/React.createElement("path", {
    d: line,
    fill: "none",
    stroke: tone,
    strokeWidth: "2",
    vectorEffect: "non-scaling-stroke",
    strokeLinejoin: "round",
    strokeLinecap: "round"
  }), pts.length > 0 && /*#__PURE__*/React.createElement("circle", {
    cx: pts[pts.length - 1][0],
    cy: pts[pts.length - 1][1],
    r: "3",
    fill: tone,
    vectorEffect: "non-scaling-stroke"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "space-between",
      gap: 8
    }
  }, data.map((d, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      fontSize: 11,
      color: "var(--text-muted)"
    }
  }, d.label))), last && /*#__PURE__*/React.createElement("figcaption", {
    className: "fin-tnum",
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-secondary)"
    }
  }, "\xDAltimo ponto \u2014 ", last.label, ": ", fmt(last.value)));
}
Object.assign(__ds_scope, { TrendChart });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/charts/TrendChart.jsx", error: String((e && e.message) || e) }); }

// components/data/MoneyText.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const SIZES = {
  hero: {
    fontSize: "var(--text-amount-hero)",
    fontWeight: 650,
    lineHeight: "var(--lh-amount-hero)",
    letterSpacing: "-0.01em"
  },
  standard: {
    fontSize: "var(--text-amount)",
    fontWeight: 600,
    lineHeight: "var(--lh-amount)"
  },
  compact: {
    fontSize: 14,
    fontWeight: 600,
    lineHeight: 1.3
  }
};
function MoneyText({
  minor = 0,
  size = "standard",
  polarity = "auto",
  locale = "pt-BR",
  currency = "BRL",
  showSign = false,
  tone,
  style,
  ...rest
}) {
  let color = "var(--text-primary)";
  const p = polarity === "auto" ? minor > 0 ? "positive" : minor < 0 ? "negative" : "neutral" : polarity;
  if (tone === "semantic") color = p === "positive" ? "var(--positive)" : p === "negative" ? "var(--negative)" : "var(--text-primary)";
  if (tone === "muted") color = "var(--text-muted)";
  const text = __ds_scope.formatMoney(minor, {
    locale,
    currency,
    sign: showSign ? "always" : "auto"
  });
  const srPolarity = p === "positive" ? "entrada" : p === "negative" ? "saída" : "";
  return /*#__PURE__*/React.createElement("span", _extends({
    className: "fin-tnum",
    "aria-label": `${srPolarity} ${text}`.trim(),
    style: {
      color,
      fontFamily: "var(--font-sans)",
      whiteSpace: "nowrap",
      ...SIZES[size],
      ...style
    }
  }, rest), text);
}
Object.assign(__ds_scope, { MoneyText });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/MoneyText.jsx", error: String((e && e.message) || e) }); }

// components/data/PrivacyAmount.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function PrivacyAmount({
  minor = 0,
  hidden = false,
  size = "standard",
  currency = "BRL",
  locale = "pt-BR",
  maskDigits = 6,
  style,
  ...rest
}) {
  if (!hidden) return /*#__PURE__*/React.createElement(__ds_scope.MoneyText, _extends({
    minor: minor,
    size: size,
    currency: currency,
    locale: locale,
    style: style
  }, rest));
  const sizeStyle = size === "hero" ? {
    fontSize: "var(--text-amount-hero)",
    fontWeight: 650,
    lineHeight: "var(--lh-amount-hero)"
  } : size === "compact" ? {
    fontSize: 14,
    fontWeight: 600,
    lineHeight: 1.3
  } : {
    fontSize: "var(--text-amount)",
    fontWeight: 600,
    lineHeight: "var(--lh-amount)"
  };
  return /*#__PURE__*/React.createElement("span", _extends({
    className: "fin-tnum",
    "aria-label": "valor oculto pelo modo privacidade",
    style: {
      color: "var(--text-secondary)",
      letterSpacing: "0.04em",
      whiteSpace: "nowrap",
      ...sizeStyle,
      ...style
    }
  }, rest), __ds_scope.maskMoney({
    currency,
    locale,
    digits: maskDigits
  }));
}
Object.assign(__ds_scope, { PrivacyAmount });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/PrivacyAmount.jsx", error: String((e && e.message) || e) }); }

// components/data/TransactionTile.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const KIND = {
  expense: {
    icon: "arrow-down-left",
    color: "var(--text-secondary)"
  },
  income: {
    icon: "arrow-up-right",
    color: "var(--positive)"
  },
  transfer: {
    icon: "arrow-left-right",
    color: "var(--info)"
  },
  cardPayment: {
    icon: "credit-card",
    color: "var(--info)"
  }
};
function TransactionTile({
  title,
  category,
  account,
  date,
  minor,
  kind = "expense",
  installment,
  status,
  statusTone = "neutral",
  statusIcon,
  icon,
  privacyHidden = false,
  selected = false,
  onClick,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  const k = KIND[kind] || KIND.expense;
  const meta = [category, account].filter(Boolean).join(" · ");
  return /*#__PURE__*/React.createElement("div", _extends({
    role: onClick ? "button" : undefined,
    tabIndex: onClick ? 0 : undefined,
    onClick: onClick,
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: "flex",
      alignItems: "center",
      gap: 12,
      padding: "12px 16px",
      minHeight: 64,
      background: selected ? "var(--primary-soft)" : hover && onClick ? "var(--surface-alt)" : "var(--surface-canvas)",
      borderBottom: "1px solid var(--border)",
      cursor: onClick ? "pointer" : "default",
      transition: "background var(--duration-fast) var(--ease-standard)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      width: 36,
      height: 36,
      flex: "none",
      borderRadius: "var(--radius-md)",
      background: "var(--surface-alt)",
      color: k.color
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon || k.icon,
    size: 18
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 2,
      minWidth: 0,
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      fontWeight: 550,
      color: "var(--text-primary)",
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, title), installment && /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 11,
      fontWeight: 600,
      color: "var(--text-muted)",
      background: "var(--surface-alt)",
      borderRadius: "var(--radius-sm)",
      padding: "1px 6px",
      flex: "none"
    }
  }, installment)), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)",
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, meta)), /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      flexDirection: "column",
      alignItems: "flex-end",
      gap: 4,
      flex: "none"
    }
  }, privacyHidden ? /*#__PURE__*/React.createElement(__ds_scope.PrivacyAmount, {
    minor: minor,
    hidden: true,
    size: "standard",
    maskDigits: 5
  }) : /*#__PURE__*/React.createElement(__ds_scope.MoneyText, {
    minor: minor,
    size: "standard",
    tone: kind === "income" ? "semantic" : undefined,
    showSign: kind === "income"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8
    }
  }, date && /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, date), status && /*#__PURE__*/React.createElement(__ds_scope.StatusBadge, {
    tone: statusTone,
    icon: statusIcon,
    size: "compact"
  }, status))));
}
Object.assign(__ds_scope, { TransactionTile });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/TransactionTile.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Banner.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const TONES = {
  info: {
    fg: "var(--info)",
    bg: "var(--info-soft)",
    icon: "info"
  },
  success: {
    fg: "var(--positive)",
    bg: "var(--positive-soft)",
    icon: "circle-check"
  },
  warning: {
    fg: "var(--warning)",
    bg: "var(--warning-soft)",
    icon: "triangle-alert"
  },
  danger: {
    fg: "var(--negative)",
    bg: "var(--negative-soft)",
    icon: "circle-alert"
  },
  neutral: {
    fg: "var(--text-secondary)",
    bg: "var(--neutral-soft)",
    icon: "info"
  }
};
function Banner({
  tone = "info",
  title,
  children,
  icon,
  actions,
  onDismiss,
  style,
  ...rest
}) {
  const t = TONES[tone] || TONES.info;
  return /*#__PURE__*/React.createElement("div", _extends({
    role: tone === "danger" ? "alert" : "status",
    style: {
      display: "flex",
      alignItems: "flex-start",
      gap: 12,
      padding: "12px 14px",
      background: t.bg,
      border: "1px solid var(--border)",
      borderRadius: "var(--radius-md)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon || t.icon,
    size: 18,
    color: t.fg,
    style: {
      marginTop: 1
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0,
      display: "flex",
      flexDirection: "column",
      gap: 4
    }
  }, title && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      fontWeight: 600,
      color: "var(--text-primary)"
    }
  }, title), children && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      lineHeight: 1.5,
      color: "var(--text-secondary)"
    }
  }, children), actions && /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      marginTop: 4
    }
  }, actions)), onDismiss && /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onDismiss,
    "aria-label": "Fechar aviso",
    style: {
      background: "none",
      border: "none",
      padding: 4,
      cursor: "pointer",
      color: "var(--text-muted)",
      lineHeight: 0
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "x",
    size: 16
  })));
}
Object.assign(__ds_scope, { Banner });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Banner.jsx", error: String((e && e.message) || e) }); }

// components/feedback/BottomSheet.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function BottomSheet({
  open = true,
  title,
  children,
  actions,
  onClose,
  inline = false,
  style,
  ...rest
}) {
  if (!open) return null;
  const panel = /*#__PURE__*/React.createElement("div", _extends({
    role: "dialog",
    "aria-modal": "true",
    "aria-label": title,
    style: {
      width: "100%",
      background: "var(--surface-canvas)",
      borderTopLeftRadius: "var(--radius-lg)",
      borderTopRightRadius: "var(--radius-lg)",
      borderTop: "1px solid var(--border)",
      boxShadow: "var(--elevation-3)",
      animation: "fin-sheet-in var(--duration-panel) var(--ease-decelerate)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "center",
      padding: "8px 0 4px"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 36,
      height: 4,
      borderRadius: 999,
      background: "var(--border-strong)"
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      padding: "4px 16px 12px"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: "var(--text-h3)",
      fontWeight: "var(--fw-h3)",
      color: "var(--text-primary)"
    }
  }, title), onClose && /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClose,
    "aria-label": "Fechar",
    style: {
      background: "none",
      border: "none",
      padding: 8,
      cursor: "pointer",
      color: "var(--text-muted)",
      lineHeight: 0
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "x",
    size: 20
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "0 16px",
      borderTop: "1px solid var(--border)"
    }
  }, children), actions && /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 8,
      padding: 16
    }
  }, actions));
  if (inline) return panel;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "fixed",
      inset: 0,
      display: "flex",
      alignItems: "flex-end",
      background: "rgba(19,32,29,.36)",
      zIndex: 60
    },
    onClick: onClose
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: "100%"
    },
    onClick: e => e.stopPropagation()
  }, panel));
}
Object.assign(__ds_scope, { BottomSheet });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/BottomSheet.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Dialog.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Dialog({
  open = true,
  title,
  description,
  tone = "default",
  icon,
  children,
  actions,
  onClose,
  width = 440,
  inline = false,
  style,
  ...rest
}) {
  if (!open) return null;
  const accent = tone === "danger" ? "var(--negative)" : "var(--primary)";
  const panel = /*#__PURE__*/React.createElement("div", _extends({
    role: "dialog",
    "aria-modal": "true",
    "aria-label": title,
    style: {
      width,
      maxWidth: "100%",
      background: "var(--surface-canvas)",
      border: "1px solid var(--border)",
      borderRadius: "var(--radius-lg)",
      boxShadow: "var(--elevation-3)",
      overflow: "hidden",
      animation: "fin-dialog-in var(--duration-panel) var(--ease-decelerate)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "flex-start",
      gap: 12,
      padding: "20px 20px 0"
    }
  }, (icon || tone === "danger") && /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      width: 36,
      height: 36,
      flex: "none",
      borderRadius: "var(--radius-md)",
      background: tone === "danger" ? "var(--negative-soft)" : "var(--primary-soft)",
      color: accent
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon || "triangle-alert",
    size: 20
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, title && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: "var(--text-h3)",
      fontWeight: "var(--fw-h3)",
      lineHeight: "var(--lh-h3)",
      color: "var(--text-primary)"
    }
  }, title), description && /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 6,
      fontSize: 14,
      lineHeight: 1.5,
      color: "var(--text-secondary)"
    }
  }, description)), onClose && /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onClose,
    "aria-label": "Fechar",
    style: {
      background: "none",
      border: "none",
      padding: 4,
      cursor: "pointer",
      color: "var(--text-muted)",
      lineHeight: 0
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "x",
    size: 18
  }))), children && /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "16px 20px 0"
    }
  }, children), actions && /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "flex-end",
      gap: 12,
      padding: "20px",
      marginTop: 4
    }
  }, actions));
  if (inline) return panel;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "fixed",
      inset: 0,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      padding: 24,
      background: "rgba(19,32,29,.36)",
      zIndex: 60
    },
    onClick: onClose
  }, /*#__PURE__*/React.createElement("div", {
    onClick: e => e.stopPropagation()
  }, panel));
}
Object.assign(__ds_scope, { Dialog });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Dialog.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Toast.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const TONES = {
  success: {
    fg: "var(--positive)",
    icon: "circle-check"
  },
  info: {
    fg: "var(--info)",
    icon: "info"
  },
  warning: {
    fg: "var(--warning)",
    icon: "triangle-alert"
  }
};
function Toast({
  tone = "success",
  message,
  actionLabel,
  onAction,
  onDismiss,
  style,
  ...rest
}) {
  const t = TONES[tone] || TONES.success;
  return /*#__PURE__*/React.createElement("div", _extends({
    role: "status",
    "aria-live": "polite",
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 12,
      padding: "12px 14px",
      maxWidth: 420,
      background: "var(--surface-canvas)",
      border: "1px solid var(--border)",
      borderRadius: "var(--radius-md)",
      boxShadow: "var(--elevation-2)",
      animation: "fin-toast-in var(--duration-panel) var(--ease-decelerate)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: t.icon,
    size: 18,
    color: t.fg
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 14,
      color: "var(--text-primary)"
    }
  }, message), actionLabel && /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onAction,
    style: {
      background: "none",
      border: "none",
      padding: 0,
      font: "inherit",
      fontSize: 13,
      fontWeight: 600,
      color: "var(--primary)",
      cursor: "pointer"
    }
  }, actionLabel), onDismiss && /*#__PURE__*/React.createElement("button", {
    type: "button",
    onClick: onDismiss,
    "aria-label": "Fechar",
    style: {
      background: "none",
      border: "none",
      padding: 2,
      cursor: "pointer",
      color: "var(--text-muted)",
      lineHeight: 0
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "x",
    size: 14
  })));
}
Object.assign(__ds_scope, { Toast });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Toast.jsx", error: String((e && e.message) || e) }); }

// components/forms/Checkbox.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Checkbox({
  label,
  checked = false,
  indeterminate = false,
  disabled = false,
  onChange,
  style,
  ...rest
}) {
  const on = checked || indeterminate;
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 8,
      minHeight: 24,
      cursor: disabled ? "not-allowed" : "pointer",
      opacity: disabled ? 0.5 : 1,
      fontSize: 14,
      color: "var(--text-primary)",
      ...style
    }
  }, /*#__PURE__*/React.createElement("input", _extends({
    type: "checkbox",
    checked: checked,
    disabled: disabled,
    onChange: onChange,
    style: {
      position: "absolute",
      opacity: 0,
      width: 1,
      height: 1
    }
  }, rest)), /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      width: 18,
      height: 18,
      flex: "none",
      borderRadius: "var(--radius-sm)",
      border: "1px solid " + (on ? "var(--primary)" : "var(--border-strong)"),
      background: on ? "var(--primary)" : "var(--surface-canvas)",
      transition: "background var(--duration-fast) var(--ease-standard)"
    }
  }, on && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: indeterminate ? "minus" : "check",
    size: 14,
    color: "var(--on-primary)"
  })), label && /*#__PURE__*/React.createElement("span", null, label));
}
Object.assign(__ds_scope, { Checkbox });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Checkbox.jsx", error: String((e && e.message) || e) }); }

// components/data/DataTable.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function DataTable({
  columns = [],
  rows = [],
  selectable = false,
  selectedIds = [],
  onToggleRow,
  onToggleAll,
  sortKey,
  sortDir = "asc",
  onSort,
  onRowClick,
  activeId,
  stickyHeader = true,
  emptyLabel = "Nenhum registro encontrado",
  style,
  ...rest
}) {
  const allSelected = rows.length > 0 && selectedIds.length === rows.length;
  const someSelected = selectedIds.length > 0 && !allSelected;
  const gridCols = (selectable ? "40px " : "") + columns.map(c => c.width || "1fr").join(" ");
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      border: "1px solid var(--border)",
      borderRadius: "var(--radius-md)",
      background: "var(--surface-canvas)",
      overflow: "hidden",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: gridCols,
      alignItems: "center",
      gap: 12,
      padding: "0 16px",
      height: 44,
      background: "var(--surface-alt)",
      borderBottom: "1px solid var(--border)",
      position: stickyHeader ? "sticky" : "static",
      top: 0,
      zIndex: 1
    }
  }, selectable && /*#__PURE__*/React.createElement(__ds_scope.Checkbox, {
    checked: allSelected,
    indeterminate: someSelected,
    onChange: onToggleAll,
    "aria-label": "Selecionar todos"
  }), columns.map(c => {
    const active = sortKey === c.key;
    return /*#__PURE__*/React.createElement("button", {
      key: c.key,
      type: "button",
      onClick: c.sortable === false || !onSort ? undefined : () => onSort(c.key),
      style: {
        display: "flex",
        alignItems: "center",
        gap: 4,
        justifyContent: c.align === "right" ? "flex-end" : "flex-start",
        background: "none",
        border: "none",
        padding: 0,
        font: "inherit",
        fontSize: 11,
        fontWeight: 600,
        letterSpacing: "0.06em",
        textTransform: "uppercase",
        color: active ? "var(--text-primary)" : "var(--text-muted)",
        cursor: c.sortable === false || !onSort ? "default" : "pointer"
      }
    }, c.label, active && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: sortDir === "asc" ? "arrow-up" : "arrow-down",
      size: 12
    }));
  })), rows.length === 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "32px 16px",
      textAlign: "center",
      fontSize: 14,
      color: "var(--text-muted)"
    }
  }, emptyLabel), rows.map(r => {
    const sel = selectedIds.includes(r.id);
    return /*#__PURE__*/React.createElement(Row, {
      key: r.id,
      row: r,
      columns: columns,
      gridCols: gridCols,
      selectable: selectable,
      selected: sel,
      active: activeId === r.id,
      onToggleRow: onToggleRow,
      onRowClick: onRowClick
    });
  }));
}
function Row({
  row,
  columns,
  gridCols,
  selectable,
  selected,
  active,
  onToggleRow,
  onRowClick
}) {
  const [hover, setHover] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    onClick: onRowClick ? () => onRowClick(row) : undefined,
    tabIndex: onRowClick ? 0 : undefined,
    style: {
      display: "grid",
      gridTemplateColumns: gridCols,
      alignItems: "center",
      gap: 12,
      padding: "0 16px",
      minHeight: 48,
      borderBottom: "1px solid var(--border)",
      background: active || selected ? "var(--primary-soft)" : hover ? "var(--surface-alt)" : "transparent",
      cursor: onRowClick ? "pointer" : "default",
      transition: "background var(--duration-fast) var(--ease-standard)"
    }
  }, selectable && /*#__PURE__*/React.createElement(__ds_scope.Checkbox, {
    checked: selected,
    onChange: () => onToggleRow && onToggleRow(row.id),
    "aria-label": "Selecionar " + row.id
  }), columns.map(c => /*#__PURE__*/React.createElement("div", {
    key: c.key,
    className: c.align === "right" ? "fin-tnum" : undefined,
    style: {
      fontSize: 14,
      color: "var(--text-primary)",
      minWidth: 0,
      display: "flex",
      alignItems: "center",
      gap: 8,
      justifyContent: c.align === "right" ? "flex-end" : "flex-start",
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, c.render ? c.render(row) : row[c.key])));
}
Object.assign(__ds_scope, { DataTable });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/data/DataTable.jsx", error: String((e && e.message) || e) }); }

// components/forms/Input.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const H = {
  compact: 32,
  standard: 40,
  prominent: 48
};
function Input({
  label,
  hint,
  error,
  success,
  prefix,
  suffix,
  iconLeft,
  size = "standard",
  readOnly = false,
  disabled = false,
  align = "left",
  id,
  style,
  ...rest
}) {
  const [focus, setFocus] = React.useState(false);
  const [hover, setHover] = React.useState(false);
  const uid = React.useMemo(() => id || "fin-in-" + Math.random().toString(36).slice(2, 7), [id]);
  const state = error ? "error" : success ? "success" : "default";
  const borderColor = state === "error" ? "var(--negative)" : state === "success" ? "var(--positive)" : focus ? "var(--primary)" : hover && !disabled ? "var(--border-strong)" : "var(--border)";
  const msg = error || success || hint;
  const msgColor = error ? "var(--negative)" : success ? "var(--positive)" : "var(--text-muted)";
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6,
      minWidth: 0,
      ...style
    }
  }, label && /*#__PURE__*/React.createElement("label", {
    htmlFor: uid,
    style: {
      fontSize: "var(--text-label)",
      fontWeight: "var(--fw-label)",
      lineHeight: "var(--lh-label)",
      color: "var(--text-secondary)"
    }
  }, label), /*#__PURE__*/React.createElement("div", {
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      height: H[size] || 40,
      padding: "0 12px",
      background: disabled ? "var(--surface-alt)" : readOnly ? "var(--surface-alt)" : "var(--surface-canvas)",
      border: "1px solid " + borderColor,
      borderRadius: "var(--radius-md)",
      outline: focus ? "2px solid var(--focus-ring)" : "none",
      outlineOffset: 2,
      transition: "border-color var(--duration-fast) var(--ease-standard)",
      opacity: disabled ? 0.6 : 1
    }
  }, iconLeft && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: iconLeft,
    size: 16,
    color: "var(--text-muted)"
  }), prefix && /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 14,
      color: "var(--text-muted)"
    }
  }, prefix), /*#__PURE__*/React.createElement("input", _extends({
    id: uid,
    readOnly: readOnly,
    disabled: disabled,
    style: {
      flex: 1,
      minWidth: 0,
      border: "none",
      outline: "none",
      background: "transparent",
      fontFamily: "var(--font-sans)",
      fontSize: 14,
      color: "var(--text-primary)",
      textAlign: align,
      fontVariantNumeric: align === "right" ? "tabular-nums" : undefined
    }
  }, rest)), suffix && /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 14,
      color: "var(--text-muted)"
    }
  }, suffix), state === "error" && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "circle-alert",
    size: 16,
    color: "var(--negative)"
  }), state === "success" && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "circle-check",
    size: 16,
    color: "var(--positive)"
  })), msg && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      lineHeight: "var(--lh-caption)",
      color: msgColor
    }
  }, msg));
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Input.jsx", error: String((e && e.message) || e) }); }

// components/forms/CurrencyInput.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
/* Integer minor units beneath the formatting — never a float. */
function formatMinor(minor, locale = "pt-BR", currency = "BRL") {
  const abs = Math.abs(minor);
  const s = new Intl.NumberFormat(locale, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(abs / 100);
  return (minor < 0 ? "\u2212" : "") + s;
}
function CurrencyInput({
  label = "Valor",
  valueMinor = 0,
  onChangeMinor,
  currencySymbol = "R$",
  locale = "pt-BR",
  hint,
  error,
  installments,
  size = "standard",
  align = "right",
  ...rest
}) {
  const [text, setText] = React.useState(formatMinor(valueMinor, locale));
  React.useEffect(() => {
    setText(formatMinor(valueMinor, locale));
  }, [valueMinor, locale]);
  function handle(e) {
    const digits = (e.target.value.match(/\d/g) || []).join("");
    const minor = digits ? parseInt(digits, 10) : 0;
    setText(formatMinor(minor, locale));
    if (onChangeMinor) onChangeMinor(minor);
  }
  const preview = installments && installments > 1 ? `${installments}x de ${currencySymbol} ${formatMinor(Math.round(valueMinor / installments), locale)}` : null;
  return /*#__PURE__*/React.createElement(__ds_scope.Input, _extends({
    label: label,
    prefix: currencySymbol,
    value: text,
    onChange: handle,
    inputMode: "decimal",
    align: align,
    size: size,
    error: error,
    hint: error ? undefined : preview || hint
  }, rest));
}
Object.assign(__ds_scope, { CurrencyInput });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/CurrencyInput.jsx", error: String((e && e.message) || e) }); }

// components/forms/Select.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const H = {
  compact: 32,
  standard: 40,
  prominent: 48
};
function Select({
  label,
  hint,
  error,
  options = [],
  size = "standard",
  disabled = false,
  id,
  style,
  ...rest
}) {
  const [focus, setFocus] = React.useState(false);
  const uid = React.useMemo(() => id || "fin-sel-" + Math.random().toString(36).slice(2, 7), [id]);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 6,
      minWidth: 0,
      ...style
    }
  }, label && /*#__PURE__*/React.createElement("label", {
    htmlFor: uid,
    style: {
      fontSize: "var(--text-label)",
      fontWeight: "var(--fw-label)",
      color: "var(--text-secondary)"
    }
  }, label), /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      display: "flex",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("select", _extends({
    id: uid,
    disabled: disabled,
    onFocus: () => setFocus(true),
    onBlur: () => setFocus(false),
    style: {
      appearance: "none",
      width: "100%",
      height: H[size] || 40,
      padding: "0 34px 0 12px",
      fontFamily: "var(--font-sans)",
      fontSize: 14,
      color: "var(--text-primary)",
      background: disabled ? "var(--surface-alt)" : "var(--surface-canvas)",
      border: "1px solid " + (error ? "var(--negative)" : focus ? "var(--primary)" : "var(--border)"),
      borderRadius: "var(--radius-md)",
      outline: focus ? "2px solid var(--focus-ring)" : "none",
      outlineOffset: 2,
      opacity: disabled ? 0.6 : 1,
      cursor: disabled ? "not-allowed" : "pointer"
    }
  }, rest), options.map(o => {
    const v = typeof o === "string" ? o : o.value;
    const l = typeof o === "string" ? o : o.label;
    return /*#__PURE__*/React.createElement("option", {
      key: v,
      value: v
    }, l);
  })), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-down",
    size: 16,
    color: "var(--text-muted)",
    style: {
      position: "absolute",
      right: 10,
      pointerEvents: "none"
    }
  })), (error || hint) && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      color: error ? "var(--negative)" : "var(--text-muted)"
    }
  }, error || hint));
}
Object.assign(__ds_scope, { Select });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Select.jsx", error: String((e && e.message) || e) }); }

// components/forms/Switch.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Switch({
  label,
  description,
  checked = false,
  disabled = false,
  onChange,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("label", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 12,
      cursor: disabled ? "not-allowed" : "pointer",
      opacity: disabled ? 0.5 : 1,
      ...style
    }
  }, /*#__PURE__*/React.createElement("input", _extends({
    type: "checkbox",
    role: "switch",
    checked: checked,
    disabled: disabled,
    onChange: onChange,
    style: {
      position: "absolute",
      opacity: 0,
      width: 1,
      height: 1
    }
  }, rest)), /*#__PURE__*/React.createElement("span", {
    "aria-hidden": "true",
    style: {
      position: "relative",
      width: 40,
      height: 24,
      flex: "none",
      borderRadius: "var(--radius-pill)",
      background: checked ? "var(--primary)" : "var(--color-neutral-300)",
      transition: "background var(--duration-standard) var(--ease-standard)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      position: "absolute",
      top: 3,
      left: checked ? 19 : 3,
      width: 18,
      height: 18,
      borderRadius: "var(--radius-pill)",
      background: "#fff",
      boxShadow: "var(--elevation-1)",
      transition: "left var(--duration-standard) var(--ease-standard)"
    }
  })), (label || description) && /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 2
    }
  }, label && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      color: "var(--text-primary)"
    }
  }, label), description && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, description)));
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Switch.jsx", error: String((e && e.message) || e) }); }

// components/navigation/BottomNav.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function BottomNav({
  items = [],
  activeId,
  onSelect,
  quickAdd,
  onQuickAdd,
  style,
  ...rest
}) {
  const list = items.slice(0, 5);
  return /*#__PURE__*/React.createElement("nav", _extends({
    "aria-label": "Navega\xE7\xE3o",
    style: {
      position: "relative",
      display: "flex",
      alignItems: "stretch",
      height: 64,
      flex: "none",
      background: "var(--surface-canvas)",
      borderTop: "1px solid var(--border)",
      paddingBottom: 0,
      ...style
    }
  }, rest), list.map(it => {
    const active = activeId === it.id;
    return /*#__PURE__*/React.createElement("button", {
      key: it.id,
      type: "button",
      "aria-current": active ? "page" : undefined,
      onClick: () => onSelect && onSelect(it.id),
      style: {
        flex: 1,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 4,
        minWidth: 44,
        minHeight: 44,
        background: "none",
        border: "none",
        padding: 0,
        cursor: "pointer",
        color: active ? "var(--primary)" : "var(--text-muted)",
        font: "inherit"
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: it.icon,
      size: 24
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 11,
        fontWeight: active ? 600 : 500
      }
    }, it.label));
  }), quickAdd && /*#__PURE__*/React.createElement("button", {
    type: "button",
    "aria-label": typeof quickAdd === "string" ? quickAdd : "Adicionar",
    onClick: onQuickAdd,
    style: {
      position: "absolute",
      right: 16,
      top: -28,
      width: 56,
      height: 56,
      borderRadius: "var(--radius-pill)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      background: "var(--primary)",
      color: "var(--on-primary)",
      border: "3px solid var(--surface-background)",
      boxShadow: "var(--elevation-2)",
      cursor: "pointer"
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "plus",
    size: 24
  })));
}
Object.assign(__ds_scope, { BottomNav });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/BottomNav.jsx", error: String((e && e.message) || e) }); }

// components/navigation/Sidebar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Sidebar({
  items = [],
  activeId,
  onSelect,
  collapsed = false,
  brand = "Pollar",
  footer,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("nav", _extends({
    "aria-label": "Navega\xE7\xE3o principal",
    style: {
      width: collapsed ? "var(--size-sidebar-collapsed)" : "var(--size-sidebar-expanded)",
      flex: "none",
      display: "flex",
      flexDirection: "column",
      background: "var(--surface-canvas)",
      borderRight: "1px solid var(--border)",
      transition: "width var(--duration-panel) var(--ease-standard)",
      overflow: "hidden",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 10,
      height: 60,
      padding: collapsed ? "0 0 0 24px" : "0 16px",
      flex: "none"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      width: 24,
      height: 24,
      flex: "none",
      borderRadius: 7,
      background: "var(--primary)",
      color: "var(--on-primary)"
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chart-no-axes-column-increasing",
    size: 15
  })), !collapsed && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 16,
      fontWeight: 650,
      letterSpacing: "-0.01em",
      color: "var(--text-primary)"
    }
  }, brand)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 2,
      padding: collapsed ? "4px 12px" : "4px 8px",
      flex: 1,
      overflowY: "auto"
    }
  }, items.map(it => it.section ? !collapsed && /*#__PURE__*/React.createElement("div", {
    key: it.section,
    style: {
      padding: "16px 8px 6px",
      fontSize: 11,
      fontWeight: 600,
      letterSpacing: "0.06em",
      textTransform: "uppercase",
      color: "var(--text-muted)"
    }
  }, it.section) : /*#__PURE__*/React.createElement(SideItem, {
    key: it.id,
    item: it,
    active: activeId === it.id,
    collapsed: collapsed,
    onSelect: onSelect
  }))), footer && /*#__PURE__*/React.createElement("div", {
    style: {
      padding: collapsed ? 12 : 12,
      borderTop: "1px solid var(--border)",
      flex: "none"
    }
  }, footer));
}
function SideItem({
  item,
  active,
  collapsed,
  onSelect
}) {
  const [hover, setHover] = React.useState(false);
  return /*#__PURE__*/React.createElement("button", {
    type: "button",
    title: collapsed ? item.label : undefined,
    "aria-current": active ? "page" : undefined,
    onClick: () => onSelect && onSelect(item.id),
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      display: "flex",
      alignItems: "center",
      gap: 10,
      width: "100%",
      height: 38,
      padding: collapsed ? 0 : "0 10px",
      justifyContent: collapsed ? "center" : "flex-start",
      border: "none",
      borderRadius: "var(--radius-md)",
      background: active ? "var(--primary-soft)" : hover ? "var(--surface-alt)" : "transparent",
      color: active ? "var(--primary)" : "var(--text-secondary)",
      font: "inherit",
      fontSize: 14,
      fontWeight: active ? 600 : 450,
      cursor: "pointer",
      textAlign: "left",
      transition: "background var(--duration-fast) var(--ease-standard)"
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: item.icon,
    size: 20
  }), !collapsed && /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, item.label), !collapsed && item.badge && /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 11,
      fontWeight: 600,
      color: "var(--text-muted)",
      background: "var(--surface-alt)",
      borderRadius: 999,
      padding: "1px 7px"
    }
  }, item.badge));
}
Object.assign(__ds_scope, { Sidebar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/Sidebar.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TopBar.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function TopBar({
  title,
  subtitle,
  breadcrumb,
  search = true,
  searchPlaceholder = "Buscar transações, contas, categorias",
  actions,
  style,
  ...rest
}) {
  const [focus, setFocus] = React.useState(false);
  return /*#__PURE__*/React.createElement("header", _extends({
    style: {
      display: "flex",
      alignItems: "center",
      gap: 16,
      height: 60,
      padding: "0 var(--gutter-desktop)",
      flex: "none",
      background: "var(--surface-canvas)",
      borderBottom: "1px solid var(--border)",
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      minWidth: 0,
      display: "flex",
      flexDirection: "column",
      gap: 1
    }
  }, breadcrumb && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 11,
      color: "var(--text-muted)"
    }
  }, breadcrumb), title && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 16,
      fontWeight: 650,
      color: "var(--text-primary)",
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, title), subtitle && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, subtitle)), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }), search && /*#__PURE__*/React.createElement("label", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      height: 34,
      width: 300,
      padding: "0 10px",
      background: "var(--surface-alt)",
      border: "1px solid " + (focus ? "var(--primary)" : "transparent"),
      borderRadius: "var(--radius-md)"
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "search",
    size: 16,
    color: "var(--text-muted)"
  }), /*#__PURE__*/React.createElement("input", {
    placeholder: searchPlaceholder,
    onFocus: () => setFocus(true),
    onBlur: () => setFocus(false),
    style: {
      flex: 1,
      minWidth: 0,
      border: "none",
      background: "transparent",
      outline: "none",
      fontFamily: "var(--font-sans)",
      fontSize: 13,
      color: "var(--text-primary)"
    }
  }), /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 11,
      color: "var(--text-muted)",
      border: "1px solid var(--border)",
      borderRadius: 4,
      padding: "0 4px"
    }
  }, "\u2318K")), actions);
}
Object.assign(__ds_scope, { TopBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TopBar.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/BudgetProgress.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function BudgetProgress({
  category,
  icon = "circle",
  spentMinor = 0,
  limitMinor = 1,
  style,
  ...rest
}) {
  const pct = Math.min(999, Math.round(Math.abs(spentMinor) / Math.max(1, limitMinor) * 100));
  const tone = pct >= 100 ? "danger" : pct >= 85 ? "warning" : "primary";
  const remaining = limitMinor - Math.abs(spentMinor);
  return /*#__PURE__*/React.createElement("div", _extends({
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 8,
      minWidth: 0,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 16,
    color: "var(--text-secondary)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      fontWeight: 550,
      color: "var(--text-primary)",
      flex: 1,
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, category), /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 13,
      color: "var(--text-secondary)"
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.MoneyText, {
    minor: -Math.abs(spentMinor),
    size: "compact",
    style: {
      fontWeight: 600
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      color: "var(--text-muted)",
      fontWeight: 400
    }
  }, " de "), /*#__PURE__*/React.createElement(__ds_scope.MoneyText, {
    minor: limitMinor,
    size: "compact",
    style: {
      fontWeight: 400,
      color: "var(--text-muted)"
    }
  }))), /*#__PURE__*/React.createElement(__ds_scope.ProgressMeter, {
    value: pct,
    tone: tone
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 6,
      fontSize: "var(--text-caption)",
      color: tone === "primary" ? "var(--text-muted)" : tone === "warning" ? "var(--warning)" : "var(--negative)"
    }
  }, tone !== "primary" && /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: tone === "danger" ? "circle-alert" : "triangle-alert",
    size: 12
  }), /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum"
  }, pct, "% usado"), /*#__PURE__*/React.createElement("span", null, "\xB7"), /*#__PURE__*/React.createElement("span", null, remaining >= 0 ? "Restam " : "Excedido em ", /*#__PURE__*/React.createElement(__ds_scope.MoneyText, {
    minor: Math.abs(remaining),
    size: "compact",
    style: {
      fontSize: "var(--text-caption)",
      fontWeight: 600,
      color: "inherit"
    }
  }))));
}
Object.assign(__ds_scope, { BudgetProgress });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/BudgetProgress.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const PADS = {
  none: 0,
  sm: 12,
  md: 16,
  lg: 20
};
function Card({
  padding = "lg",
  interactive = false,
  tone = "canvas",
  children,
  style,
  ...rest
}) {
  const [hover, setHover] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", _extends({
    onMouseEnter: () => setHover(true),
    onMouseLeave: () => setHover(false),
    style: {
      background: tone === "alt" ? "var(--surface-alt)" : "var(--surface-canvas)",
      border: "1px solid var(--border)",
      borderRadius: "var(--radius-lg)",
      padding: PADS[padding] ?? 20,
      boxShadow: interactive && hover ? "var(--elevation-1)" : "none",
      borderColor: interactive && hover ? "var(--border-strong)" : "var(--border)",
      transition: "box-shadow var(--duration-standard) var(--ease-standard),border-color var(--duration-standard) var(--ease-standard)",
      minWidth: 0,
      ...style
    }
  }, rest), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/Card.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/MetricCard.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function MetricCard({
  title,
  helper,
  action,
  minor,
  size = "hero",
  comparisonMinor,
  comparisonLabel,
  privacyHidden = false,
  children,
  style,
  ...rest
}) {
  const up = (comparisonMinor || 0) >= 0;
  return /*#__PURE__*/React.createElement(__ds_scope.Card, _extends({
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 12,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-label)",
      fontWeight: "var(--fw-label)",
      color: "var(--text-secondary)",
      flex: 1
    }
  }, title), helper && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, helper), action), /*#__PURE__*/React.createElement(__ds_scope.PrivacyAmount, {
    minor: minor,
    hidden: privacyHidden,
    size: size
  }), comparisonMinor !== undefined && /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: up ? "trending-up" : "trending-down",
    size: 16,
    color: up ? "var(--positive)" : "var(--negative)"
  }), /*#__PURE__*/React.createElement(__ds_scope.MoneyText, {
    minor: comparisonMinor,
    size: "compact",
    tone: "semantic",
    showSign: true
  }), comparisonLabel && /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, comparisonLabel)), children);
}
Object.assign(__ds_scope, { MetricCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/MetricCard.jsx", error: String((e && e.message) || e) }); }

// components/surfaces/StatementSummary.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function StatementSummary({
  cardName,
  brand,
  last4,
  period,
  status = "Aberta",
  statusTone = "neutral",
  statusIcon = "circle",
  totalMinor = 0,
  paidMinor = 0,
  dueDate,
  limitMinor,
  actions,
  style,
  ...rest
}) {
  const outstanding = totalMinor - paidMinor;
  const utilization = limitMinor ? Math.min(100, Math.round(Math.abs(totalMinor) / limitMinor * 100)) : null;
  return /*#__PURE__*/React.createElement(__ds_scope.Card, _extends({
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16,
      ...style
    }
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "flex-start",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      width: 40,
      height: 40,
      borderRadius: "var(--radius-md)",
      background: "var(--primary-soft)",
      color: "var(--primary)",
      flex: "none"
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "credit-card",
    size: 20
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: "var(--text-h3)",
      fontWeight: "var(--fw-h3)",
      color: "var(--text-primary)"
    }
  }, cardName), /*#__PURE__*/React.createElement("div", {
    className: "fin-tnum",
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, [brand, last4 ? "•••• " + last4 : null, period].filter(Boolean).join(" · "))), /*#__PURE__*/React.createElement(__ds_scope.StatusBadge, {
    tone: statusTone,
    icon: statusIcon
  }, status)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "repeat(3,minmax(0,1fr))",
      gap: 12,
      padding: "12px 0",
      borderTop: "1px solid var(--border)",
      borderBottom: "1px solid var(--border)"
    }
  }, /*#__PURE__*/React.createElement(Field, {
    label: "Total da fatura"
  }, /*#__PURE__*/React.createElement(__ds_scope.MoneyText, {
    minor: totalMinor,
    size: "standard"
  })), /*#__PURE__*/React.createElement(Field, {
    label: "Pago"
  }, /*#__PURE__*/React.createElement(__ds_scope.MoneyText, {
    minor: paidMinor,
    size: "standard",
    tone: paidMinor ? "semantic" : undefined
  })), /*#__PURE__*/React.createElement(Field, {
    label: "Em aberto"
  }, /*#__PURE__*/React.createElement(__ds_scope.MoneyText, {
    minor: outstanding,
    size: "standard"
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 12,
      flexWrap: "wrap"
    }
  }, dueDate && /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      gap: 6,
      fontSize: 13,
      color: "var(--text-secondary)"
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "calendar-clock",
    size: 16,
    color: "var(--text-muted)"
  }), "Vence em ", /*#__PURE__*/React.createElement("strong", {
    className: "fin-tnum",
    style: {
      fontWeight: 600,
      color: "var(--text-primary)"
    }
  }, dueDate)), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }), actions), utilization !== null && /*#__PURE__*/React.createElement(__ds_scope.ProgressMeter, {
    label: "Limite utilizado",
    value: utilization,
    valueLabel: utilization + "%",
    tone: utilization > 85 ? "warning" : "primary"
  }));
}
function Field({
  label,
  children
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 2,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, label), children);
}
Object.assign(__ds_scope, { StatementSummary });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/surfaces/StatementSummary.jsx", error: String((e && e.message) || e) }); }

// ui_kits/desktop/DesktopScreens.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  Sidebar,
  TopBar,
  Button,
  IconButton,
  Icon,
  Card,
  MetricCard,
  StatementSummary,
  BudgetProgress,
  MoneyText,
  PrivacyAmount,
  StatusBadge,
  TransactionTile,
  DataTable,
  TrendChart,
  ComparisonBars,
  CategoryDonut,
  ProgressMeter,
  Banner,
  Dialog,
  Toast,
  Input,
  Select,
  Checkbox,
  Switch,
  CurrencyInput
} = window.PollarDesignSystem_efbbc4;
const D = window.PollarDesktopData;
function SectionTitle({
  children,
  action
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 12,
      marginBottom: 12
    }
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      margin: 0,
      fontSize: "var(--text-h3)",
      fontWeight: "var(--fw-h3)",
      lineHeight: "var(--lh-h3)",
      color: "var(--text-primary)",
      flex: 1
    }
  }, children), action);
}
function PageHead({
  title,
  subtitle,
  actions
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "flex-end",
      gap: 16,
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      margin: 0,
      fontSize: "var(--text-h1)",
      fontWeight: "var(--fw-h1)",
      lineHeight: "var(--lh-h1)",
      letterSpacing: "-0.015em",
      color: "var(--text-primary)"
    }
  }, title), subtitle && /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 4,
      fontSize: 14,
      color: "var(--text-secondary)"
    }
  }, subtitle)), actions);
}

/* ---------- 1. Dashboard ---------- */
function DashboardScreen({
  priv,
  onOpenTx,
  offline
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      maxWidth: "var(--size-dashboard-max)"
    }
  }, /*#__PURE__*/React.createElement(PageHead, {
    title: "Vis\xE3o geral",
    subtitle: "Setembro de 2026 \xB7 Todas as contas",
    actions: /*#__PURE__*/React.createElement("div", {
      style: {
        display: "flex",
        gap: 8
      }
    }, /*#__PURE__*/React.createElement(Select, {
      size: "compact",
      options: ["Setembro 2026", "Agosto 2026", "Julho 2026"],
      style: {
        width: 170
      }
    }), /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "secondary",
      iconLeft: "download"
    }, "Exportar"))
  }), offline && /*#__PURE__*/React.createElement("div", {
    style: {
      marginBottom: 20
    }
  }, /*#__PURE__*/React.createElement(Banner, {
    tone: "warning",
    title: "Voc\xEA est\xE1 offline",
    actions: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "secondary"
    }, "Tentar novamente")
  }, "As altera\xE7\xF5es ficam salvas neste dispositivo e ser\xE3o sincronizadas quando a conex\xE3o voltar.")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "repeat(3,minmax(0,1fr))",
      gap: 16,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(MetricCard, {
    title: "Saldo total",
    helper: "4 contas",
    minor: 1873455,
    comparisonMinor: 125455,
    comparisonLabel: "vs. agosto",
    privacyHidden: priv
  }), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Resultado do m\xEAs",
    helper: "Entradas \u2212 sa\xEDdas",
    minor: 191000,
    size: "hero",
    comparisonMinor: -40000,
    comparisonLabel: "vs. agosto",
    privacyHidden: priv
  }), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Faturas em aberto",
    helper: "2 cart\xF5es",
    minor: -412390,
    size: "hero",
    privacyHidden: priv
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1.55fr 1fr",
      gap: 16,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SectionTitle, {
    action: /*#__PURE__*/React.createElement(Select, {
      size: "compact",
      options: ["6 meses", "12 meses"],
      style: {
        width: 120
      }
    })
  }, "Evolu\xE7\xE3o do saldo"), /*#__PURE__*/React.createElement(TrendChart, {
    data: D.trend,
    height: 168
  })), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SectionTitle, null, "Entradas e sa\xEDdas"), /*#__PURE__*/React.createElement(ComparisonBars, {
    height: 150,
    series: [{
      label: "Entradas",
      color: "var(--chart-1)"
    }, {
      label: "Saídas",
      color: "var(--chart-3)"
    }],
    groups: D.flow
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr",
      gap: 16,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SectionTitle, {
    action: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "ghost",
      iconRight: "arrow-right"
    }, "Ver tudo")
  }, "Or\xE7amentos de setembro"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, D.budgets.slice(0, 3).map(b => /*#__PURE__*/React.createElement(BudgetProgress, _extends({
    key: b.category
  }, b))))), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SectionTitle, null, "Composi\xE7\xE3o das sa\xEDdas"), /*#__PURE__*/React.createElement(CategoryDonut, {
    size: 124,
    thickness: 16,
    centerLabel: "Sa\xEDdas",
    centerValue: "R$ 8.610,00",
    slices: D.categories
  }))), /*#__PURE__*/React.createElement(Card, {
    padding: "none"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "16px 20px 12px"
    }
  }, /*#__PURE__*/React.createElement(SectionTitle, {
    action: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "ghost",
      iconRight: "arrow-right",
      onClick: onOpenTx
    }, "Todas as transa\xE7\xF5es")
  }, "Transa\xE7\xF5es recentes")), /*#__PURE__*/React.createElement("div", {
    style: {
      borderTop: "1px solid var(--border)"
    }
  }, D.transactions.slice(0, 4).map(t => /*#__PURE__*/React.createElement(TransactionTile, {
    key: t.id,
    title: t.title,
    category: t.category,
    account: t.account,
    date: t.date,
    minor: t.minor,
    kind: t.kind,
    installment: t.installment,
    icon: t.icon,
    status: t.status[0],
    statusTone: t.status[1],
    statusIcon: t.status[2],
    privacyHidden: priv,
    onClick: onOpenTx
  })))));
}

/* ---------- 2. Transactions + detail panel ---------- */
function TransactionsScreen({
  priv
}) {
  const [selected, setSelected] = React.useState([]);
  const [active, setActive] = React.useState(D.transactions[1]);
  const [sortKey, setSortKey] = React.useState("date");
  const [sortDir, setSortDir] = React.useState("asc");
  const rows = D.transactions;
  const columns = [{
    key: "date",
    label: "Data",
    width: "104px"
  }, {
    key: "title",
    label: "Descrição",
    render: r => /*#__PURE__*/React.createElement("span", {
      style: {
        display: "flex",
        alignItems: "center",
        gap: 8,
        minWidth: 0
      }
    }, /*#__PURE__*/React.createElement(Icon, {
      name: r.icon,
      size: 16,
      color: "var(--text-muted)"
    }), /*#__PURE__*/React.createElement("span", {
      style: {
        overflow: "hidden",
        textOverflow: "ellipsis",
        whiteSpace: "nowrap"
      }
    }, r.title), r.installment && /*#__PURE__*/React.createElement("span", {
      className: "fin-tnum",
      style: {
        fontSize: 11,
        fontWeight: 600,
        color: "var(--text-muted)",
        background: "var(--surface-alt)",
        borderRadius: "var(--radius-sm)",
        padding: "1px 6px"
      }
    }, r.installment))
  }, {
    key: "category",
    label: "Categoria",
    width: "130px"
  }, {
    key: "account",
    label: "Conta",
    width: "150px"
  }, {
    key: "status",
    label: "Status",
    width: "144px",
    sortable: false,
    render: r => /*#__PURE__*/React.createElement(StatusBadge, {
      tone: r.status[1],
      icon: r.status[2],
      size: "compact"
    }, r.status[0])
  }, {
    key: "minor",
    label: "Valor",
    width: "128px",
    align: "right",
    render: r => priv ? /*#__PURE__*/React.createElement(PrivacyAmount, {
      minor: r.minor,
      hidden: true,
      size: "compact",
      maskDigits: 5
    }) : /*#__PURE__*/React.createElement(MoneyText, {
      minor: r.minor,
      size: "compact",
      tone: r.kind === "income" ? "semantic" : undefined,
      showSign: r.kind === "income"
    })
  }];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 16,
      alignItems: "flex-start"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement(PageHead, {
    title: "Transa\xE7\xF5es",
    subtitle: "1\u201330 de setembro de 2026 \xB7 128 registros",
    actions: /*#__PURE__*/React.createElement("div", {
      style: {
        display: "flex",
        gap: 8
      }
    }, /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "secondary",
      iconLeft: "sliders-horizontal"
    }, "Filtros"), /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      iconLeft: "plus"
    }, "Nova transa\xE7\xE3o"))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      alignItems: "center",
      marginBottom: 12,
      flexWrap: "wrap"
    }
  }, /*#__PURE__*/React.createElement(Input, {
    size: "compact",
    iconLeft: "search",
    placeholder: "Buscar descri\xE7\xE3o ou valor",
    style: {
      width: 260
    }
  }), /*#__PURE__*/React.createElement(Select, {
    size: "compact",
    options: ["Todas as contas", "Conta corrente", "Cartão Ouro"],
    style: {
      width: 170
    }
  }), /*#__PURE__*/React.createElement(Select, {
    size: "compact",
    options: ["Todos os status", "Previsto", "Compensado", "Conciliado"],
    style: {
      width: 170
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }), selected.length > 0 && /*#__PURE__*/React.createElement("span", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 13,
      color: "var(--text-secondary)"
    }
  }, selected.length, " selecionadas"), /*#__PURE__*/React.createElement(Button, {
    size: "compact",
    variant: "secondary",
    iconLeft: "tags"
  }, "Categorizar"), /*#__PURE__*/React.createElement(Button, {
    size: "compact",
    variant: "danger",
    iconLeft: "trash-2"
  }, "Excluir")), /*#__PURE__*/React.createElement(IconButton, {
    icon: "sliders-horizontal",
    label: "Colunas",
    size: "compact",
    variant: "outline"
  })), /*#__PURE__*/React.createElement(DataTable, {
    columns: columns,
    rows: rows,
    selectable: true,
    selectedIds: selected,
    onToggleRow: id => setSelected(s => s.includes(id) ? s.filter(x => x !== id) : [...s, id]),
    onToggleAll: () => setSelected(s => s.length === rows.length ? [] : rows.map(r => r.id)),
    sortKey: sortKey,
    sortDir: sortDir,
    onSort: k => {
      setSortDir(d => k === sortKey && d === "asc" ? "desc" : "asc");
      setSortKey(k);
    },
    onRowClick: setActive,
    activeId: active && active.id
  })), active && /*#__PURE__*/React.createElement(DetailPanel, {
    tx: active,
    onClose: () => setActive(null),
    priv: priv
  }));
}
function DetailPanel({
  tx,
  onClose,
  priv
}) {
  return /*#__PURE__*/React.createElement("aside", {
    style: {
      width: "var(--size-context-panel)",
      flex: "none",
      background: "var(--surface-canvas)",
      border: "1px solid var(--border)",
      borderRadius: "var(--radius-lg)",
      overflow: "hidden",
      position: "sticky",
      top: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      padding: "14px 16px",
      borderBottom: "1px solid var(--border)"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: "var(--text-h3)",
      fontWeight: "var(--fw-h3)",
      color: "var(--text-primary)"
    }
  }, "Detalhes"), /*#__PURE__*/React.createElement(IconButton, {
    icon: "pencil",
    label: "Editar",
    size: "compact"
  }), /*#__PURE__*/React.createElement(IconButton, {
    icon: "x",
    label: "Fechar painel",
    size: "compact",
    onClick: onClose
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 16,
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 4
    }
  }, /*#__PURE__*/React.createElement(PrivacyAmount, {
    minor: tx.minor,
    hidden: priv,
    size: "hero"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 14,
      color: "var(--text-secondary)"
    }
  }, tx.title)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexWrap: "wrap",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(StatusBadge, {
    tone: tx.status[1],
    icon: tx.status[2]
  }, tx.status[0]), tx.installment && /*#__PURE__*/React.createElement(StatusBadge, {
    icon: "layers"
  }, "Parcela ", tx.installment.replace("/", " de "))), /*#__PURE__*/React.createElement("dl", {
    style: {
      margin: 0,
      display: "grid",
      gridTemplateColumns: "108px 1fr",
      rowGap: 10,
      columnGap: 12,
      fontSize: 13
    }
  }, [["Data", tx.date], ["Categoria", tx.category], ["Conta", tx.account], ["Tipo", {
    income: "Entrada",
    expense: "Saída",
    transfer: "Transferência",
    cardPayment: "Pagamento de fatura"
  }[tx.kind]], ["Identificador", tx.id.toUpperCase() + "-2026-09"]].map(([k, v]) => /*#__PURE__*/React.createElement(React.Fragment, {
    key: k
  }, /*#__PURE__*/React.createElement("dt", {
    style: {
      color: "var(--text-muted)"
    }
  }, k), /*#__PURE__*/React.createElement("dd", {
    style: {
      margin: 0,
      color: "var(--text-primary)"
    }
  }, v)))), tx.status[0] === "Conflito" && /*#__PURE__*/React.createElement(Banner, {
    tone: "danger",
    title: "Conflito de sincroniza\xE7\xE3o",
    actions: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "secondary"
    }, "Revisar vers\xF5es")
  }, "Esta transa\xE7\xE3o foi editada em dois dispositivos. Escolha qual vers\xE3o manter."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(Button, {
    variant: "secondary",
    size: "compact",
    iconLeft: "copy"
  }, "Duplicar"), /*#__PURE__*/React.createElement(Button, {
    variant: "danger",
    size: "compact",
    iconLeft: "trash-2"
  }, "Excluir"))));
}

/* ---------- 3. Card statement ---------- */
function StatementScreen({
  priv,
  onPay
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      maxWidth: 1080
    }
  }, /*#__PURE__*/React.createElement(PageHead, {
    title: "Cart\xE3o Ouro",
    subtitle: "Visa \xB7 \u2022\u2022\u2022\u2022 4417 \xB7 Fatura de setembro",
    actions: /*#__PURE__*/React.createElement("div", {
      style: {
        display: "flex",
        gap: 8
      }
    }, /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "secondary",
      iconLeft: "file-text"
    }, "Extrato PDF"), /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      iconLeft: "check",
      onClick: onPay
    }, "Pagar fatura"))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1.6fr 1fr",
      gap: 16,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(StatementSummary, {
    cardName: "Cart\xE3o Ouro",
    brand: "Visa",
    last4: "4417",
    period: "1\u201330 set 2026",
    status: "Parcialmente paga",
    statusTone: "warning",
    statusIcon: "clock",
    totalMinor: -412390,
    paidMinor: -150000,
    dueDate: "10 out 2026",
    limitMinor: 800000,
    actions: /*#__PURE__*/React.createElement("div", {
      style: {
        display: "flex",
        gap: 8
      }
    }, /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "secondary"
    }, "Pagamento parcial"), /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      onClick: onPay
    }, "Pagar fatura"))
  }), /*#__PURE__*/React.createElement(Card, {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(SectionTitle, null, "Parcelas futuras"), [["Notebook Pro", "6/12", -32083], ["Mercado do bairro", "3/12", -23480], ["Livraria Central", "1/3", -8990]].map(([t, i, v]) => /*#__PURE__*/React.createElement("div", {
    key: t,
    style: {
      display: "flex",
      alignItems: "center",
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 14,
      color: "var(--text-primary)",
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, t), /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 12,
      fontWeight: 600,
      color: "var(--text-muted)",
      background: "var(--surface-alt)",
      borderRadius: "var(--radius-sm)",
      padding: "1px 6px"
    }
  }, i), /*#__PURE__*/React.createElement(MoneyText, {
    minor: v,
    size: "compact"
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      borderTop: "1px solid var(--border)",
      paddingTop: 12,
      display: "flex",
      alignItems: "center"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 13,
      color: "var(--text-secondary)"
    }
  }, "Comprometido nos pr\xF3ximos meses"), /*#__PURE__*/React.createElement(MoneyText, {
    minor: -64553,
    size: "standard"
  })))), /*#__PURE__*/React.createElement(Card, {
    padding: "none"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "16px 20px 12px",
      display: "flex",
      alignItems: "center",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("h2", {
    style: {
      margin: 0,
      fontSize: "var(--text-h3)",
      fontWeight: "var(--fw-h3)",
      color: "var(--text-primary)",
      flex: 1
    }
  }, "Compras da fatura"), /*#__PURE__*/React.createElement(Select, {
    size: "compact",
    options: ["Agrupado por data", "Agrupado por categoria"],
    style: {
      width: 200
    }
  })), D.statementPurchases.map(g => /*#__PURE__*/React.createElement("div", {
    key: g.day
  }, /*#__PURE__*/React.createElement("div", {
    className: "fin-tnum",
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      padding: "8px 20px",
      background: "var(--surface-alt)",
      borderTop: "1px solid var(--border)",
      borderBottom: "1px solid var(--border)",
      fontSize: 12,
      fontWeight: 600,
      color: "var(--text-secondary)"
    }
  }, g.day, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement(MoneyText, {
    minor: g.items.reduce((a, i) => a + i.minor, 0),
    size: "compact",
    style: {
      fontSize: 12
    }
  })), g.items.map(i => /*#__PURE__*/React.createElement(TransactionTile, {
    key: i.id,
    title: i.title,
    category: i.category,
    account: "Cart\xE3o Ouro",
    minor: i.minor,
    installment: i.installment,
    icon: i.icon,
    privacyHidden: priv,
    onClick: () => {}
  }))))));
}

/* ---------- 4. Budgets ---------- */
function BudgetsScreen({
  priv
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      maxWidth: "var(--size-dashboard-max)"
    }
  }, /*#__PURE__*/React.createElement(PageHead, {
    title: "Or\xE7amentos",
    subtitle: "Setembro de 2026 \xB7 4 categorias acompanhadas",
    actions: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      iconLeft: "plus"
    }, "Novo or\xE7amento")
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr",
      gap: 16,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(MetricCard, {
    title: "Total or\xE7ado",
    minor: 295000,
    size: "standard",
    privacyHidden: priv
  }), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Gasto at\xE9 agora",
    minor: -236940,
    size: "standard",
    comparisonMinor: -58060,
    comparisonLabel: "restante",
    privacyHidden: priv
  })), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(SectionTitle, {
    action: /*#__PURE__*/React.createElement(Switch, {
      label: "Alertar em 85%",
      checked: true
    })
  }, "Acompanhamento por categoria"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 20
    }
  }, D.budgets.map(b => /*#__PURE__*/React.createElement(BudgetProgress, _extends({
    key: b.category
  }, b))))));
}

/* ---------- 5. Settings ---------- */
function SettingsScreen({
  priv,
  setPriv,
  theme,
  setTheme
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      maxWidth: 760
    }
  }, /*#__PURE__*/React.createElement(PageHead, {
    title: "Prefer\xEAncias",
    subtitle: "Aplicadas a este dispositivo"
  }), /*#__PURE__*/React.createElement(Card, {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 18,
      marginBottom: 16
    }
  }, /*#__PURE__*/React.createElement(SectionTitle, null, "Privacidade e exibi\xE7\xE3o"), /*#__PURE__*/React.createElement(Switch, {
    label: "Modo privacidade",
    description: "Oculta todos os valores monet\xE1rios (atalho: \u2318P)",
    checked: priv,
    onChange: () => setPriv(!priv)
  }), /*#__PURE__*/React.createElement(Switch, {
    label: "Tema escuro",
    description: "Usa a paleta escura em todas as telas",
    checked: theme === "dark",
    onChange: () => setTheme(theme === "dark" ? "light" : "dark")
  }), /*#__PURE__*/React.createElement(Switch, {
    label: "Reduzir anima\xE7\xF5es",
    description: "Respeita a prefer\xEAncia do sistema quando ativa"
  })), /*#__PURE__*/React.createElement(Card, {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(SectionTitle, null, "Moeda e formato"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr",
      gap: 16
    }
  }, /*#__PURE__*/React.createElement(Select, {
    label: "Moeda",
    options: ["Real brasileiro (R$)", "Dólar americano (US$)", "Euro (€)"]
  }), /*#__PURE__*/React.createElement(Select, {
    label: "Formato de data",
    options: ["1 set 2026", "01/09/2026", "2026-09-01"]
  })), /*#__PURE__*/React.createElement(CurrencyInput, {
    label: "Meta de reserva de emerg\xEAncia",
    valueMinor: 2400000,
    installments: 12
  }), /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement(Checkbox, {
    label: "Arredondar valores em gr\xE1ficos (os totais permanecem exatos)"
  }))));
}
Object.assign(window, {
  DashboardScreen,
  TransactionsScreen,
  StatementScreen,
  BudgetsScreen,
  SettingsScreen,
  FinPageHead: PageHead,
  FinSectionTitle: SectionTitle
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/desktop/DesktopScreens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/desktop/data.js
try { (() => {
/* Fake data for the Pollar desktop recreation. Amounts are integer minor units. */
window.PollarDesktopData = {
  nav: [{
    id: "dash",
    label: "Visão geral",
    icon: "layout-dashboard"
  }, {
    section: "Dinheiro"
  }, {
    id: "tx",
    label: "Transações",
    icon: "arrow-left-right"
  }, {
    id: "cards",
    label: "Cartões",
    icon: "credit-card",
    badge: 2
  }, {
    id: "budgets",
    label: "Orçamentos",
    icon: "target"
  }, {
    section: "Planejamento"
  }, {
    id: "reports",
    label: "Relatórios",
    icon: "chart-pie"
  }, {
    id: "settings",
    label: "Preferências",
    icon: "settings"
  }],
  trend: [{
    label: "abr",
    value: 1420000
  }, {
    label: "mai",
    value: 1512000
  }, {
    label: "jun",
    value: 1487000
  }, {
    label: "jul",
    value: 1610000
  }, {
    label: "ago",
    value: 1748000
  }, {
    label: "set",
    value: 1873455
  }],
  flow: [{
    label: "jun",
    values: [980000, 742000]
  }, {
    label: "jul",
    values: [1010000, 861000]
  }, {
    label: "ago",
    values: [1035000, 904000]
  }, {
    label: "set",
    values: [1052000, 861000]
  }],
  categories: [{
    label: "Moradia",
    value: -320000
  }, {
    label: "Alimentação",
    value: -138050
  }, {
    label: "Transporte",
    value: -42300
  }, {
    label: "Saúde",
    value: -31600
  }, {
    label: "Lazer",
    value: -24990
  }],
  budgets: [{
    category: "Alimentação",
    icon: "shopping-basket",
    spentMinor: -138050,
    limitMinor: 160000
  }, {
    category: "Transporte",
    icon: "bus",
    spentMinor: -42300,
    limitMinor: 40000
  }, {
    category: "Lazer",
    icon: "clapperboard",
    spentMinor: -24990,
    limitMinor: 50000
  }, {
    category: "Saúde",
    icon: "heart-pulse",
    spentMinor: -31600,
    limitMinor: 45000
  }],
  transactions: [{
    id: "t1",
    date: "1 set 2026",
    title: "Salário",
    category: "Renda",
    account: "Conta corrente",
    minor: 920000,
    kind: "income",
    status: ["Compensado", "success", "check"],
    icon: "banknote"
  }, {
    id: "t2",
    date: "1 set 2026",
    title: "Mercado do bairro",
    category: "Alimentação",
    account: "Cartão Ouro",
    minor: -23480,
    kind: "expense",
    installment: "3/12",
    status: ["Previsto", "neutral", "clock"],
    icon: "shopping-basket"
  }, {
    id: "t3",
    date: "2 set 2026",
    title: "Aluguel",
    category: "Moradia",
    account: "Conta corrente",
    minor: -320000,
    kind: "expense",
    status: ["Compensado", "success", "check"],
    icon: "house"
  }, {
    id: "t4",
    date: "2 set 2026",
    title: "Assinatura streaming",
    category: "Lazer",
    account: "Cartão Ouro",
    minor: -4990,
    kind: "expense",
    status: ["Pendente", "neutral", "clock"],
    icon: "clapperboard"
  }, {
    id: "t5",
    date: "3 set 2026",
    title: "Transferência para Reserva",
    category: "Transferência",
    account: "Conta corrente → Poupança",
    minor: -150000,
    kind: "transfer",
    status: ["Conciliado", "info", "link"],
    icon: "arrow-left-right"
  }, {
    id: "t6",
    date: "4 set 2026",
    title: "Combustível",
    category: "Transporte",
    account: "Cartão Ouro",
    minor: -28900,
    kind: "expense",
    status: ["Previsto", "neutral", "clock"],
    icon: "fuel"
  }, {
    id: "t7",
    date: "5 set 2026",
    title: "Farmácia",
    category: "Saúde",
    account: "Débito",
    minor: -8760,
    kind: "expense",
    status: ["Compensado", "success", "check"],
    icon: "pill"
  }, {
    id: "t8",
    date: "5 set 2026",
    title: "Pagamento fatura agosto",
    category: "Cartão",
    account: "Cartão Ouro",
    minor: -150000,
    kind: "cardPayment",
    status: ["Compensado", "success", "check"],
    icon: "credit-card"
  }, {
    id: "t9",
    date: "6 set 2026",
    title: "Freelance — projeto Vega",
    category: "Renda",
    account: "Conta corrente",
    minor: 132000,
    kind: "income",
    status: ["Previsto", "neutral", "clock"],
    icon: "briefcase"
  }, {
    id: "t10",
    date: "7 set 2026",
    title: "Restaurante Yuki",
    category: "Alimentação",
    account: "Cartão Ouro",
    minor: -14200,
    kind: "expense",
    status: ["Conflito", "danger", "triangle-alert"],
    icon: "utensils"
  }],
  statementPurchases: [{
    day: "5 set 2026",
    items: [{
      id: "p1",
      title: "Mercado do bairro",
      category: "Alimentação",
      minor: -23480,
      installment: "3/12",
      icon: "shopping-basket"
    }, {
      id: "p2",
      title: "Combustível",
      category: "Transporte",
      minor: -28900,
      icon: "fuel"
    }]
  }, {
    day: "3 set 2026",
    items: [{
      id: "p3",
      title: "Restaurante Yuki",
      category: "Alimentação",
      minor: -14200,
      icon: "utensils"
    }, {
      id: "p4",
      title: "Livraria Central",
      category: "Educação",
      minor: -8990,
      installment: "1/3",
      icon: "book-open"
    }]
  }, {
    day: "1 set 2026",
    items: [{
      id: "p5",
      title: "Assinatura streaming",
      category: "Lazer",
      minor: -4990,
      icon: "clapperboard"
    }, {
      id: "p6",
      title: "Notebook Pro",
      category: "Equipamentos",
      minor: -32083,
      installment: "6/12",
      icon: "laptop"
    }]
  }]
};
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/desktop/data.js", error: String((e && e.message) || e) }); }

// ui_kits/mobile/MobileScreens.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const {
  Button,
  IconButton,
  Icon,
  Card,
  MetricCard,
  StatementSummary,
  BudgetProgress,
  MoneyText,
  PrivacyAmount,
  StatusBadge,
  TransactionTile,
  TrendChart,
  CategoryDonut,
  ProgressMeter,
  Banner,
  BottomSheet,
  Input,
  Select,
  CurrencyInput,
  Switch,
  Checkbox
} = window.PollarDesignSystem_efbbc4;
const D = window.PollarDesktopData;
function AppBar({
  title,
  subtitle,
  left,
  actions
}) {
  return /*#__PURE__*/React.createElement("header", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      minHeight: 56,
      padding: "8px var(--gutter-mobile)",
      background: "var(--surface-canvas)",
      borderBottom: "1px solid var(--border)",
      flex: "none"
    }
  }, left, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      fontWeight: 650,
      letterSpacing: "-0.01em",
      color: "var(--text-primary)",
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, title), subtitle && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, subtitle)), actions);
}
function GroupTitle({
  children,
  action
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      padding: "0 0 8px"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: "var(--text-label)",
      fontWeight: "var(--fw-label)",
      color: "var(--text-secondary)"
    }
  }, children), action);
}

/* ---------- 1. Home ---------- */
function MobileHome({
  priv,
  offline,
  onOpen
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16,
      padding: "16px var(--gutter-mobile) 24px"
    }
  }, offline && /*#__PURE__*/React.createElement(Banner, {
    tone: "warning",
    title: "Offline",
    actions: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "secondary"
    }, "Tentar novamente")
  }, "Suas altera\xE7\xF5es ser\xE3o sincronizadas quando a conex\xE3o voltar."), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Saldo total",
    helper: "4 contas",
    minor: 1873455,
    comparisonMinor: 125455,
    comparisonLabel: "vs. agosto",
    privacyHidden: priv
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(MetricCard, {
    title: "Entradas",
    minor: 1052000,
    size: "standard",
    privacyHidden: priv
  }), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Sa\xEDdas",
    minor: -861000,
    size: "standard",
    privacyHidden: priv
  })), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(GroupTitle, null, "Evolu\xE7\xE3o do saldo"), /*#__PURE__*/React.createElement(TrendChart, {
    data: D.trend,
    height: 116
  })), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(GroupTitle, {
    action: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "ghost",
      iconRight: "arrow-right",
      onClick: () => onOpen("cards")
    }, "Ver")
  }, "Fatura aberta"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      width: 40,
      height: 40,
      flex: "none",
      borderRadius: "var(--radius-md)",
      background: "var(--primary-soft)",
      color: "var(--primary)"
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: "credit-card",
    size: 20
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      fontWeight: 600,
      color: "var(--text-primary)"
    }
  }, "Cart\xE3o Ouro"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: "var(--text-caption)",
      color: "var(--text-muted)"
    }
  }, "Vence 10 out 2026")), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      alignItems: "flex-end",
      gap: 4
    }
  }, /*#__PURE__*/React.createElement(PrivacyAmount, {
    minor: -262390,
    hidden: priv
  }), /*#__PURE__*/React.createElement(StatusBadge, {
    tone: "warning",
    icon: "clock",
    size: "compact"
  }, "Parcialmente paga"))), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 14
    }
  }, /*#__PURE__*/React.createElement(ProgressMeter, {
    label: "Limite utilizado",
    value: 52,
    valueLabel: "52%"
  }))), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(GroupTitle, {
    action: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "ghost",
      iconRight: "arrow-right",
      onClick: () => onOpen("budgets")
    }, "Ver")
  }, "Or\xE7amentos"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16
    }
  }, D.budgets.slice(0, 2).map(b => /*#__PURE__*/React.createElement(BudgetProgress, _extends({
    key: b.category
  }, b))))), /*#__PURE__*/React.createElement(Card, {
    padding: "none"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "16px 16px 8px"
    }
  }, /*#__PURE__*/React.createElement(GroupTitle, {
    action: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "ghost",
      iconRight: "arrow-right",
      onClick: () => onOpen("tx")
    }, "Tudo")
  }, "Transa\xE7\xF5es recentes")), /*#__PURE__*/React.createElement("div", {
    style: {
      borderTop: "1px solid var(--border)"
    }
  }, D.transactions.slice(0, 4).map(t => /*#__PURE__*/React.createElement(TransactionTile, {
    key: t.id,
    title: t.title,
    category: t.category,
    account: t.account,
    date: t.date,
    minor: t.minor,
    kind: t.kind,
    installment: t.installment,
    icon: t.icon,
    status: t.status[0],
    statusTone: t.status[1],
    statusIcon: t.status[2],
    privacyHidden: priv,
    onClick: () => onOpen("tx")
  })))));
}

/* ---------- 2. Transactions list ---------- */
function MobileTransactions({
  priv,
  onSelect
}) {
  const [filter, setFilter] = React.useState("Todas");
  const chips = ["Todas", "Saídas", "Entradas", "Previstas"];
  const rows = D.transactions.filter(t => filter === "Todas" ? true : filter === "Saídas" ? t.minor < 0 : filter === "Entradas" ? t.minor > 0 : t.status[0] === "Previsto");
  const byDay = rows.reduce((acc, t) => {
    (acc[t.date] = acc[t.date] || []).push(t);
    return acc;
  }, {});
  return /*#__PURE__*/React.createElement("div", null, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      padding: "12px var(--gutter-mobile)",
      overflowX: "auto",
      background: "var(--surface-canvas)",
      borderBottom: "1px solid var(--border)"
    }
  }, chips.map(c => /*#__PURE__*/React.createElement("button", {
    key: c,
    type: "button",
    onClick: () => setFilter(c),
    style: {
      flex: "none",
      height: 32,
      padding: "0 12px",
      borderRadius: "var(--radius-pill)",
      cursor: "pointer",
      border: "1px solid " + (filter === c ? "var(--primary)" : "var(--border)"),
      background: filter === c ? "var(--primary-soft)" : "var(--surface-canvas)",
      color: filter === c ? "var(--primary)" : "var(--text-secondary)",
      font: "inherit",
      fontSize: 13,
      fontWeight: 600
    }
  }, c))), Object.entries(byDay).map(([day, items]) => /*#__PURE__*/React.createElement("div", {
    key: day
  }, /*#__PURE__*/React.createElement("div", {
    className: "fin-tnum",
    style: {
      display: "flex",
      alignItems: "center",
      gap: 8,
      padding: "8px var(--gutter-mobile)",
      background: "var(--surface-background)",
      fontSize: 12,
      fontWeight: 600,
      color: "var(--text-secondary)"
    }
  }, day, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement(MoneyText, {
    minor: items.reduce((a, i) => a + i.minor, 0),
    size: "compact",
    style: {
      fontSize: 12
    }
  })), items.map(t => /*#__PURE__*/React.createElement(TransactionTile, {
    key: t.id,
    title: t.title,
    category: t.category,
    account: t.account,
    minor: t.minor,
    kind: t.kind,
    installment: t.installment,
    icon: t.icon,
    status: t.status[0],
    statusTone: t.status[1],
    statusIcon: t.status[2],
    privacyHidden: priv,
    onClick: () => onSelect(t)
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "20px var(--gutter-mobile) 32px",
      textAlign: "center",
      fontSize: 13,
      color: "var(--text-muted)"
    }
  }, "128 transa\xE7\xF5es em setembro"));
}

/* ---------- 3. Statement ---------- */
function MobileStatement({
  priv,
  onPay
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16,
      padding: "16px var(--gutter-mobile) 24px"
    }
  }, /*#__PURE__*/React.createElement(StatementSummary, {
    cardName: "Cart\xE3o Ouro",
    brand: "Visa",
    last4: "4417",
    period: "1\u201330 set 2026",
    status: "Parcialmente paga",
    statusTone: "warning",
    statusIcon: "clock",
    totalMinor: -412390,
    paidMinor: -150000,
    dueDate: "10 out 2026",
    limitMinor: 800000,
    actions: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      onClick: onPay
    }, "Pagar fatura")
  }), /*#__PURE__*/React.createElement(Card, {
    padding: "none"
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "16px 16px 8px"
    }
  }, /*#__PURE__*/React.createElement(GroupTitle, null, "Compras da fatura")), D.statementPurchases.map(g => /*#__PURE__*/React.createElement("div", {
    key: g.day
  }, /*#__PURE__*/React.createElement("div", {
    className: "fin-tnum",
    style: {
      display: "flex",
      padding: "8px 16px",
      background: "var(--surface-alt)",
      borderTop: "1px solid var(--border)",
      borderBottom: "1px solid var(--border)",
      fontSize: 12,
      fontWeight: 600,
      color: "var(--text-secondary)"
    }
  }, g.day, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement(MoneyText, {
    minor: g.items.reduce((a, i) => a + i.minor, 0),
    size: "compact",
    style: {
      fontSize: 12
    }
  })), g.items.map(i => /*#__PURE__*/React.createElement(TransactionTile, {
    key: i.id,
    title: i.title,
    category: i.category,
    account: "Cart\xE3o Ouro",
    minor: i.minor,
    installment: i.installment,
    icon: i.icon,
    privacyHidden: priv,
    onClick: () => {}
  }))))), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(GroupTitle, null, "Parcelas futuras"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 12
    }
  }, [["Notebook Pro", "6/12", -32083], ["Mercado do bairro", "3/12", -23480], ["Livraria Central", "1/3", -8990]].map(([t, i, v]) => /*#__PURE__*/React.createElement("div", {
    key: t,
    style: {
      display: "flex",
      alignItems: "center",
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      fontSize: 14,
      color: "var(--text-primary)",
      overflow: "hidden",
      textOverflow: "ellipsis",
      whiteSpace: "nowrap"
    }
  }, t), /*#__PURE__*/React.createElement("span", {
    className: "fin-tnum",
    style: {
      fontSize: 12,
      fontWeight: 600,
      color: "var(--text-muted)",
      background: "var(--surface-alt)",
      borderRadius: "var(--radius-sm)",
      padding: "1px 6px"
    }
  }, i), /*#__PURE__*/React.createElement(MoneyText, {
    minor: v,
    size: "compact"
  }))))));
}

/* ---------- 4. Budgets ---------- */
function MobileBudgets({
  priv
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16,
      padding: "16px var(--gutter-mobile) 24px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "grid",
      gridTemplateColumns: "1fr 1fr",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(MetricCard, {
    title: "Or\xE7ado",
    minor: 295000,
    size: "standard",
    privacyHidden: priv
  }), /*#__PURE__*/React.createElement(MetricCard, {
    title: "Gasto",
    minor: -236940,
    size: "standard",
    privacyHidden: priv
  })), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(GroupTitle, null, "Por categoria"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 20
    }
  }, D.budgets.map(b => /*#__PURE__*/React.createElement(BudgetProgress, _extends({
    key: b.category
  }, b))))), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement(GroupTitle, null, "Composi\xE7\xE3o das sa\xEDdas"), /*#__PURE__*/React.createElement(CategoryDonut, {
    size: 104,
    thickness: 14,
    centerLabel: "Sa\xEDdas",
    centerValue: "R$ 8.610,00",
    slices: D.categories
  })));
}

/* ---------- 5. Transaction detail (full page) ---------- */
function MobileDetail({
  tx,
  priv
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16,
      padding: "16px var(--gutter-mobile) 24px"
    }
  }, /*#__PURE__*/React.createElement(Card, {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 10,
      alignItems: "flex-start"
    }
  }, /*#__PURE__*/React.createElement(PrivacyAmount, {
    minor: tx.minor,
    hidden: priv,
    size: "hero"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 15,
      color: "var(--text-secondary)"
    }
  }, tx.title), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 8,
      flexWrap: "wrap"
    }
  }, /*#__PURE__*/React.createElement(StatusBadge, {
    tone: tx.status[1],
    icon: tx.status[2]
  }, tx.status[0]), tx.installment && /*#__PURE__*/React.createElement(StatusBadge, {
    icon: "layers"
  }, "Parcela ", tx.installment.replace("/", " de ")))), /*#__PURE__*/React.createElement(Card, null, /*#__PURE__*/React.createElement("dl", {
    style: {
      margin: 0,
      display: "grid",
      gridTemplateColumns: "112px 1fr",
      rowGap: 12,
      columnGap: 12,
      fontSize: 14
    }
  }, [["Data", tx.date], ["Categoria", tx.category], ["Conta", tx.account], ["Tipo", {
    income: "Entrada",
    expense: "Saída",
    transfer: "Transferência",
    cardPayment: "Pagamento de fatura"
  }[tx.kind]], ["Identificador", tx.id.toUpperCase() + "-2026-09"]].map(([k, v]) => /*#__PURE__*/React.createElement(React.Fragment, {
    key: k
  }, /*#__PURE__*/React.createElement("dt", {
    style: {
      color: "var(--text-muted)"
    }
  }, k), /*#__PURE__*/React.createElement("dd", {
    style: {
      margin: 0,
      color: "var(--text-primary)"
    }
  }, v))))), tx.status[0] === "Conflito" && /*#__PURE__*/React.createElement(Banner, {
    tone: "danger",
    title: "Conflito de sincroniza\xE7\xE3o",
    actions: /*#__PURE__*/React.createElement(Button, {
      size: "compact",
      variant: "secondary"
    }, "Revisar vers\xF5es")
  }, "Esta transa\xE7\xE3o foi editada em dois dispositivos. Escolha qual vers\xE3o manter."), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 10
    }
  }, /*#__PURE__*/React.createElement(Button, {
    size: "prominent",
    fullWidth: true,
    iconLeft: "pencil"
  }, "Editar transa\xE7\xE3o"), /*#__PURE__*/React.createElement(Button, {
    size: "prominent",
    fullWidth: true,
    variant: "secondary",
    iconLeft: "copy"
  }, "Duplicar"), /*#__PURE__*/React.createElement(Button, {
    size: "prominent",
    fullWidth: true,
    variant: "danger",
    iconLeft: "trash-2"
  }, "Excluir transa\xE7\xE3o")));
}

/* ---------- 6. More / settings ---------- */
function MobileMore({
  priv,
  setPriv,
  theme,
  setTheme
}) {
  const rows = [["Contas e cartões", "wallet"], ["Categorias", "tags"], ["Metas", "target"], ["Exportar dados", "download"], ["Ajuda", "circle-help"]];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 16,
      padding: "16px var(--gutter-mobile) 24px"
    }
  }, /*#__PURE__*/React.createElement(Card, {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 18
    }
  }, /*#__PURE__*/React.createElement(GroupTitle, null, "Prefer\xEAncias"), /*#__PURE__*/React.createElement(Switch, {
    label: "Modo privacidade",
    description: "Oculta valores em todas as telas",
    checked: priv,
    onChange: () => setPriv(!priv)
  }), /*#__PURE__*/React.createElement(Switch, {
    label: "Tema escuro",
    checked: theme === "dark",
    onChange: () => setTheme(theme === "dark" ? "light" : "dark")
  }), /*#__PURE__*/React.createElement(Switch, {
    label: "Reduzir anima\xE7\xF5es"
  })), /*#__PURE__*/React.createElement(Card, {
    padding: "none"
  }, rows.map(([label, icon], i) => /*#__PURE__*/React.createElement("button", {
    key: label,
    type: "button",
    style: {
      display: "flex",
      alignItems: "center",
      gap: 12,
      width: "100%",
      minHeight: 52,
      padding: "0 16px",
      background: "none",
      border: "none",
      borderTop: i ? "1px solid var(--border)" : "none",
      font: "inherit",
      fontSize: 15,
      color: "var(--text-primary)",
      cursor: "pointer",
      textAlign: "left"
    }
  }, /*#__PURE__*/React.createElement(Icon, {
    name: icon,
    size: 20,
    color: "var(--text-secondary)"
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }, label), /*#__PURE__*/React.createElement(Icon, {
    name: "chevron-right",
    size: 18,
    color: "var(--text-muted)"
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: "center",
      fontSize: 12,
      color: "var(--text-muted)"
    }
  }, "Pollar \xB7 vers\xE3o de demonstra\xE7\xE3o"));
}
Object.assign(window, {
  FinAppBar: AppBar,
  MobileHome,
  MobileTransactions,
  MobileStatement,
  MobileBudgets,
  MobileDetail,
  MobileMore
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/MobileScreens.jsx", error: String((e && e.message) || e) }); }

__ds_ns.CategoryDonut = __ds_scope.CategoryDonut;

__ds_ns.ComparisonBars = __ds_scope.ComparisonBars;

__ds_ns.ProgressMeter = __ds_scope.ProgressMeter;

__ds_ns.TrendChart = __ds_scope.TrendChart;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.DataTable = __ds_scope.DataTable;

__ds_ns.MoneyText = __ds_scope.MoneyText;

__ds_ns.PrivacyAmount = __ds_scope.PrivacyAmount;

__ds_ns.StatusBadge = __ds_scope.StatusBadge;

__ds_ns.TransactionTile = __ds_scope.TransactionTile;

__ds_ns.Banner = __ds_scope.Banner;

__ds_ns.BottomSheet = __ds_scope.BottomSheet;

__ds_ns.Dialog = __ds_scope.Dialog;

__ds_ns.Toast = __ds_scope.Toast;

__ds_ns.Checkbox = __ds_scope.Checkbox;

__ds_ns.CurrencyInput = __ds_scope.CurrencyInput;

__ds_ns.Input = __ds_scope.Input;

__ds_ns.Select = __ds_scope.Select;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.BottomNav = __ds_scope.BottomNav;

__ds_ns.Sidebar = __ds_scope.Sidebar;

__ds_ns.TopBar = __ds_scope.TopBar;

__ds_ns.BudgetProgress = __ds_scope.BudgetProgress;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.MetricCard = __ds_scope.MetricCard;

__ds_ns.StatementSummary = __ds_scope.StatementSummary;

})();

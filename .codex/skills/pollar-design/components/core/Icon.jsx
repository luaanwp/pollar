import React from "react";

/* Lucide (rounded-outline family, per spec §7) delivered from the lucide-static CDN
   and tinted with currentColor via a CSS mask, so a single wrapper covers all glyphs. */
const CDN = "https://unpkg.com/lucide-static@0.462.0/icons/";

export function Icon({ name, size = 20, strokeWidth, color = "currentColor", label, style, ...rest }) {
  const url = `url("${CDN}${name}.svg")`;
  return (
    <span
      role={label ? "img" : "presentation"}
      aria-label={label}
      aria-hidden={label ? undefined : true}
      title={label}
      style={{
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
        ...style,
      }}
      {...rest}
    />
  );
}

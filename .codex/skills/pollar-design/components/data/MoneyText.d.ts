import * as React from "react";

/**
 * Renders an exact monetary amount with tabular numerals and a true minus sign.
 * @startingPoint section="Data" subtitle="Hero, standard and compact money amounts" viewport="700x150"
 */
export interface MoneyTextProps extends Omit<React.HTMLAttributes<HTMLSpanElement>, "style"> {
  /** Amount in integer minor units (cents). */
  minor: number;
  size?: "hero" | "standard" | "compact";
  /** Override the derived polarity (affects the screen-reader label and semantic tone). */
  polarity?: "auto" | "positive" | "negative" | "neutral";
  locale?: string;
  currency?: string;
  /** Render "+" for positive values where comparison matters. */
  showSign?: boolean;
  /** "semantic" colors by polarity; "muted" for metadata. Omit for neutral transaction rows. */
  tone?: "semantic" | "muted";
  style?: React.CSSProperties;
}

export declare function MoneyText(props: MoneyTextProps): React.ReactElement;

import * as React from "react";

export interface PrivacyAmountProps extends Omit<React.HTMLAttributes<HTMLSpanElement>, "style"> {
  minor: number;
  /** When true, renders "R$ ••••••" while preserving approximate layout width. */
  hidden?: boolean;
  size?: "hero" | "standard" | "compact";
  currency?: string;
  locale?: string;
  maskDigits?: number;
  style?: React.CSSProperties;
}

export declare function PrivacyAmount(props: PrivacyAmountProps): React.ReactElement;

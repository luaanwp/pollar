import * as React from "react";

export interface IconProps extends React.HTMLAttributes<HTMLSpanElement> {
  /** Lucide icon name in kebab-case, e.g. "arrow-up-right", "wallet". */
  name: string;
  /** 16 | 20 | 24 are the sanctioned sizes. */
  size?: number;
  /** Any CSS color; defaults to currentColor so the icon inherits text color. */
  color?: string;
  /** Accessible label. Omit for decorative icons (renders aria-hidden). */
  label?: string;
}

export declare function Icon(props: IconProps): React.ReactElement;

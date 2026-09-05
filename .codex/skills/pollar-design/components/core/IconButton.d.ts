import * as React from "react";

export interface IconButtonProps extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, "style"> {
  /** Lucide icon name. */
  icon: string;
  /** Required — becomes both the tooltip and the accessible name. */
  label: string;
  size?: "compact" | "standard" | "prominent";
  variant?: "ghost" | "outline";
  selected?: boolean;
  disabled?: boolean;
  style?: React.CSSProperties;
}

export declare function IconButton(props: IconButtonProps): React.ReactElement;

import * as React from "react";

/**
 * Pollar action button. Primary is reserved for the single main action in a region.
 * @startingPoint section="Core" subtitle="Primary, secondary, ghost and danger actions" viewport="700x150"
 */
export interface ButtonProps extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, "style"> {
  variant?: "primary" | "secondary" | "ghost" | "danger";
  /** compact = 32px dense desktop, standard = 40px, prominent = 48px mobile. */
  size?: "compact" | "standard" | "prominent";
  /** Lucide icon name placed before the label. */
  iconLeft?: string;
  /** Lucide icon name placed after the label. */
  iconRight?: string;
  loading?: boolean;
  disabled?: boolean;
  fullWidth?: boolean;
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function Button(props: ButtonProps): React.ReactElement;

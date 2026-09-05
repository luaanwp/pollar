import * as React from "react";

/**
 * Pill-shaped status label. Status is never communicated by color alone — always a text label, optionally a leading icon.
 * @startingPoint section="Data" subtitle="Neutral, info, success, warning and danger statuses" viewport="700x150"
 */
export interface StatusBadgeProps extends Omit<React.HTMLAttributes<HTMLSpanElement>, "style"> {
  tone?: "neutral" | "info" | "success" | "warning" | "danger";
  /** Leading Lucide icon — recommended, it is the non-color status cue. */
  icon?: string;
  size?: "compact" | "standard";
  children: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function StatusBadge(props: StatusBadgeProps): React.ReactElement;

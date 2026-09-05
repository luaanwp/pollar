import * as React from "react";

/**
 * Dashboard metric card: title, optional helper/action, primary amount, supporting comparison, optional compact visualization.
 * @startingPoint section="Surfaces" subtitle="Dashboard metric with comparison" viewport="700x200"
 */
export interface MetricCardProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style"> {
  title: string;
  helper?: string;
  /** Usually an IconButton or a ghost Button. */
  action?: React.ReactNode;
  /** Primary metric in integer minor units. */
  minor: number;
  size?: "hero" | "standard";
  /** Delta vs. the previous period, in minor units. */
  comparisonMinor?: number;
  comparisonLabel?: string;
  privacyHidden?: boolean;
  /** Optional compact chart slot. */
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function MetricCard(props: MetricCardProps): React.ReactElement;

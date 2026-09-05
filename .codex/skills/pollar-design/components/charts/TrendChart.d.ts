import * as React from "react";

export interface TrendPoint { label: string; value: number }

/**
 * Line/area chart for cash flow or balance over time, with a visible zero baseline and a text alternative.
 * @startingPoint section="Charts" subtitle="Cash-flow trend line with zero baseline" viewport="700x200"
 */
export interface TrendChartProps extends Omit<React.HTMLAttributes<HTMLElement>, "style"> {
  /** Points in chronological order; values in minor units. */
  data: TrendPoint[];
  height?: number;
  /** Stroke color, default --chart-1. */
  tone?: string;
  showArea?: boolean;
  valueFormatter?: (value: number) => string;
  style?: React.CSSProperties;
}

export declare function TrendChart(props: TrendChartProps): React.ReactElement;

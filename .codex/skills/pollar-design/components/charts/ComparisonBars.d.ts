import * as React from "react";

export interface BarSeries { label: string; color: string }
export interface BarGroup { label: string; values: number[] }

export interface ComparisonBarsProps extends Omit<React.HTMLAttributes<HTMLElement>, "style"> {
  /** One entry per x-axis tick; `values` maps positionally onto `series`. */
  groups: BarGroup[];
  series: BarSeries[];
  height?: number;
  valueFormatter?: (value: number) => string;
  showLegend?: boolean;
  style?: React.CSSProperties;
}

export declare function ComparisonBars(props: ComparisonBarsProps): React.ReactElement;

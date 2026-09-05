import * as React from "react";

export interface DonutSlice { label: string; value: number; color?: string }

export interface CategoryDonutProps extends Omit<React.HTMLAttributes<HTMLElement>, "style"> {
  /** Few categories only (≤6). Use sorted bars beyond that. */
  slices: DonutSlice[];
  size?: number;
  thickness?: number;
  centerLabel?: string;
  centerValue?: string;
  valueFormatter?: (value: number) => string;
  style?: React.CSSProperties;
}

export declare function CategoryDonut(props: CategoryDonutProps): React.ReactElement;

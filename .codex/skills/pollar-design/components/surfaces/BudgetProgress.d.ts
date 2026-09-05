import * as React from "react";

export interface BudgetProgressProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style"> {
  category: string;
  /** Lucide category glyph. */
  icon?: string;
  /** Spent amount in minor units (sign ignored). */
  spentMinor?: number;
  /** Budget ceiling in minor units. */
  limitMinor?: number;
  style?: React.CSSProperties;
}

export declare function BudgetProgress(props: BudgetProgressProps): React.ReactElement;

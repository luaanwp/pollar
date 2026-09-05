import * as React from "react";

export interface ProgressMeterProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style"> {
  /** 0–100. */
  value: number;
  label?: string;
  /** Exact value shown as text — required whenever the meter carries meaning. */
  valueLabel?: string;
  tone?: "primary" | "success" | "warning" | "danger" | "info";
  height?: number;
  style?: React.CSSProperties;
}

export declare function ProgressMeter(props: ProgressMeterProps): React.ReactElement;

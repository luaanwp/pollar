import * as React from "react";

export interface SelectOption { value: string; label: string }

export interface SelectProps extends Omit<React.SelectHTMLAttributes<HTMLSelectElement>, "size" | "style" | "children"> {
  label?: string;
  hint?: string;
  error?: string;
  options?: Array<string | SelectOption>;
  size?: "compact" | "standard" | "prominent";
  disabled?: boolean;
  style?: React.CSSProperties;
}

export declare function Select(props: SelectProps): React.ReactElement;

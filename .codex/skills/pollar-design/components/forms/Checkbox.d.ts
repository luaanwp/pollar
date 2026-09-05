import * as React from "react";

export interface CheckboxProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "style" | "type"> {
  label?: React.ReactNode;
  checked?: boolean;
  /** Header state when only some rows are selected. */
  indeterminate?: boolean;
  disabled?: boolean;
  style?: React.CSSProperties;
}

export declare function Checkbox(props: CheckboxProps): React.ReactElement;

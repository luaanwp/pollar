import * as React from "react";

export interface SwitchProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "style" | "type"> {
  label?: string;
  description?: string;
  checked?: boolean;
  disabled?: boolean;
  style?: React.CSSProperties;
}

export declare function Switch(props: SwitchProps): React.ReactElement;

import * as React from "react";

/**
 * Labeled text field. Labels stay visible above the control; placeholders are examples only.
 * @startingPoint section="Forms" subtitle="Text field with label, hint and error states" viewport="700x180"
 */
export interface InputProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "size" | "style"> {
  /** Always supply a visible label. */
  label?: string;
  /** Helper text below the field. */
  hint?: string;
  /** Error message — states what happened and how to fix it. */
  error?: string;
  /** Success message. */
  success?: string;
  /** Static text before the value, e.g. "R$". */
  prefix?: string;
  /** Static text after the value, e.g. "%". */
  suffix?: string;
  /** Lucide icon name rendered inside the field. */
  iconLeft?: string;
  size?: "compact" | "standard" | "prominent";
  /** Right-align amounts in dense desktop forms. */
  align?: "left" | "right";
  readOnly?: boolean;
  disabled?: boolean;
  style?: React.CSSProperties;
}

export declare function Input(props: InputProps): React.ReactElement;

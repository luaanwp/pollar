import * as React from "react";

export interface CurrencyInputProps {
  label?: string;
  /** Amount in integer minor units (cents). Never pass a float. */
  valueMinor?: number;
  /** Called with the new integer minor-unit value. */
  onChangeMinor?: (minor: number) => void;
  /** Locale-aware symbol, default "R$". */
  currencySymbol?: string;
  /** BCP-47 locale, default "pt-BR". */
  locale?: string;
  hint?: string;
  error?: string;
  /** When > 1, renders a textual installment preview ("12x de R$ 102,88"). */
  installments?: number;
  size?: "compact" | "standard" | "prominent";
  align?: "left" | "right";
}

export declare function CurrencyInput(props: CurrencyInputProps): React.ReactElement;

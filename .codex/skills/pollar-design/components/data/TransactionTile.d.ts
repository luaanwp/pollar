import * as React from "react";

/**
 * Transaction row: icon/category, payee, metadata, date/status, amount, optional installment label.
 * @startingPoint section="Data" subtitle="Transaction row with amount, status and installment" viewport="700x220"
 */
export interface TransactionTileProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style"> {
  title: string;
  category?: string;
  account?: string;
  /** Pre-formatted short date, e.g. "1 set 2026". */
  date?: string;
  /** Amount in integer minor units; negative for expenses. */
  minor: number;
  kind?: "expense" | "income" | "transfer" | "cardPayment";
  /** Compact installment label, e.g. "3/12". */
  installment?: string;
  status?: string;
  statusTone?: "neutral" | "info" | "success" | "warning" | "danger";
  statusIcon?: string;
  /** Override the kind's default Lucide icon with a category glyph. */
  icon?: string;
  privacyHidden?: boolean;
  selected?: boolean;
  style?: React.CSSProperties;
}

export declare function TransactionTile(props: TransactionTileProps): React.ReactElement;

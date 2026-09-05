import * as React from "react";

/**
 * Credit-card statement header: card identity, period, status, total/paid/outstanding, due date, actions and utilization.
 * @startingPoint section="Surfaces" subtitle="Credit-card statement summary" viewport="700x330"
 */
export interface StatementSummaryProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style"> {
  cardName: string;
  brand?: string;
  last4?: string;
  /** Pre-formatted statement period, e.g. "1–30 set 2026". */
  period?: string;
  status?: string;
  statusTone?: "neutral" | "info" | "success" | "warning" | "danger";
  statusIcon?: string;
  totalMinor?: number;
  paidMinor?: number;
  /** Pre-formatted due date, e.g. "10 out 2026". */
  dueDate?: string;
  /** Credit limit in minor units — enables the utilization meter. */
  limitMinor?: number;
  /** Pay / partial-payment buttons. */
  actions?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function StatementSummary(props: StatementSummaryProps): React.ReactElement;

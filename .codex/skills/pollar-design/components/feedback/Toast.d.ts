import * as React from "react";

export interface ToastProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style"> {
  tone?: "success" | "info" | "warning";
  message: string;
  /** Usually "Desfazer" — prefer undo for reversible operations. */
  actionLabel?: string;
  onAction?: () => void;
  onDismiss?: () => void;
  style?: React.CSSProperties;
}

export declare function Toast(props: ToastProps): React.ReactElement;

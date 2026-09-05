import * as React from "react";

/**
 * Focused desktop decision surface. Destructive confirmations must name the object and explain impact.
 * @startingPoint section="Feedback" subtitle="Confirmation dialog with destructive variant" viewport="700x300"
 */
export interface DialogProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style" | "title"> {
  open?: boolean;
  title?: string;
  description?: string;
  tone?: "default" | "danger";
  icon?: string;
  children?: React.ReactNode;
  /** Buttons, most-destructive last and explicitly labeled. */
  actions?: React.ReactNode;
  onClose?: () => void;
  width?: number;
  /** Render the panel without the fixed overlay — for specimen cards. */
  inline?: boolean;
  style?: React.CSSProperties;
}

export declare function Dialog(props: DialogProps): React.ReactElement | null;

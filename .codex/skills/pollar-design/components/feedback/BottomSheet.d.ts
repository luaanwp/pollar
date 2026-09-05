import * as React from "react";

export interface BottomSheetProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style" | "title"> {
  open?: boolean;
  title?: string;
  children?: React.ReactNode;
  /** Full-width stacked buttons (48px prominent). */
  actions?: React.ReactNode;
  onClose?: () => void;
  /** Render without the fixed overlay — for specimen cards. */
  inline?: boolean;
  style?: React.CSSProperties;
}

export declare function BottomSheet(props: BottomSheetProps): React.ReactElement | null;

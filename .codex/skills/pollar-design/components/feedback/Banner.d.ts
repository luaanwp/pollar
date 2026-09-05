import * as React from "react";

/**
 * Persistent inline banner for offline state, sync errors, conflicts and information that stays relevant.
 * @startingPoint section="Feedback" subtitle="Offline, sync-error and conflict banners" viewport="700x200"
 */
export interface BannerProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style" | "title"> {
  tone?: "info" | "success" | "warning" | "danger" | "neutral";
  title?: string;
  /** Body copy — say what happened and what to do next. */
  children?: React.ReactNode;
  /** Override the tone's default Lucide icon. */
  icon?: string;
  /** Recovery actions — required for danger/conflict banners. */
  actions?: React.ReactNode;
  onDismiss?: () => void;
  style?: React.CSSProperties;
}

export declare function Banner(props: BannerProps): React.ReactElement;

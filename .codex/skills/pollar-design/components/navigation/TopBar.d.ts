import * as React from "react";

export interface TopBarProps extends Omit<React.HTMLAttributes<HTMLElement>, "style" | "title"> {
  title?: string;
  subtitle?: string;
  breadcrumb?: string;
  search?: boolean;
  searchPlaceholder?: string;
  /** Utility controls — privacy toggle, notifications, quick add, avatar. */
  actions?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function TopBar(props: TopBarProps): React.ReactElement;

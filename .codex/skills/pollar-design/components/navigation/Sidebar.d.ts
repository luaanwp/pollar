import * as React from "react";

export interface SidebarItem {
  id?: string;
  label?: string;
  /** Lucide icon name (20px in the sidebar). */
  icon?: string;
  badge?: string | number;
  /** Set instead of id/label to render an uppercase section divider. */
  section?: string;
}

/**
 * Desktop navigation sidebar — 256px expanded, 72px collapsed.
 * @startingPoint section="Navigation" subtitle="Desktop sidebar, expanded and collapsed" viewport="700x420"
 */
export interface SidebarProps extends Omit<React.HTMLAttributes<HTMLElement>, "style"> {
  items: SidebarItem[];
  activeId?: string;
  onSelect?: (id: string) => void;
  collapsed?: boolean;
  brand?: string;
  footer?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function Sidebar(props: SidebarProps): React.ReactElement;

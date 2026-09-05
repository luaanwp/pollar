import * as React from "react";

export interface BottomNavItem { id: string; label: string; icon: string }

/**
 * Mobile bottom navigation — at most five destinations, 24px icons, 44px minimum targets.
 * @startingPoint section="Navigation" subtitle="Mobile bottom nav with quick-add action" viewport="390x120"
 */
export interface BottomNavProps extends Omit<React.HTMLAttributes<HTMLElement>, "style"> {
  items: BottomNavItem[];
  activeId?: string;
  onSelect?: (id: string) => void;
  /** Label for the floating quick-add action; omit to hide it. */
  quickAdd?: string | boolean;
  onQuickAdd?: () => void;
  style?: React.CSSProperties;
}

export declare function BottomNav(props: BottomNavProps): React.ReactElement;

import * as React from "react";

export interface DataTableColumn {
  key: string;
  label: string;
  /** CSS grid track, e.g. "1fr" | "120px". */
  width?: string;
  /** Amounts are right-aligned and rendered with tabular numerals. */
  align?: "left" | "right";
  sortable?: boolean;
  render?: (row: any) => React.ReactNode;
}

/**
 * Dense desktop table with sorting, row selection, sticky header and a click-through detail row.
 * @startingPoint section="Data" subtitle="Sortable, selectable transaction table" viewport="700x260"
 */
export interface DataTableProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style"> {
  columns: DataTableColumn[];
  rows: Array<{ id: string | number } & Record<string, any>>;
  selectable?: boolean;
  selectedIds?: Array<string | number>;
  onToggleRow?: (id: string | number) => void;
  onToggleAll?: () => void;
  sortKey?: string;
  sortDir?: "asc" | "desc";
  onSort?: (key: string) => void;
  onRowClick?: (row: any) => void;
  activeId?: string | number;
  stickyHeader?: boolean;
  emptyLabel?: string;
  style?: React.CSSProperties;
}

export declare function DataTable(props: DataTableProps): React.ReactElement;

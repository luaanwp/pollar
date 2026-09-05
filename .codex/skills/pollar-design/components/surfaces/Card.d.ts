import * as React from "react";

export interface CardProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "style"> {
  padding?: "none" | "sm" | "md" | "lg";
  /** Adds a hover elevation for clickable cards. */
  interactive?: boolean;
  tone?: "canvas" | "alt";
  children?: React.ReactNode;
  style?: React.CSSProperties;
}

export declare function Card(props: CardProps): React.ReactElement;

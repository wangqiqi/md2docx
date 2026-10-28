import type { ReactNode } from 'react';

type PageShellProps = {
  title: string;
  subtitle?: string;
  children: ReactNode;
};

/** Neutral page shell — extend with your design system. */
export function PageShell({ title, subtitle, children }: PageShellProps) {
  return (
    <section className="page-shell" data-testid="page-shell">
      <header className="page-shell__header">
        <h1 className="page-shell__title">{title}</h1>
        {subtitle ? <p className="page-shell__subtitle">{subtitle}</p> : null}
      </header>
      <div className="page-shell__body">{children}</div>
    </section>
  );
}

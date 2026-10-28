type ListLoadErrorAlertProps = {
  message?: string;
  onRetry?: () => void;
};

/** Distinguish load failure from empty list — wire onRetry to your data hook. */
export function ListLoadErrorAlert({
  message = 'Failed to load',
  onRetry,
}: ListLoadErrorAlertProps) {
  return (
    <div role="alert" className="list-load-error" data-testid="list-load-error">
      <span>{message}</span>
      {onRetry ? (
        <button type="button" onClick={onRetry}>
          Retry
        </button>
      ) : null}
    </div>
  );
}

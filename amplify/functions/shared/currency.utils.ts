/**
 * Standardizes currency formatting to ensure consistency
 * across all backend-generated activity records.
 */
export function formatCurrency(amount: number, currencyCode: string): string {
    // We map code to symbol, then format as string
    const symbol = currencyCode === 'NGN' ? '₦' : currencyCode;

    // Add commas for thousands and 2 decimal places for financial accuracy
    const formattedAmount = amount.toLocaleString('en-NG', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
    });

    return `${symbol} ${formattedAmount}`;
}

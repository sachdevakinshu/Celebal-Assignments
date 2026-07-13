""" Python and SQL Integration: command-line report tool.

Generates a summary report from the SQLite database for a chosen report type
(daily / weekly / monthly) and date range, including a comparison with the
previous period of equal length.

Used only sqlite3 and the stdlib.
"""

import sqlite3
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent.parent / "db" / "ecommerce.db"
REPORT_TYPES = ("daily", "weekly", "monthly")

# Net revenue: quantity * unit_price * (1 - discount%/100); returns subtract.
REVENUE = "oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)"


def parse_date(text: str) -> date:
    """Parse a YYYY-MM-DD string, raising ValueError with a friendly message."""
    try:
        return datetime.strptime(text.strip(), "%Y-%m-%d").date()
    except ValueError:
        raise ValueError(f"'{text}' is not a valid date - expected YYYY-MM-DD") from None


def period_summary(conn, start: date, end: date):
    """Total orders, net revenue and unique customers between start and end
    (end date inclusive)."""
    row = conn.execute(
        f"""
        SELECT COUNT(DISTINCT o.order_id),
               COALESCE(SUM({REVENUE}), 0),
               COUNT(DISTINCT o.customer_id)
        FROM orders o
        LEFT JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.order_date >= ? AND o.order_date < ?
        """,
        (start.isoformat(), (end + timedelta(days=1)).isoformat()),
    ).fetchone()
    return {"orders": row[0], "revenue": row[1], "customers": row[2]}


def top_products(conn, start: date, end: date, limit: int = 3):
    return conn.execute(
        f"""
        SELECT p.product_name,
               SUM(oi.quantity) AS units,
               ROUND(SUM({REVENUE}), 2) AS revenue
        FROM orders o
        JOIN order_items oi ON oi.order_id = o.order_id
        JOIN products p     ON p.product_id = oi.product_id
        WHERE o.order_date >= ? AND o.order_date < ?
        GROUP BY p.product_name
        ORDER BY revenue DESC
        LIMIT ?
        """,
        (start.isoformat(), (end + timedelta(days=1)).isoformat(), limit),
    ).fetchall()


def breakdown(conn, start: date, end: date, report_type: str):
    """Per-bucket (day / ISO week / month) orders and revenue in the range."""
    bucket = {
        "daily": "date(o.order_date)",
        "weekly": "strftime('%Y-W%W', o.order_date)",
        "monthly": "strftime('%Y-%m', o.order_date)",
    }[report_type]
    return conn.execute(
        f"""
        SELECT {bucket} AS bucket,
               COUNT(DISTINCT o.order_id) AS orders,
               ROUND(COALESCE(SUM({REVENUE}), 0), 2) AS revenue
        FROM orders o
        LEFT JOIN order_items oi ON oi.order_id = o.order_id
        WHERE o.order_date >= ? AND o.order_date < ?
        GROUP BY bucket
        ORDER BY bucket
        """,
        (start.isoformat(), (end + timedelta(days=1)).isoformat()),
    ).fetchall()


def pct_change(current, previous):
    """Percentage change vs the previous period; None when undefined."""
    if previous in (0, None):
        return None
    return 100.0 * (current - previous) / previous


def fmt_pct(value):
    if value is None:
        return "n/a (no data in previous period)"
    arrow = "up" if value >= 0 else "down"
    return f"{value:+.1f}% ({arrow})"


def generate_report(conn, report_type: str, start: date, end: date) -> str:
    days = (end - start).days + 1
    prev_end = start - timedelta(days=1)
    prev_start = prev_end - timedelta(days=days - 1)

    cur = period_summary(conn, start, end)
    prev = period_summary(conn, prev_start, prev_end)
    products = top_products(conn, start, end)
    buckets = breakdown(conn, start, end, report_type)

    w = 62
    lines = []
    lines.append("=" * w)
    lines.append(f"{report_type.upper()} SALES REPORT".center(w))
    lines.append(f"{start}  to  {end}   ({days} days)".center(w))
    lines.append("=" * w)
    lines.append("")
    lines.append("SUMMARY")
    lines.append(f"  Total orders     : {cur['orders']:,}")
    lines.append(f"  Net revenue      : {cur['revenue']:,.2f}")
    lines.append(f"  Unique customers : {cur['customers']:,} (guest orders excluded)")
    lines.append("")
    lines.append("TOP 3 PRODUCTS (by revenue)")
    if products:
        for i, (name, units, revenue) in enumerate(products, 1):
            lines.append(f"  {i}. {name:<38} {units:>4} units  {revenue:>12,.2f}")
    else:
        lines.append("  (no sales in this period)")
    lines.append("")
    lines.append(f"VS PREVIOUS PERIOD ({prev_start} to {prev_end})")
    lines.append(f"  Orders    : {prev['orders']:,} -> {cur['orders']:,}   "
                 f"{fmt_pct(pct_change(cur['orders'], prev['orders']))}")
    lines.append(f"  Revenue   : {prev['revenue']:,.2f} -> {cur['revenue']:,.2f}   "
                 f"{fmt_pct(pct_change(cur['revenue'], prev['revenue']))}")
    lines.append(f"  Customers : {prev['customers']:,} -> {cur['customers']:,}   "
                 f"{fmt_pct(pct_change(cur['customers'], prev['customers']))}")
    lines.append("")
    label = {"daily": "DAY", "weekly": "WEEK", "monthly": "MONTH"}[report_type]
    lines.append(f"BREAKDOWN BY {label}")
    lines.append(f"  {'bucket':<12} {'orders':>8} {'revenue':>14}")
    for bucket, orders, revenue in buckets:
        lines.append(f"  {bucket:<12} {orders:>8,} {revenue:>14,.2f}")
    lines.append("=" * w)
    return "\n".join(lines)


def get_inputs(argv):
    """Read report type + date range from argv, falling back to prompts."""
    if len(argv) == 4:
        report_type, start_text, end_text = argv[1].lower(), argv[2], argv[3]
    elif len(argv) == 1:
        print("Report type options: daily, weekly, monthly")
        report_type = input("Report type: ").strip().lower()
        start_text = input("Start date (YYYY-MM-DD): ")
        end_text = input("End date   (YYYY-MM-DD): ")
    else:
        raise ValueError(
            "usage: python report_cli.py [daily|weekly|monthly] [start] [end]\n"
            "       (run with no arguments for interactive mode)"
        )

    if report_type not in REPORT_TYPES:
        raise ValueError(f"unknown report type '{report_type}' - choose from {', '.join(REPORT_TYPES)}")
    start, end = parse_date(start_text), parse_date(end_text)
    if start > end:
        raise ValueError(f"start date {start} is after end date {end}")
    return report_type, start, end


def main(argv):
    if not DB_PATH.exists():
        print(f"error: database not found at {DB_PATH}\n"
              "run notebooks 01-03 first to build it", file=sys.stderr)
        return 1
    try:
        report_type, start, end = get_inputs(argv)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    with sqlite3.connect(DB_PATH) as conn:
        print(generate_report(conn, report_type, start, end))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))

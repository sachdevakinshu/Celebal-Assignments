"""Data cleaning functions for the E-Commerce Order Analytics project (Part 2).

Each function will return the cleaned DataFrame.
It will also give us a dictionary that lists every problem it found.
This way our notebook can put together a report, on the quality of the data.
The dictionary is really important because it helps us see what issues the function found in the E-Commerce Order Analytics project data.
"""

import re

import pandas as pd

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
WRONG_DATE_RE = re.compile(r"^\d{2}-\d{2}-\d{4}")


def clean_orders(orders_df: pd.DataFrame, reference_date=None):
    """Fixing date formats and handle NULL customer_ids.

    - order_date arrives in either ``YYYY-MM-DD HH:MM:SS`` (correct) or
      ``DD-MM-YYYY HH:MM:SS``(wrong); both are parsed and re-emitted in the
      correct format.
    - customer_id values of ``"NULL"`` / empty string are standardized to a
      real missing value (guest orders are kept, not dropped).
    - Orders dated in the future (relative to *reference_date*, default: now)
      are reported and dropped — a future order date is a data error that
      would pollute time-based analyses (running totals, YoY, cohorts).
    """
    df = orders_df.copy()
    df["customer_id"] = df["customer_id"].astype("string")
    df["order_date"] = df["order_date"].astype("string")
    issues = {}

    #customer_id: normalizing "NULL" / "" / whitespace to missing
    null_mask = df["customer_id"].isna() | df["customer_id"].str.strip().isin(["", "NULL", "null"])
    issues["null_customer_ids"] = {
        "count": int(null_mask.sum()),
        "order_ids": df.loc[null_mask, "order_id"].tolist(),
    }
    df.loc[null_mask, "customer_id"] = pd.NA

    #order_date: detect wrong DD-MM-YYYY format, parse both formats
    wrong_mask = df["order_date"].str.match(WRONG_DATE_RE).fillna(False)
    issues["wrong_date_format"] = {
        "count": int(wrong_mask.sum()),
        "order_ids": df.loc[wrong_mask, "order_id"].tolist(),
    }
    parsed = pd.Series(pd.NaT, index=df.index)
    parsed[wrong_mask] = pd.to_datetime(
        df.loc[wrong_mask, "order_date"], format="%d-%m-%Y %H:%M:%S", errors="coerce"
    )
    parsed[~wrong_mask] = pd.to_datetime(
        df.loc[~wrong_mask, "order_date"], format="%Y-%m-%d %H:%M:%S", errors="coerce"
    )
    unparseable = parsed.isna()
    issues["unparseable_dates"] = {
        "count": int(unparseable.sum()),
        "order_ids": df.loc[unparseable, "order_id"].tolist(),
    }
    df = df[~unparseable].copy()
    parsed = parsed[~unparseable]

    #future dates: report and drop
    if reference_date is None:
        reference_date = pd.Timestamp.now()
    future_mask = parsed > pd.Timestamp(reference_date)
    issues["future_dates"] = {
        "count": int(future_mask.sum()),
        "order_ids": df.loc[future_mask, "order_id"].tolist(),
    }
    df = df[~future_mask].copy()
    parsed = parsed[~future_mask]

    df["order_date"] = parsed.dt.strftime("%Y-%m-%d %H:%M:%S")
    return df, issues


def clean_products(products_df: pd.DataFrame):
    """Normalize product names: trim whitespace, collapse internal runs of
    spaces, and apply title case."""
    df = products_df.copy()
    original = df["product_name"].astype("string")
    normalized = (
        original.str.strip()
        .str.replace(r"\s+", " ", regex=True)
        .str.title()
    )
    changed = original != normalized
    issues = {
        "messy_product_names": {
            "count": int(changed.sum()),
            "product_ids": df.loc[changed, "product_id"].tolist(),
        }
    }
    df["product_name"] = normalized
    return df, issues


def validate_emails(customers_df: pd.DataFrame):
    """Return the list of customer_ids whose email is invalid
    (missing @, missing domain, empty, etc.)."""
    emails = customers_df["email"].fillna("").astype(str)
    invalid_mask = ~emails.str.match(EMAIL_RE)
    return customers_df.loc[invalid_mask, "customer_id"].tolist()


def check_referential_integrity(order_items_df: pd.DataFrame, orders_df: pd.DataFrame,
                                products_df: pd.DataFrame | None = None):
    """Find order_items that reference non-existent orders (and, optionally,
    non-existent products). Returns a dict of violations."""
    orphan_orders = order_items_df[~order_items_df["order_id"].isin(orders_df["order_id"])]
    result = {
        "orphan_order_items": {
            "count": len(orphan_orders),
            "item_ids": orphan_orders["item_id"].tolist(),
            "missing_order_ids": sorted(orphan_orders["order_id"].unique().tolist()),
        }
    }
    if products_df is not None:
        orphan_products = order_items_df[
            ~order_items_df["product_id"].isin(products_df["product_id"])
        ]
        result["orphan_product_items"] = {
            "count": len(orphan_products),
            "item_ids": orphan_products["item_id"].tolist(),
        }
    return result


def clean_order_items(order_items_df: pd.DataFrame, orders_df: pd.DataFrame):
    """Clean order_items:

    - drop rows referencing non-existent orders (after reporting them)
    - clamp discount_percent into the valid 0-100 range (report offenders)
    - flag zero-quantity rows (kept: they contribute no revenue)
    - negative quantities are KEPT — they are legitimate returns per the spec
    """
    df = order_items_df.copy()
    issues = {}

    integrity = check_referential_integrity(df, orders_df)
    issues.update(integrity)
    df = df[df["order_id"].isin(orders_df["order_id"])].copy()

    over_mask = df["discount_percent"] > 100
    under_mask = df["discount_percent"] < 0
    issues["discount_out_of_range"] = {
        "count": int((over_mask | under_mask).sum()),
        "item_ids": df.loc[over_mask | under_mask, "item_id"].tolist(),
    }
    df.loc[over_mask, "discount_percent"] = 100
    df.loc[under_mask, "discount_percent"] = 0

    zero_mask = df["quantity"] == 0
    issues["zero_quantity"] = {
        "count": int(zero_mask.sum()),
        "item_ids": df.loc[zero_mask, "item_id"].tolist(),
    }
    issues["negative_quantity_returns"] = {"count": int((df["quantity"] < 0).sum())}

    return df, issues

# Week 7 Assignment - Delta Lake MERGE Implementation

Incremental data processing using **Delta Lake** on **Databricks** - load a customer
dataset into a Delta table, clean it, and `MERGE` an incremental dataset to update
existing records and insert new ones (SCD Type 1).

## How to Run (Databricks)

This notebook is built for **Databricks** (Serverless compute + Unity Catalog). It uses
Databricks features like `display()` and Volumes, so run it inside a Databricks workspace.

1. **Import the notebook** - Workspace → Import → File → `Week7Assignment.ipynb`
2. **Upload the CSVs to a Volume** - Catalog → Add data → Upload files to volume
   (e.g. `workspace.default.assignment_data`)
3. **Check the paths** in the notebook match your volume:
   ```python
   master_path = "/Volumes/workspace/default/assignment_data/customer_master.csv"
   incr_path   = "/Volumes/workspace/default/assignment_data/customer_incremental.csv"
   ```
4. **Connect to Serverless** compute and **Run all**.

> `spark` is provided automatically by Databricks - no SparkSession setup needed.

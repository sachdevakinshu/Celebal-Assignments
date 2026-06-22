# Week 5 - Apache Spark Basics (PySpark)

Data Engineering Internship · Celebal Technologies

Clean, transform, and analyze an Employees dataset using **Apache Spark DataFrames**.

## Objective
Learn the basics of Apache Spark and use it to clean, transform, and analyze data with DataFrames - covering loading data, handling nulls and duplicates, filtering, type casting, aggregation, grouping, and building a simple end-to-end pipeline.

## Folder Structure
```
Week5-Spark-Assignment/
├── Data/
│   └── dataset.csv            # raw Employees dataset
├── notebook/
│   └── Week5Assignment.ipynb  # main notebook
├── Output/
│   ├── dept_results.csv       # department-wise summary
│   └── cleaned_data.csv       # full cleaned dataset
└── README.md
```

## Prerequisites & Setup

- **Python 3.x**
- **Java 17** (Spark works with Java 8, 11, or 17 - newer versions like 21+ will cause errors such as `getSubject is not supported`)
- **PySpark** and **pandas**

Install the Python packages:
```bash
pip install pyspark pandas
```

### Important - Java setup
Spark runs on the Java Virtual Machine, so a supported JDK (8 / 11 / 17) must be installed.
Download Java 17 from https://adoptium.net or Oracle's Java archive.

In the notebook, `JAVA_HOME` is set to point at the Java 17 install:
```python
os.environ["JAVA_HOME"] = r"C:\Program Files\Java\jdk-17"
```
**Update this path to match your own Java 17 location before running.** To find it:
- Windows: check `C:\Program Files\Java\`
- Mac/Linux: run `which java`, or set it to your JDK 17 directory

## How to Run
Open the notebook and run all cells from top to bottom:
```bash
cd notebook
jupyter notebook Week5Assignment.ipynb
```
The notebook reads `../Data/dataset.csv` and writes the two output files into `../Output/`.

## Steps Performed
- Created a Spark session and loaded the Employees dataset (CSV) into a DataFrame.
- Inspected the data - viewed rows, columns, data types, schema, and total row count.
- Cleaned the data - removed duplicate rows, standardised inconsistent region values, filled missing ages with the mean, and dropped rows with missing salary.
- Filtered the data by age, by region, and by both conditions combined.
- Transformed the data - renamed columns and cast columns to the correct data types.
- Performed aggregations - count, average, minimum, and maximum.
- Grouped the data by department and by region using `groupBy`.
- Explored advanced concepts - wide vs narrow transformations and shuffle (demonstrated with `.explain()`).
- Combined all steps into a single reusable pipeline that outputs the cleaned dataset and a department-wise summary.

## Output
- `Output/dept_results.csv` - department-wise summary (headcount, average salary, total salary).
- `Output/cleaned_data.csv` - the full cleaned and transformed dataset.

## Key Concepts Learned
- Spark keeps data **in memory**, making it faster than disk-based MapReduce.
- **DataFrames** provide an easy, table-like API for processing data.
- **Narrow transformations** (`filter`, `withColumn`) need no data movement; **wide transformations** (`groupBy`, `orderBy`, `join`) trigger a **shuffle**, which is the costly part to minimise.



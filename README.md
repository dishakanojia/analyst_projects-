🏦 Bank Customer Churn Analysis

From raw data to a prioritized, ROI-backed retention strategy — using Python, SQL Server, and Power BI.**

---

📌 Problem Statement

The bank is losing roughly 1 in 5 customers, and with them, a meaningful share of its deposit base — but there's no clear picture of who is leaving, why, or where the losses hurt most. Retention efforts today are reactive and spread evenly across the customer base instead of focused on the segments most likely to churn and most valuable to keep.

This project answers three questions:

1. How big is the problem? Churn rate and deposit balance lost, in absolute and relative terms.
2. Who is churning, and why? Which combinations of geography, age, product holdings, engagement, and service experience predict churn.
3. What should the bank do about it? Which specific customers to prioritize for retention, and what's the financial upside of acting?

---

🧰 Tech Stack

| Stage | Tool |
|---|---|
| Data cleaning & feature engineering | Python (pandas) |
| Database & business analysis | Microsoft SQL Server (T-SQL) |
| Data loading | SQLAlchemy |
| Dashboard / reporting | Power BI |

---

🗂️ Project Structure

```
├── padas_cleaning_bank_churn.ipynb   # Python/pandas data cleaning & feature engineering
├── SQL_BUSNIESS_QUERY.sql            # 17 business-question SQL queries against the cleaned data
├── bank_churn_project.pbit           # Power BI dashboard (initial build)
├── bank_churn_project_final.pbit     # Power BI dashboard (refined final version)
└── README.md
```

---

🔄 Pipeline

```
Raw CSV (bank_churn_master.csv — 10,000 rows × 30 columns)
        │
        ▼  Python / pandas — cleaning & feature engineering
Clean CSV (bank_churn_master_clean.csv)
        │
        ▼  SQLAlchemy → SQL Server
"customers" table in the bank_churn database
        │
        ▼  17 T-SQL business queries
Answers to specific stakeholder questions
        │
        ▼  Power BI (.pbit)
Interactive dashboard: KPI cards, churn-by-segment charts, pivot table, at-risk customer list
```

---

🧹 Data Cleaning Highlights

- Converted `exit_date`, `signup_date`, `last_complaint_date` to proper datetime fields — a null `exit_date` is meaningful (customer still active), so it was preserved, not dropped.
- Filled `recent_avg_txns` nulls with `0` and `activity_decline_pct` nulls with `100` — a customer with no recent activity is, by definition, at maximum decline, not "missing data."
- Built a `has_complained` flag from `complaint_count`.
- Ran cross-field logical consistency checks (e.g., churned customer with no exit date, or active customer with an exit date — both should be impossible) to catch upstream data errors.
- Checked for duplicate `customer_id`s, invalid ages (`<18` or `>100`), and negative balances.
- Standardized text fields, binned `age` into `age_band` (18-30, 31-40, 41-50, 51-60, 60+), and added `balance_lakh` / `is_zero_balance` features.
- Loaded the cleaned dataset into SQL Server via SQLAlchemy for downstream querying.

---

🔍 Business Questions Answered in SQL

The `SQL_BUSNIESS_QUERY.sql` file contains 17 queries, including:

- Overall churn rate and deposit balance already lost to churn
- Churn by zone, age band, tenure, product count, activity status, and balance quartile
- Whether cross-sold products (credit card, fixed deposit, insurance, mutual fund, personal loan) actually reduce churn
- Gender-churn gaps *within* each zone (window functions)
- Top 5 highest-risk zone × age-band × activity-status segments
- Deposit-target attainment and RM workload by zone
- A ranked retention call list: active customers matching the high-risk profile with a recent activity collapse, sorted by balance at stake
- A what-if ROI query: deposit balance retained if churn in the highest-risk segment drops by 5 points

---
 📊 Dashboard

The Power BI report includes:

- KPI cards (churn rate, balance lost, at-risk customer count)
- Clustered bar/column charts of churn by segment
- A donut chart for compositional breakdowns
- A pivot table and detail table, including the prioritized retention call list

---

💡 Key Insights

- Churn (~20%) is a first-order revenue risk, not a rounding error.
- Churn clusters by zone, age, inactivity, and complaint history — it is **not** evenly distributed, so a blanket retention strategy is inefficient.
- Activity decline is a leading indicator: churned customers show a measurable drop in transaction activity *before* leaving.
- Not all "sticky" products are equally sticky — some correlate with materially lower churn, others don't.
- The project outputs a concrete, ranked list of current at-risk customers to contact — not just a diagnosis.
- A proposed 5-point churn reduction in the highest-risk segment is translated into a specific dollar figure, giving leadership a basis to approve a retention campaign budget.

---

🛠️ Skills Demonstrated

`pandas` · data validation & integrity checks · feature engineering · SQL Server · SQLAlchemy · window functions (`NTILE`, `AVG() OVER`) · CTEs · conditional aggregation · Power BI data modeling & visualization · segment prioritization · ROI-based recommendation framing

---

 How to Reproduce

1. Run `padas_cleaning_bank_churn.ipynb` to clean the raw dataset and load it into SQL Server.
2. Run the queries in `SQL_BUSNIESS_QUERY.sql` against the `bank_churn` database to reproduce the business analysis.
3. Open `bank_churn_project_final.pbit` in Power BI Desktop and point it at the `customers` table to regenerate the dashboard.

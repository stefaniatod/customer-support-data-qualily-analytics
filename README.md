# Customer Support Data Quality & Analytics

## Project overview
This portfolio project uses a **synthetic customer-support dataset** to demonstrate practical data handling, validation, SQL analysis, and business-oriented reporting. The work is relevant to data-specialist tasks such as maintaining structured datasets, checking data quality, identifying anomalies, and documenting repeatable analysis.

**Important:** all records are fictional and generated for learning. They are not real customer or company data.

## Business questions
- How does customer satisfaction (CSAT) vary by channel and ticket priority?
- Is slower resolution associated with lower CSAT?
- Which products or channels have comparatively higher dissatisfaction rates?
- What data-quality checks should be performed before publishing an update?

## Dataset
Period covered by tickets: **1 January–30 September 2026**.

| File | Description | Expected records |
|---|---|---:|
| `tickets.csv` | Ticket facts, timestamps, channel, priority, status and CSAT | 10,000 |
| `customers.csv` | Customer attributes and segments | 2,500 |
| `products.csv` | Product reference data | 20 |
| `agents.csv` | Support-agent reference data | 80 |
| `ticket_messages.csv` | Synthetic ticket message text | 10,000 |
| `ai_enrichment.csv` | Synthetic category, sentiment, urgency, topic and summary labels | 10,000 |
| `customer_support_analytics_dataset.xlsx` | Workbook version of the dataset | — |

The record counts above are expected dataset counts, not a claim that every downstream import has been validated in a BI tool.

## Tools and skills demonstrated
- **Excel:** PivotTables, formulas, KPI calculations, segmentation and exploratory analysis.
- **SQL (SQLite):** filtering, aggregation, joins, CTEs, CASE expressions, date/time calculations and data-quality checks.
- **Data quality:** record counts, null checks, key uniqueness, referential integrity and timestamp validation.
- **Business interpretation:** distinguish observed associations from causal claims.
- **Documentation:** assumptions, reproducible queries and limitations.

## Selected findings from exploratory analysis
- Overall average CSAT: **3.89 / 5**.
- Average resolution time for resolved tickets: approximately **24.3 hours**.
- Tickets resolved in under 24 hours had average CSAT of approximately **4.02**, compared with **3.71** for tickets taking 24 hours or more.
- Web had the highest observed dissatisfaction rate among channels in the exploratory query (about **6.79%**), followed by Email (**6.73%**), Chat (**5.94%**) and Phone (**5.74%**).

These are descriptive results from the synthetic dataset. The relationship between resolution time and CSAT is an association, not proof of causation. Product-level percentages should be interpreted alongside sample sizes.

## How to reproduce
1. Download or clone this repository.
2. Open the CSV files in Excel or import them into a SQLite database.
3. Run the queries in `sql/customer_support_analysis.sql` after creating tables named `tickets`, `products`, `customers`, `agents`, `ticket_messages`, and `ai_enrichment`.
4. Use the query outputs to validate record quality and reproduce the summary findings.
5. See `docs/data_dictionary.md` for field descriptions and validation recommendations.

### Importing CSVs into SQLite
You can use DB Browser for SQLite: create/open a database, import each CSV as a table, and keep the table names exactly as listed above. SQLite's command-line `.import` is another option.

## Limitations and next steps
- The data is synthetic and does not represent actual company performance.
- AI enrichment fields are simulated labels, not model-generated conclusions that have been independently validated.
- A production-ready extension would add automated validation tests, documented source lineage, and a refresh/update procedure.
- A BI dashboard is not included because the current browser-only Power BI setup did not successfully persist the semantic model. The Excel analysis and SQL are the validated deliverables for this version.

## Portfolio summary
This project demonstrates a repeatable workflow for checking structured data, investigating data-quality patterns, and turning ticket records into concise operational insights. It does **not** claim production experience or a completed Power BI dashboard.

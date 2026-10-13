-- Customer Support Data Quality & Analytics
-- Database: SQLite
-- Expected table names: tickets, products, customers, agents, ticket_messages, ai_enrichment
-- All records are synthetic. Run one query at a time in DB Browser for SQLite.

-- 1. Record counts: quick load validation
SELECT 'tickets' AS table_name, COUNT(*) AS row_count FROM tickets
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'agents', COUNT(*) FROM agents
UNION ALL SELECT 'ticket_messages', COUNT(*) FROM ticket_messages
UNION ALL SELECT 'ai_enrichment', COUNT(*) FROM ai_enrichment;

-- 2. Duplicate ticket IDs (expected: no rows)
SELECT ticket_id, COUNT(*) AS occurrences
FROM tickets
GROUP BY ticket_id
HAVING COUNT(*) > 1;

-- 3. CSAT values outside the expected 1-5 range
SELECT ticket_id, csat_score
FROM tickets
WHERE csat_score IS NOT NULL
  AND (CAST(csat_score AS REAL) < 1 OR CAST(csat_score AS REAL) > 5);

-- 4. Invalid timestamp ordering: resolution before ticket creation
SELECT ticket_id, created_at, resolved_at
FROM tickets
WHERE resolved_at IS NOT NULL
  AND julianday(resolved_at) < julianday(created_at);

-- 5. Orphan product references (expected: no rows)
SELECT t.ticket_id, t.product_id
FROM tickets AS t
LEFT JOIN products AS p ON p.product_id = t.product_id
WHERE p.product_id IS NULL;

-- 6. Overall CSAT and resolution time for resolved tickets
SELECT
    COUNT(*) AS resolved_tickets,
    ROUND(AVG(CAST(csat_score AS REAL)), 2) AS avg_csat,
    ROUND(AVG((julianday(resolved_at) - julianday(created_at)) * 24), 2)
        AS avg_resolution_hours
FROM tickets
WHERE resolved_at IS NOT NULL;

-- 7. CSAT and ticket volume by channel
SELECT
    channel,
    COUNT(*) AS ticket_count,
    ROUND(AVG(CAST(csat_score AS REAL)), 2) AS avg_csat
FROM tickets
GROUP BY channel
ORDER BY avg_csat DESC;

-- 8. CSAT and ticket volume by priority
SELECT
    priority,
    COUNT(*) AS ticket_count,
    ROUND(AVG(CAST(csat_score AS REAL)), 2) AS avg_csat
FROM tickets
GROUP BY priority
ORDER BY
    CASE priority
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
        ELSE 5
    END;

-- 9. Resolution-speed comparison (resolved tickets only)
WITH ticket_speed AS (
    SELECT
        ticket_id,
        CAST(csat_score AS REAL) AS csat_score,
        (julianday(resolved_at) - julianday(created_at)) * 24 AS resolution_hours
    FROM tickets
    WHERE resolved_at IS NOT NULL
)
SELECT
    CASE WHEN resolution_hours < 24 THEN 'Under 24 hours'
         ELSE '24 hours or more' END AS resolution_group,
    COUNT(*) AS ticket_count,
    ROUND(AVG(resolution_hours), 2) AS avg_resolution_hours,
    ROUND(AVG(csat_score), 2) AS avg_csat
FROM ticket_speed
GROUP BY resolution_group
ORDER BY resolution_group;

-- 10. Dissatisfied rate by channel (CSAT 1-2; NULL CSAT excluded from rate denominator)
SELECT
    channel,
    COUNT(*) AS tickets_with_csat,
    SUM(CASE WHEN CAST(csat_score AS REAL) < 3 THEN 1 ELSE 0 END) AS dissatisfied_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN CAST(csat_score AS REAL) < 3 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(csat_score), 0),
        2
    ) AS dissatisfied_rate_pct
FROM tickets
WHERE csat_score IS NOT NULL
GROUP BY channel
ORDER BY dissatisfied_rate_pct DESC;

-- 11. Product-level review: volume, CSAT, dissatisfaction rate
SELECT
    p.product_name,
    COUNT(t.ticket_id) AS ticket_count,
    ROUND(AVG(CAST(t.csat_score AS REAL)), 2) AS avg_csat,
    SUM(CASE WHEN CAST(t.csat_score AS REAL) < 3 THEN 1 ELSE 0 END) AS dissatisfied_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN CAST(t.csat_score AS REAL) < 3 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(t.csat_score), 0),
        2
    ) AS dissatisfied_rate_pct
FROM tickets AS t
JOIN products AS p ON p.product_id = t.product_id
GROUP BY p.product_name
ORDER BY dissatisfied_rate_pct DESC, ticket_count DESC;

-- 12. Product/channel combinations to investigate (include sample size)
SELECT
    p.product_name,
    t.channel,
    COUNT(*) AS ticket_count,
    SUM(CASE WHEN CAST(t.csat_score AS REAL) < 3 THEN 1 ELSE 0 END) AS dissatisfied_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN CAST(t.csat_score AS REAL) < 3 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(t.csat_score), 0),
        2
    ) AS dissatisfied_rate_pct
FROM tickets AS t
JOIN products AS p ON p.product_id = t.product_id
WHERE t.csat_score IS NOT NULL
GROUP BY p.product_name, t.channel
HAVING COUNT(t.ticket_id) >= 20
ORDER BY dissatisfied_rate_pct DESC, ticket_count DESC;

-- 13. Status completeness check: resolved status without resolved timestamp
SELECT ticket_id, status, resolved_at
FROM tickets
WHERE LOWER(status) = 'resolved'
  AND resolved_at IS NULL;

-- 14. AI enrichment coverage and duplicate-key check
SELECT
    COUNT(*) AS enrichment_rows,
    COUNT(DISTINCT ticket_id) AS unique_ticket_ids,
    COUNT(*) - COUNT(DISTINCT ticket_id) AS duplicate_ticket_ids
FROM ai_enrichment;

-- 15. Join coverage: tickets missing customer, product or agent reference
SELECT
    SUM(CASE WHEN c.customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_refs,
    SUM(CASE WHEN p.product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_refs,
    SUM(CASE WHEN a.agent_id IS NULL THEN 1 ELSE 0 END) AS missing_agent_refs
FROM tickets AS t
LEFT JOIN customers AS c ON c.customer_id = t.customer_id
LEFT JOIN products AS p ON p.product_id = t.product_id
LEFT JOIN agents AS a ON a.agent_id = t.agent_id;

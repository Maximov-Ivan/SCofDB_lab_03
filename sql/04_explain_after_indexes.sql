\timing on
\echo '=== AFTER INDEXES ==='

SET max_parallel_workers_per_gather = 0;
SET work_mem = '32MB';
ANALYZE;

-- ============================================
-- TODO:
-- Скопируйте сюда ТО ЖЕ множество запросов из 02_explain_before.sql
-- и выполните EXPLAIN (ANALYZE, BUFFERS) повторно.
-- ============================================

\echo '--- Q1 ---'
-- TODO: EXPLAIN (ANALYZE, BUFFERS) ...
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_id, total_amount, created_at, status
FROM orders
WHERE total_amount > 2000
ORDER BY created_at DESC
LIMIT 10;

\echo '--- Q2 ---'
-- TODO: EXPLAIN (ANALYZE, BUFFERS) ...
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, user_id, total_amount, created_at, status
FROM orders
WHERE status = 'paid'
  AND created_at >= '2024-07-01'
  AND created_at < '2025-01-01';

\echo '--- Q3 ---'
-- TODO: EXPLAIN (ANALYZE, BUFFERS) ...
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.user_id,
    COUNT(DISTINCT o.id) as orders_count,
    COUNT(oi.id) as items_count,
    SUM(oi.price * oi.quantity) as total_revenue,
    AVG(oi.price) as avg_item_price
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status != 'cancelled'
  AND created_at >= '2025-01-01'
  AND created_at < '2025-07-01'
GROUP BY o.user_id
ORDER BY total_revenue DESC
LIMIT 10;

-- (Опционально) Q4
-- TODO

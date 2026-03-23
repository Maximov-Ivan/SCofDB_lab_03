\timing on
\echo '=== APPLY INDEXES ==='

-- ============================================
-- TODO: Создайте индексы на основе ваших EXPLAIN ANALYZE
-- ============================================

-- Индекс 1
-- TODO:
CREATE INDEX idx_orders_created_at ON orders USING BTREE (created_at);
-- Обоснование:
-- - Ускоряет Q1, Q2, Q3: все запросы с фильтрацией или сортировкой по дате
-- - BTREE оптимален для операций сравнения и сортировки

-- Индекс 2
-- TODO:
CREATE INDEX idx_orders_status_created_at ON orders USING BTREE (status, created_at);
-- Обоснование:
-- - Ускоряет Q2, Q3: фильтрация по диапазону дат и статусу
-- - Данные фильтруются сначала по статусу, затем по диапазону дат

-- Индекс 3
-- TODO:
CREATE INDEX idx_orders_created_at_part ON orders USING BTREE (created_at)
WHERE created_at >= '2025-01-01' AND created_at < '2025-07-01';
-- Обоснование:
-- - Ускоряет Q3: фильтрация по определенному диапазону дат 
-- - Частичный индекс для определенного промежутка времени

-- Не забудьте обновить статистику после создания индексов
-- TODO:
ANALYZE orders;
ANALYZE order_items;

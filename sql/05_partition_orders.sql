\timing on
\echo '=== PARTITION ORDERS BY DATE ==='

-- ============================================
-- TODO: Реализуйте партиционирование orders по дате
-- ============================================

-- Вариант A (рекомендуется): RANGE по created_at (месяц/квартал)
-- Вариант B: альтернативная разумная стратегия

-- Шаг 1: Подготовка структуры
-- TODO:
-- - создайте partitioned table (или shadow-таблицу для безопасной миграции)
-- - определите partition key = created_at
CREATE TABLE orders_partitioned (
    id UUID DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'created',
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT orders_user_id_fk FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT orders_status_fk FOREIGN KEY (status) 
        REFERENCES order_statuses(status),
    CONSTRAINT orders_total_amount_positive CHECK (total_amount >= 0)
) PARTITION BY RANGE (created_at);

-- Шаг 2: Создание партиций
-- TODO:
-- - создайте набор партиций по диапазонам дат
-- - добавьте DEFAULT partition (опционально)
CREATE TABLE orders_2024_q1 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
CREATE TABLE orders_2024_q2 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
CREATE TABLE orders_2024_q3 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');
CREATE TABLE orders_2024_q4 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');
CREATE TABLE orders_2025_q1 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');
CREATE TABLE orders_2025_q2 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');
CREATE TABLE orders_2025_q3 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');
CREATE TABLE orders_2025_q4 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2025-10-01') TO ('2026-01-01');
CREATE TABLE orders_default PARTITION OF orders_partitioned DEFAULT;

-- Шаг 3: Перенос данных
-- TODO:
-- - перенесите данные из исходной таблицы
-- - проверьте количество строк до/после
INSERT INTO orders_partitioned (id, user_id, status, total_amount, created_at)
SELECT id, user_id, status, total_amount, created_at
FROM orders;

SELECT 'original' as table_name, COUNT(*) as rows_count FROM orders
UNION ALL
SELECT 'partitioned', COUNT(*) FROM orders_partitioned;

-- Шаг 4: Индексы на партиционированной таблице
-- TODO:
-- - создайте нужные индексы (если требуется)
CREATE INDEX idx_orders_partitioned_created_at ON orders_partitioned USING BTREE (created_at);
CREATE INDEX idx_orders_partitioned_status_created_at ON orders_partitioned USING BTREE (status, created_at);

-- Шаг 5: Проверка
-- TODO:
-- - ANALYZE
-- - проверка partition pruning на запросах по диапазону дат
ANALYZE orders_partitioned;

\echo '--- Запрос на оригинальной таблице ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM orders
WHERE created_at >= '2024-07-01' AND created_at < '2024-10-01';

\echo '--- Запрос на таблице с партициями---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*)
FROM orders_partitioned
WHERE created_at >= '2024-07-01' AND created_at < '2024-10-01';

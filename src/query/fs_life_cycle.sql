WITH tb_life_cycle_atual AS (
    SELECT
        IdCliente,
        descLifeCycle
    FROM life_cycle
    WHERE dtRef = date('2026-02-01', '-1 day')
)

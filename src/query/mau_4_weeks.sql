WITH tb_daily AS (
    SELECT DISTINCT
        date(substr(DtCriacao, 0, 11)) as DtDia
        , IdCliente
    FROM transacoes
    ORDER BY DtDia
)
, tb_distinct_day as (
    SELECT
        DISTINCT DtDia as DtRef
    FROM tb_daily
)
SELECT
    tdd.DtRef
    , count(distinct IdCliente) as MAU
FROM tb_distinct_day AS tdd
LEFT JOIN tb_daily as td
    on td.DtDia <= tdd.DtRef
    and julianday(tdd.DtRef) - julianday(td.DtDia) < 28
GROUP BY tdd.DtRef 
ORDER BY tdd.DtRef desc
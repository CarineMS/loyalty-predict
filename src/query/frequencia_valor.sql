WITH tb_freq_valor AS (
SELECT
    IdCliente
    , COUNT(DISTINCT substr(DtCriacao, 0, 11)) AS qtdeFrequencia
    , SUM( CASE WHEN QtdePontos > 0 THEN QtdePontos END ) AS qtdePontosPos
    -- , SUM(ABS(QtdePontos)) AS qtdePontosAbs
FROM transacoes
WHERE 
    DtCriacao < '2025-09-01'
    AND DtCriacao > date('2025-09-01', '-28 day')
GROUP BY IdCliente
ORDER BY DtCriacao DESC
)
, tb_cluster AS (
SELECT
    *
    , CASE 
        WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 1500 THEN '12-HYPER'
        WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN '22-EFICIENTE'
        WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN '11-INDECISO'
        WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 750 THEN '21-ESFORÇADO'
        WHEN qtdeFrequencia < 5 THEN '00-LURKER'
        WHEN qtdeFrequencia <= 10 THEN '01-PREGUIÇOSO'
        WHEN qtdeFrequencia > 10 THEN '20-POTENCIAL'
    END AS descCluster
FROM tb_freq_valor
)
SELECT 
    *
FROM tb_cluster
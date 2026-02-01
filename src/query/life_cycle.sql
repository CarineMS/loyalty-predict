-- curioso      -> idade < 7 dias
-- fiel         -> recencia < 7 dias E recencia < 15
-- turista      -> recencia menor que 14 e maior que 7
-- desencantado -> recencia menor que 28 e maior que 14
-- zumbi        -> recencia maior que 28

-- fluxo de retorno
-- reconquitado -> recencia menor que 7 dias e recencia anterior entre 14 e 28 dias (veio do desencantado)
-- reborn       -> recencia menor que 7 dias e recencia anterior maior que 28 (vem do zumbi)

with tb_daily AS (
    SELECT DISTINCT
        IdCliente
        , substr(DtCriacao, 0, 11) DtDia    
    FROM transacoes
    WHERE DtCriacao < '{date}'
)
, tb_idade AS (
    SELECT
        IdCliente
        , min(DtDia) dtPrimTransacao
        , CAST(max(julianday('{date}') - julianday(DtDia)) AS int) qtdeDiasPrimTransacao
        
        , max(DtDia) dtUltTransacao
        , CAST(min(julianday('{date}') - julianday(DtDia)) AS int) qtdeDiasUltTransacao
    FROM tb_daily
    GROUP BY IdCliente
)
, tb_rn as (
    SELECT
        *
        , ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY DtDia DESC) rnDia
    FROM tb_daily
)
, tb_penultima_ativacao as (
    SELECT 
        *
        , CAST((julianday('{date}') - julianday(DtDia)) AS int) qtdeDiasPenultimaTransacao
    FROM tb_rn
    WHERE rnDia = 2
)
, life_cycle as (
    SELECT 
        t1.*
        , t2.qtdeDiasPenultimaTransacao
        , CASE
            WHEN qtdeDiasPrimTransacao <= 7 THEN '01-CURIOSO'
            WHEN qtdeDiasUltTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao <= 14 THEN '02-FIEL'
            WHEN qtdeDiasUltTransacao BETWEEN 8 AND 14 THEN '03-TURISTA'
            WHEN qtdeDiasUltTransacao BETWEEN 15 AND 28 THEN '04-DESENCANTADA'
            WHEN qtdeDiasUltTransacao > 28 THEN '05-ZUMBI'
            WHEN qtdeDiasUltTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao BETWEEN 15 AND 27 THEN '02-RECONQUISTADO'
            WHEN qtdeDiasUltTransacao <= 7 AND qtdeDiasPenultimaTransacao - qtdeDiasUltTransacao > 28 THEN '02-REBORN'
        END AS descLifeCycle
    FROM tb_idade t1
    LEFT JOIN tb_penultima_ativacao t2
        ON t1.IdCliente = t2.IdCliente
)
, tb_freq_valor AS (
SELECT
    IdCliente
    , COUNT(DISTINCT substr(DtCriacao, 0, 11)) AS qtdeFrequencia
    , SUM( CASE WHEN QtdePontos > 0 THEN QtdePontos END ) AS qtdePontosPos
    -- , SUM(ABS(QtdePontos)) AS qtdePontosAbs
FROM transacoes
WHERE 
    DtCriacao < '{date}'
    AND DtCriacao > date('{date}', '-28 day')
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
    date('{date}', '-1 day') as DtRef
    , t1.*
    , t2.qtdeFrequencia
    , t2.qtdePontosPos
    , t2.descCluster
FROM life_cycle t1
LEFT JOIN tb_cluster t2 
    ON t1.IdCliente = t2.IdCliente


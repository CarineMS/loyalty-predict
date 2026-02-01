WITH tb_transacao AS (

    SELECT 
        *,
        substr(DtCriacao,0,11) DtDia,
        cast(substr(DtCriacao, 12,2) AS int) AS dtHora
    FROM transacoes
    WHERE DtCriacao < '2026-01-25'

)
, tb_agg_transacao as (

    SELECT 
        IdCliente,
        COUNT(DISTINCT DtDia) AS qtdeAtivacaoVida,
        COUNT(DISTINCT CASE WHEN DtDia > date('2026-01-25', '-7 day') THEN DtDia END) AS qtdeAtivacaoVidaD7,
        COUNT(DISTINCT CASE WHEN DtDia > date('2026-01-25', '-14 day') THEN DtDia END) AS qtdeAtivacaoVidaD14,
        COUNT(DISTINCT CASE WHEN DtDia > date('2026-01-25', '-28 day') THEN DtDia END) AS qtdeAtivacaoVidaD28,
        COUNT(DISTINCT CASE WHEN DtDia > date('2026-01-25', '-56 day') THEN DtDia END) AS qtdeAtivacaoVidaD56,

        COUNT(DISTINCT IdTransacao) AS qtdeTransacaoVida,
        COUNT(DISTINCT CASE WHEN DtDia > date('2026-01-25', '-7 day') THEN IdTransacao END) AS qtdeTransacaoVidaD7,
        COUNT(DISTINCT CASE WHEN DtDia > date('2026-01-25', '-14 day') THEN IdTransacao END) AS qtdeTransacaoVidaD14,
        COUNT(DISTINCT CASE WHEN DtDia > date('2026-01-25', '-28 day') THEN IdTransacao END) AS qtdeTransacaoVidaD28,
        COUNT(DISTINCT CASE WHEN DtDia > date('2026-01-25', '-56 day') THEN IdTransacao END) AS qtdeTransacaoVidaD56,

        SUM(QtdePontos) AS saldoVida,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-7 day') THEN QtdePontos ELSE 0 END) AS saldoD7,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-14 day') THEN QtdePontos ELSE 0 END) AS saldoD14,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-28 day') THEN QtdePontos ELSE 0 END) AS saldoD28,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-56 day') THEN QtdePontos ELSE 0 END) AS saldoD56,

        SUM(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosVida,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-7 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosD7,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-14 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosD14,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-28 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosD28,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-56 day') AND QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPosD56,

        SUM(CASE WHEN QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegVida,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-7 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegD7,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-14 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegD14,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-28 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegD28,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-56 day') AND QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS qtdePontosNegD56,

        1. * COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoManha,
        1. * COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoTarde,
        1. * COUNT(CASE WHEN dtHora > 21 OR dtHora < 10 THEN IdTransacao END) / COUNT(IdTransacao) AS pctTransacaoNoite

    FROM tb_transacao
    GROUP BY IdCliente

), 
tb_agg_calc AS (
    SELECT
        *,
        COALESCE( 1. * qtdeTransacaoVida / qtdeAtivacaoVida,0) AS qtdeTransacaoDia,
        COALESCE( 1. * qtdeTransacaoVidaD7 / qtdeAtivacaoVidaD7,0) AS qtdeTransacaoDiaD7,
        COALESCE( 1. * qtdeTransacaoVidaD14 / qtdeAtivacaoVidaD14,0) AS qtdeTransacaoDiaD14,
        COALESCE( 1. * qtdeTransacaoVidaD28 / qtdeAtivacaoVidaD28,0) AS qtdeTransacaoDiaD28,
        COALESCE( 1. * qtdeTransacaoVidaD56 / qtdeAtivacaoVidaD56,0) AS qtdeTransacaoDiaD56,

        1. * qtdeAtivacaoVidaD28 / 28 AS pctAtivacaoMAU
    FROM tb_agg_transacao
)
, tb_horas_dia as (

    SELECT
        IdCliente,
        DtDia,
        24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao
    FROM tb_transacao
    GROUP BY IdCliente, DtDia

)
, tb_hora_cliente AS (
    SELECT
        IdCliente,
        SUM(duracao) qtdeHorasVida,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
        SUM(CASE WHEN DtDia > date('2026-01-25', '-56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56
    FROM tb_horas_dia
    GROUP BY IdCliente
)
, tb_lag_dia as (
    SELECT
        IdCliente,
        DtDia,
        LAG(DtDia) OVER(PARTITION BY IdCliente ORDER BY DtDia) AS lagDia
    FROM tb_horas_dia
)
, tb_invervalo_dias AS (
    SELECT
        IdCliente,
        avg(julianday(DtDia) - julianday(lagDia)) AS avgIntervalosDiaVida,
        avg(CASE WHEN DtDia >= date('2026-01-25', '-28 day') THEN julianday(DtDia) - julianday(lagDia) END) AS avgIntervalosDiasD28
    FROM tb_lag_dia
    GROUP BY IdCliente
)
, tb_join as (
SELECT
    t1.*,
    t2.qtdeHorasVida,
    t2.qtdeHorasD7,
    t2.qtdeHorasD14,
    t2.qtdeHorasD28,
    t2.qtdeHorasD56,
    t3.avgIntervalosDiaVida,
    t3.avgIntervalosDiasD28

FROM tb_agg_calc AS t1
LEFT JOIN tb_hora_cliente AS t2
    ON t1.IdCliente = t2.IdCliente
LEFT JOIN tb_invervalo_dias AS t3
    ON t1.IdCliente = t3.IdCliente
)

SELECT
    *
FROM tb_join

limit 10

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

        MAX(julianday(date('2026-01-25', '-1 day')) - julianday(DtCriacao)) AS idadeDias,

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
, tb_share_produtos as (
    SELECT
        idCliente,
        1. * COUNT(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeChatMessage,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeAirflowLover,
        1. * COUNT(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeRLover,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeResgatarPonei,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeListadepresenca,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdePresencaStreak,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeTrocaStreamElements,
        1. * COUNT(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeReembolsoStreamElements,
        1. * COUNT(CASE WHEN DescCategoriaProduto = 'rpg' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeRPG,
        1. * COUNT(CASE WHEN DescCategoriaProduto = 'churn_model' THEN t1.IdTransacao END) / COUNT(t1.IdTransacao) AS qtdeChurnModel

    FROM tb_transacao t1

    LEFT JOIN transacao_produto as t2
        ON t1.IdTransacao = t2.IdTransacao

    LEFT JOIN produtos as t3
        ON t2.IdProduto = t3.IdProduto

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
        t3.avgIntervalosDiasD28,
        t4.qtdeChatMessage,
        t4.qtdeAirflowLover,
        t4.qtdeRLover,
        t4.qtdeResgatarPonei,
        t4.qtdeListadepresenca,
        t4.qtdePresencaStreak,
        t4.qtdeTrocaStreamElements,
        t4.qtdeReembolsoStreamElements,
        t4.qtdeRPG,
        t4.qtdeChurnModel

    FROM tb_agg_calc AS t1

    LEFT JOIN tb_hora_cliente AS t2
        ON t1.IdCliente = t2.IdCliente
    
    LEFT JOIN tb_invervalo_dias AS t3
        ON t1.IdCliente = t3.IdCliente
    
    LEFT JOIN tb_share_produtos AS t4
        ON t1.IdCliente = t4.IdCliente
)

SELECT
    date('2026-01-25', '-1 day') as dtRef,
    *
FROM tb_join
LIMIT 10
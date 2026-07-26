CREATE TABLE abt_fiel AS

WITH tb_join AS (
    SELECT
        t1.dtRef,
        t1.IdCliente,
        t1.descLifeCycle,
        t2.descLifeCycle,
        CASE WHEN t2.descLifeCycle = '02-FIEL' THEN 1 ELSE 0 END AS flFiel,
        ROW_NUMBER() OVER (PARTITION BY T1.IdCliente ORDER BY random()) as RandomCol
    FROM life_cycle AS t1

    LEFT JOIN life_cycle AS t2
        ON t1.IdCliente = t2.IdCliente
        AND DATE(t1.dtRef, '+28 day') = DATE(t2.dtRef)
        
    WHERE
        (
            (t1.dtRef <= '2024-03-01' AND t1.dtRef <= '2025-08-01') 
            OR t1.dtRef = '2025-09-01'
        )
        AND t1.descLifeCycle <> '05-ZUMBI'
)
, tb_cohord AS (
    SELECT 
        t1.dtRef,
        t1.IdCliente,
        t1.flFiel

    FROM tb_join AS t1

    WHERE  
        RandomCol <= 2

    ORDER BY IdCliente, dtRef
)
    SELECT
        t1.*,
        t2.idadeDias, 
        t2.qtdeAtivacaoVida, 
        t2.qtdeAtivacaoVidaD7, 
        t2.qtdeAtivacaoVidaD14, 
        t2.qtdeAtivacaoVidaD28, 
        t2.qtdeAtivacaoVidaD56, 
        t2.qtdeTransacaoVida, 
        t2.qtdeTransacaoVidaD7, 
        t2.qtdeTransacaoVidaD14, 
        t2.qtdeTransacaoVidaD28, 
        t2.qtdeTransacaoVidaD56, 
        t2.saldoVida,
        t2.saldoD7,
        t2.saldoD14,
        t2.saldoD28,
        t2.saldoD56,
        t2.qtdePontosPosVida,
        t2.qtdePontosPosD7,
        t2.qtdePontosPosD14,
        t2.qtdePontosPosD28,
        t2.qtdePontosPosD56,
        t2.qtdePontosNegVida,
        t2.qtdePontosNegD7,
        t2.qtdePontosNegD14,
        t2.qtdePontosNegD28,
        t2.qtdePontosNegD56,
        t2.pctTransacaoManha,
        t2.pctTransacaoTarde,
        t2.pctTransacaoNoite,
        t2.qtdeTransacaoDia,
        t2.qtdeTransacaoDiaD7,
        t2.qtdeTransacaoDiaD14,
        t2.qtdeTransacaoDiaD28,
        t2.qtdeTransacaoDiaD56,
        t2.pctAtivacaoMAU,
        t2.qtdeHorasVida,
        t2.qtdeHorasD7,
        t2.qtdeHorasD14,
        t2.qtdeHorasD28,
        t2.qtdeHorasD56,
        t2.avgIntervalosDiaVida,
        t2.avgIntervalosDiasD28,
        t2.qtdeChatMessage,
        t2.qtdeAirflowLover,
        t2.qtdeRLover,
        t2.qtdeResgatarPonei,
        t2.qtdeListadepresenca,
        t2.qtdePresencaStreak,
        t2.qtdeTrocaStreamElements,
        t2.qtdeReembolsoStreamElements,
        t2.qtdeRPG,
        t2.qtdeChurnModel,
        t3.qtdeFrequencia,
        t3.descLifeCycleAtual,
        t3.descLifeCycleD28,
        t3.pctCurioso,
        t3.pctFiel,
        t3.pctTurista,
        t3.pctDesencantada,
        t3.pctZumbi,
        t3.pctReconquistado,
        t3.pctReborn,
        t3.avgFreqGrupo,
        t3.ratioFreqGrupo,
        t4.qtdeCursosCompletos,
        t4.qtdeCursosIncompletos,
        t4.carreira,
        t4.coletaDados2024,
        t4.dsDatabricks2024,
        t4.dsPontos2024,
        t4.estatistica2024,
        t4.estatistica2025,
        t4.github2024,
        t4.github2025,
        t4.go2026,
        t4.iaCanal2025,
        t4.lagoMago2024,
        t4.loyaltyPredict2025,
        t4.machineLearning2025,
        t4.matchmakingTramparDeCasa2024,
        t4.ml2024,
        t4.mlflow2025,
        t4.nekt2025,
        t4.pandas2024,
        t4.pandas2025,
        t4.python2024,
        t4.python2025,
        t4.speedF1,
        t4.sql2020,
        t4.sql2025,
        t4.streamlit2025,
        t4.tramparLakehouse2024,
        t4.tseAnalytics2024,
        t4.qtdeDiasUltiAtividade

    FROM tb_cohord AS t1

    LEFT JOIN fs_transacional AS t2
        ON t1.IdCliente = t2.IdCliente
        AND t1.dtRef = t2.dtRef

    LEFT JOIN fs_life_cycle AS t3
        ON t1.IdCliente = t3.IdCliente
        AND t1.dtRef = t3.dtRef

    LEFT JOIN fs_education AS t4
    ON t1.IdCliente = t4.IdCliente
    AND t1.dtRef = t4.dtRef
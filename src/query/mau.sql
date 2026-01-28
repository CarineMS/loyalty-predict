SELECT
    substr(DtCriacao, 0, 8) as DtMes
    , count( distinct IdCliente) as MAU
FROM transacoes
group by 1
order by 1
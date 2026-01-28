-- SELECT
--     substr(DtCriacao, 0, 11) as DtDia
--     , count( distinct IdCliente) as DAU
-- FROM transacoes
-- group by 1
-- order by 1


select * from transacoes limit 10000

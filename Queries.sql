-- Explorando os datasets a serem usados para os insights	

select * from dbo.olist_orders_dataset -- Tabela fato do dataset
select * from dbo.olist_customers_dataset -- Tabela dimensão 
select * from dbo.olist_order_payments_dataset -- Tabela fato/dimensão
select * from dbo.olist_order_reviews_dataset -- Tabela fato/dimensão
select * from dbo.olist_products_dataset -- Tabela dimensão
select * from dbo.olist_sellers_dataset -- Tabela dimensão

-- Identificando os pontos fortes da empresa
		
		/* Comparativo de cidades contendo o somatorio das vendas, a sua quantidade, bem como o Ticket Médio por cidade*/

Create view vendasxcidade as
select (c.["customer_city"]) as Cidade, sum(cast(p.["payment_value"] as decimal (18,2))) as Valor_vendasxcidade, count(c.["customer_city"]) as Qtde_vendasxcidade, sum(cast(p.["payment_value"] as decimal (18,2)))/cast(count(c.["customer_city"]) as decimal (18,2)) as Ticket_medioxcidade
from dbo.olist_orders_dataset o
inner join dbo.olist_customers_dataset c
on o.["customer_id"] = c.["customer_id"]
inner join dbo.olist_order_payments_dataset p
on o.["order_id"] = p.["order_id"]
group by c.["customer_city"]

select *
from vendasxcidade v
where v.Ticket_medioxcidade = (select min(v.Ticket_medioxcidade) 
								from vendasxcidade v)


		/* Comparativo de estados contendo o somatorio das vendas, a sua quantidade, bem como o Ticket Médio por estado*/

create view vendasxestado as
select (c.["customer_state"]) Estado, sum(cast(p.["payment_value"] as decimal (18,2))) as Total_vendasxestado, count(c.["customer_state"]) as Qtde_vendasxestado, sum(cast(p.["payment_value"] as decimal (18,2)))/cast(count(c.["customer_state"]) as decimal (18,2)) Ticket_Medioxestado
from dbo.olist_orders_dataset o
inner join dbo.olist_customers_dataset c
on o.["customer_id"] = c.["customer_id"]
inner join dbo.olist_order_payments_dataset p
on o.["order_id"] = p.["order_id"]
group by c.["customer_state"]
order by 2 desc

select *
from vendasxestado e 
where e.Ticket_Medioxestado between (select min(e.Ticket_Medioxestado) from vendasxestado e) and (select avg(e.Ticket_Medioxestado) from vendasxestado e)
order by e.Total_vendasxestado desc

-- Foram criadas 2 views que guardam os registros POR ESTADO E POR CIDADE da somatória das vendas, a quantidade de vendas e o ticket médio da localidade. Feito isso, pode-se impor as condiçoes com o uso do 'where', de acordo com a necessidade da consulta.


			/*Identificando a preferência do método de pagamento dos clientes e a porcentagem disto*/
select p.["payment_type"], count(p.["payment_type"]) Qntd_metodo_pagamento, cast((count(p.["payment_type"])/temp.qntd)*100 as numeric (10,3)) as Porcetagem 
from dbo.olist_order_payments_dataset p, (select cast(count(["payment_type"]) as numeric (10,3)) qntd from dbo.olist_order_payments_dataset) temp
group by p.["payment_type"], temp.qntd
order by 2 desc

-- Identificando possíveis melhorias com o delivery nas regiões com mais atrasos

create view info_entregas as
select o.["order_estimated_delivery_date"], o.["order_delivered_customer_date"], Prazo = case when (cast(o.["order_delivered_customer_date"] as datetime2)) < (cast(o.["order_estimated_delivery_date"] as datetime2)) 
																							then 'Entrega antecipada'
																						   when (cast(o.["order_delivered_customer_date"] as datetime2)) is null 
																						   then 'Aguardando entrega' 
																						   else 'Entrega atrasada' end , c.["customer_state"]
from dbo.olist_orders_dataset o
join dbo.olist_customers_dataset c
on o.["customer_id"] = c.["customer_id"]

select i.["customer_state"], i.Prazo, count(i.Prazo) as Qntd_entregas
from info_entregas i
group by i.["customer_state"], i.Prazo
order by 1*/ 

-- Comparativo geral entre os produtos no que tange ao nº de vendas, bem como região mais vendida de determinado produto

select c.["customer_state"], p.["product_category_name"], count(p.["product_category_name"]) Qntd_vendidas
from dbo.olist_orders_dataset o
join dbo.olist_order_items_dataset i
on o.["order_id"] = i.["order_id"]
join dbo.olist_products_dataset p
on i.["product_id"] = p.["product_id"]
join dbo.olist_customers_dataset c
on o.["customer_id"] = c.["customer_id"]
where c.["customer_state"] in ('SP','RJ')
group by c.["customer_state"], p.["product_category_name"]
order by 1 asc, 3 desc

-- Identificando com tabela simples os melhores vendedores da empresa

select s.["seller_id"], count(s.["seller_id"])Qntd_vendas
from dbo.olist_orders_dataset o
join dbo.olist_order_items_dataset i
on o.["order_id"] = i.["order_id"]
join dbo.olist_sellers_dataset s
on i.["seller_id"] = s.["seller_id"]
group by s.["seller_id"]
order by 2 desc

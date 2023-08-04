-- Comandos DDL


-- drop é DDL
-- delete é DML


-- Converter chave primária composta da tabela item_pedido para uma chave simples
-- Passo 1) adicionar coluna nova
alter table item_pedido add numitm serial;

-- Passo 2) excluir a atual chave primária
alter table item_pedido drop constraint item_pedido_pk;

-- Passo 3) adicionar nova chave primária
alter table item_pedido add constraint item_pedido_pk primary key(numitm);




-- Converter a coluna DATPED de date para timestamp
alter table pedido alter datped type timestamp;


-- adicionar a coluna prepro (preço) na tabela item_pedido
alter table item_pedido add column prepro numeric(10,2);


-- excluir a coluna limite de crédito do cliente
alter table cliente drop column limcrecli;


-- criar uma cópia da tabela cliente
create table cliente_copia1 as select * from cliente;

select * into cliente_copia from cliente;



-- próx: schemas, view, index, sequences
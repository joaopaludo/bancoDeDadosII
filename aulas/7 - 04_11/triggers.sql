-- Gatilhos ou Triggers
-- são objetos de banco com código PLPGSQL que disparam a partir de eventos acionados em tabelas
-- eventos como: insert, update e delete
-- podem ser disparados antes(BEFORE) ou depois(AFTER)

-- no postgresql a declaração da trigger e o "corpo" ficam separados



-- quando a function é do tipo trigger, variáveis implícitas são injetadas
	-- TG_RELNAME = nome da tabela que disparou a trigger
	-- TG_OP = nome da operação DML que acionou a trigger
	-- TG_WHEN = quando disparou (antes ou depois)
	-- NEW = representa o registro novo (insert, update)
	-- OLD = representa o registro antigo (delete, update)

	-- pode retornar old, new ou null

create or replace function funcionamento_trigger()
returns trigger
as
$body$
begin
	raise notice '% - % - % - NEW(%), OLD(%)', TG_RELNAME, TG_OP, TG_WHEN, new::text, old::text;
	return new;
end
$body$
language plpgsql;


-- criando a trigger de fato
create trigger nacionalidade_bf_tg
before insert or update or delete
on nacionalidade
for each row
execute procedure funcionamento_trigger();

create trigger nacionalidade_af_tg
after insert or update or delete
on nacionalidade
for each row
execute procedure funcionamento_trigger();

drop trigger nacionalidade_af_tg on nacionalidade;



select * from nacionalidade;

insert into nacionalidade values (10, 'Paraguaio');

update nacionalidade set desnac = upper(desnac) where codnac = 10;

delete from nacionalidade where codnac = 10;




-- criando trigger para verificar se ao tentar emprestar um livro não existem reservas
create or replace function verifica_reserva()
returns trigger
as
$body$
declare
	conta numeric;
begin
	select count(*) into conta from reserva where codliv = new.codliv; 
	if (conta > 0) then
		raise exception 'O livro % possui reserva(s).', new.codliv;
	end if;
	return new;
end
$body$
language plpgsql;

create or replace trigger emprestimo_bf_tg
before insert
on emprestimo
for each row
execute procedure verifica_reserva();

select * from emprestimo e;
select * from reserva r;
insert into emprestimo values(2, 1001, 1, current_timestamp);
insert into emprestimo values(3, 1002, 1, current_timestamp);




-- Regra de negócio: não pode cadastrar peças com peso > 200
create or replace function controla_peso()
returns trigger
as
$body$
begin 
	if (new.pespec > 200) then
		raise exception 'Peça % pesa % e o limite é 200.', new.codpec, new.pespec;
	end if;
	return new;
end
$body$
language plpgsql;

create or replace trigger peca_bf_tg
before insert or update
on peca
for each row
execute procedure controla_peso();

select * from peca;

insert into peca values(4, 'D', 199, 'Azul');
insert into peca values(5, 'E', 201, 'Azul');




-- Regra de negócio: não pode deixar vender/pedir itens cuja quantidade zere ou negative o estoque
create or replace function controla_estoque()
returns trigger
as
$body$
declare
	quantidade numeric;
begin
	select quantity into quantidade from stock
	where item_id = new.item_id;
	if(new.quantity >= quantidade) then
		raise exception 'Estoque insuficiente!';
	end if;
	return new;
end
$body$
language plpgsql;

create or replace trigger orderline_bf_tg
before insert
on orderline
for each row
execute procedure controla_estoque();

select * from stock;
select * from orderline;

insert into orderline values(1, 8, 18);




-- Exemplo auditoria
-- criando a tabela onde serão armazenadas as informações auditadas
create table AUDITORIA (
	ID SERIAL not null primary key,
	TABELA VARCHAR(50) not null,
	USUARIO VARCHAR(50) not null,
	data TIMESTAMP not null,
	OPERACAO VARCHAR(1) not null, -- I – INCLUSÃO, E – EXCLUSÃO, A - ALTERAÇÃO
	NEWREG text,
	OLDREG text
);

-- criando a função genérica de auditoria
create or replace function ft_auditoria()
returns trigger
as
$body$
begin
-- Cria uma linha na tabela AUDITORIA para refletir a operação
-- realizada na tabela que invoca a trigger.
 if (TG_OP = 'DELETE') then
 insert into auditoria(tabela, usuario,	data, operacao,	oldreg)
select
	TG_RELNAME,
	user,
	current_timestamp,
	'E',
	old::text;

return old;

elsif (TG_OP = 'UPDATE') then
 insert
	into
	auditoria(tabela,
	usuario,
	data,
	operacao,
	newreg,
	oldreg)
select
	TG_RELNAME,
	user,
	current_timestamp,
	'A',
	new::text,
	old::text;

return new;

elsif (TG_OP = 'INSERT') then
 insert
	into
	auditoria(tabela,
	usuario,
	data,
	operacao,
	newreg)
select
	TG_RELNAME,
	user,
	current_timestamp,
	'I',
	new::text;

return new;
end if;

return null;
-- o resultado é ignorado uma vez que este é um gatilho AFTER
end;

$body$
 language plpgsql;

-- auditando a tabela academico e a tabela uf
CREATE TRIGGER naturalidade_audit
AFTER INSERT OR UPDATE OR DELETE
on naturalidade
FOR EACH ROW
EXECUTE PROCEDURE ft_auditoria();

CREATE TRIGGER aluno_audit
AFTER INSERT OR UPDATE OR delete
ON aluno
for each row
EXECUTE PROCEDURE ft_auditoria();



select * from pg_catalog.pg_stat_activity;

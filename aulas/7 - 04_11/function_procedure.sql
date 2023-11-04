-- Aula 04/11/23
-- Programação em banco de dados

-- os códigos em banco não geram um binário
-- os códigos são compilados / interpretados e armazenados dentro do banco
-- por isso são chamados de stored procedures (inclui procedimentos e funções)
--- Funções tem retorno
--- Procedimentos não tem retorno

-- Triggers fazem uso de stored procedures
--- disparam quando algum evento ocorre e executam uma stored procedure



-- Há suporte para várias linguagens:
--- Postgresql: sql, plpgsql, pl/java, pl/python etc.
--- DLLs e SOs podem ser usadas no banco de dados



-- Vantagens de programar em banco:
--- Performance
--- Padronização dos códigos entre clientes/aplicativos

-- Desvantagem de programar em banco
--- Falta de padronização nas linguagens de um banco pra outro




-- PostgreSQL - plpgsql
--- função de multiplicação de números
create or replace function multiplicacao(num1 numeric, num2 numeric)
returns numeric
as
$body$
begin 
	return num1 * num2;
end
$body$
language plpgsql;

select multiplicacao(3,3);



-- função para remover acentos
create or replace function remove_acento(palavra varchar)
returns varchar
as
$body$
declare
	resultado varchar;
begin
	resultado := translate(palavra, 'ÁÃÂÀáãâà', 'AAAAaaaa');
	resultado := translate(resultado, 'ÉÊÈéêè', 'EEEeee');
	resultado := translate(resultado, 'ÍÎÌíîì', 'IIIiii');
	resultado := translate(resultado, 'ÓÒÕÔóòõô', 'OOOOoooo');
	resultado := translate(resultado, 'ÚÙÛúùû', 'UUUuuu');
	resultado := translate(resultado, 'Çç', 'Cc');
	return resultado;
end
$body$
language plpgsql;

select remove_acento('joão');

select remove_acento(nomdis) from disciplina;



-- enviando mensagem para o log/output do servidor
create or replace procedure mensagem_plpgsql(mensagem varchar)
as
$body$
begin 
	raise notice '%', mensagem;
end
$body$
language plpgsql;

-- para rodar procedure, usa-se call
call mensagem_plpgsql('Olá! Mensagem para o log do servidor.'); 



-- função para retornar dia da semana a partir de data
create or replace function diaSemana(data timestamp)
returns varchar
as 
$body$
declare
	dia integer;
	resultado varchar;
begin
    dia := extract(dow from data); -- dow -> day of week (0, 1, 2, ...)
	case dia
		when 0 then resultado := 'Domingo';
		when 1 then resultado := 'Segunda-feira';
		when 2 then resultado := 'Terça-feira';
		when 3 then resultado := 'Quarta-feira';
		when 4 then resultado := 'Quinta-feira';
		when 5 then resultado := 'Sexta-feira';
		when 6 then resultado := 'Sábado';
	end case;
	return resultado;
end
$body$
language plpgsql;


-- função para mostrar o dia em que nasceu
--- dois parâmetros + uso de outra function
create or replace procedure dia_nasceu(nome varchar, data timestamp)
as
$body$
declare
	resultado varchar;
begin
	resultado := diaSemana(data);
	raise notice '%, você nasceu no dia da semana: %!', nome, resultado;
end
$body$
language plpgsql;

call dia_nasceu('João', '10-03-2002');


-- Exemplo com laço de repetição
create or replace procedure diasChuva(dias integer)
as
$body$
declare
	i integer;
begin
	for i in 1..dias loop
		raise notice 'Chovendo, dia %', i;
	end loop;
end
$body$
language plpgsql;

call diasChuva(3);



-- criando função que calcula média das notas do histórico
create or replace function media_notas()
returns numeric
as 
$body$
declare
	soma numeric := 0;
	conta numeric := 0;
	h historico%rowtype;
begin
	-- loop for baseado no resultado de um select
	for h in (select * from historico) loop
		conta := conta + 1;
		soma := soma + h.vlrnot;
	end loop;
return soma / conta;
end
$body$
language plpgsql;

select media_notas();



create or replace procedure coronavirus(casos integer)
as
$body$
begin
	while (casos > 0) loop
		raise notice 'Número de casos de coronavírus: %', casos;
		casos := casos - 1;
	end loop;
end
$body$
language plpgsql;

call coronavirus(10);



-- Exercício: criar function que aumenta o preço de produtos
--- dois parâmetros: valor do produto e unidade de medida
--- A regra é:
---- KG - aumentar 5%
---- UN - aumentar 2%
---- PC - aumentar 10%
---- L - aumentar 1.8%
---- ML - aumentar 3.2%
--- aceitar informar unidades de medida em maiúsculo ou minúsculo
create or replace function aumento_preco_produto(valor numeric, unidade varchar)
returns numeric
as
$body$
declare
	resultado numeric;
begin
	case lower(unidade)
		when 'kg' then resultado := valor * 1.05;
		when 'un' then resultado := valor * 1.02;
		when 'pc' then resultado := valor * 1.1;
		when 'l' then resultado := valor * 1.018;
		when 'ml' then resultado := valor * 1.032;
		else raise exception 'Unidade de medida inválida!';
	end case;
	return resultado;
end
$body$
language plpgsql;

select aumento_preco_produto(10, 'mL');



-- função para contar registros de usuário
create or replace function conta_usuarios()
returns numeric
as
$body$
declare
	conta numeric := 0;
begin
	select count(*) into conta from usuario;
	return conta;
end
$body$
language plpgsql;

select conta_usuarios();



-- função para contar registros de tabelas
create or replace function conta_registros(tabela varchar)
returns setof record
as
$body$
declare
	tab varchar;
	conta numeric;
	rec record;
begin
	for tab in (
		select tablename from pg_tables
		where tablename ilike tabela and schemaname = 'public'
	) loop
		execute format('select count(*) from %I', tab) into conta;
		select tab, conta into rec;
		return next rec;
	end loop;
end
$body$
language plpgsql;

select * from conta_registros('usuario') as (tabela varchar, registros numeric);

select * from conta_registros('%%') as (tabela varchar, registros numeric);

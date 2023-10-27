-- Programação em banco
-- SQL e PLPGSQL


create function soma(num1 integer, num2 integer)
returns integer
as
'
	select num1 + num2;
'
language sql;

-- testando a função
select soma(2, 5);



create function soma(num1 numeric, num2 numeric)
returns numeric
as
$body$
	select num1 + num2;
$body$
language sql;

-- testando a função
select soma(0.75, 9.0);


-- pode-se usar replace para substituir uma função no lugar de criar uma nova
-- parâmetros da function podem ser não nomeados
create or replace function multiplica(numeric, numeric)
returns numeric
as
$body$
	select $1 * $2;
$body$
language sql;

-- testando função
select multiplica(2.3, 3);



-- PLPGSQL
-- soma utilizando PLPGSQL
create or replace function soma(num1 numeric, num2 numeric)
returns numeric
as
$body$
begin 
	return num1 + num2;
end
$body$
language plpgsql;

select soma(2.3, 6.8);


-- criando procedure para imprimir o nome
create or replace procedure bemvindo(nome varchar)
as
$body$
begin
	raise notice 'Seja bem-vindo, %', nome;
end
$body$
language plpgsql;

-- chamando procedure
call bemvindo('Ashuasa');



-- função para verificar se número é par
create or replace function ehPar(num integer)
returns varchar
as 
$body$
declare
	resultado varchar := '';
begin
    if (num % 2 = 0) then
        resultado := 'É par.';
    else
        resultado := 'Não é par.';
    end if;

    return resultado;
end
$body$
language plpgsql;

select ehPar(2);

select coddis, ehPar(coddis) from disciplina;


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

select diaSemana('26-10-2023');

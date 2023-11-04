-- 1
create or replace function calcula_cubo(num numeric)
returns numeric
as
$body$
begin
	-- return num * num * num;
	-- return power(num, 3);
	return num ^ 3;
end
$body$
language plpgsql;

select calcula_cubo(2);



-- 2
create or replace function raiz_quadrada(num numeric)
returns numeric
as
$body$
begin
	return sqrt(num);
end
$body$
language plpgsql;

select raiz_quadrada(81);



-- 3
create or replace function conta_vogais(string varchar)
returns integer
as
$body$
declare
	cont integer := 0;
	pos integer;
begin
	for pos in 1..char_length(string) loop
		if (substring(string from pos for 1) = any('{a, e, i, o, u, A, E, I, O, U}')) then
			cont := cont + 1;
		end if;
	end loop;
	return cont;
end
$body$
language plpgsql;

select conta_vogais('abc AEIOU teste vogais');



-- 4
create or replace procedure log_nome_idade(nome varchar, sobrenome varchar, datnas date)
as
$body$
declare
	idade integer;
begin
	idade := extract(year from current_date) - extract(year from datnas);
	raise notice '% %, sua idade é %', nome, sobrenome, idade;
end
$body$
language plpgsql;

call log_nome_idade('João', 'Paludo', '10-03-2002');



-- 5
create or replace function controle_notas()
returns trigger
as
$body$
begin
	if (new.vlrnot < 4) then
		raise exception 'A nota % é inválida. A nota deve ser maior ou igual a 4.', new.vlrnot;
	end if;
	return new;
end
$body$
language plpgsql;

create or replace trigger historico_bf_tg
before insert or update
on historico
for each row
execute procedure controle_notas();

select * from historico;

insert into historico values(3, 3, 3);

21/09/2023

# Tuning
- Também chamado de ajuste fino ou sintonia;

- Tuning é feito no banco de dados: ajustes no SGBD para melhor uso de resursos deste, logo melhor performance para a máquina específica onde o banco está. <br><br>

- Tuning requer conhecimento de:
    - desenvolvimento de aplicações
    - SGBD
    - Sistema operacional
    - Hardware

<br>

[PostgreSQL Tuning Configuration Calculator](https://pgtune.leopard.in.ua/)

<br><br>

# Otimização
- Melhorar o desempenho de consultas realizadas pelas aplicações

- Otimização do SQL

<br>

> Tradução do comando SQL alto nível passa por:<br>
> - Análise léxica
> - Análise sintática
> - Análise semântica

<br>

### Plano de execução do banco
Comando EXPLAIN: mostra o plano de execução definido pelo planejador do PostgreSQL elegeu para uma determinada consulta

Exemplo:<br>
EXPLAIN ANALYZE SELECT * FROM aluno;

<br><br>

# Índices
- Estrutura geralmente menor que a tabela onde é feita a busca inicialmente. Busca por uma **chave de pesquisa** para encontrar mais facilmente determinados registros, sendo mais performático (idealmente, mas o uso excessivo e indevido pode piorar a performance).

- Podem ser formados por um ou mais atributos

<br>

- Tipos de índices
    - **Primary index:** unique search keys in sorted order. Cannot be null. One to one relationship with data blocks.
        > A primary key é um índice do tipo primary index
    - **Clustered index:** por agrupamento. O arquivo de dados é ordenado por um campo não chave.
    - **Secondary index:** índice denso (uma entrada por valor da chave de busca) que mapeia valores de uma coluna não chave.

<br>

- Podem ser _densos_ ou _esparsos_
    - **Densos:** uma entrada no índice para cada valor da chave de busca
    - **Esparsos:** contém um par chave-ponteiro por bloco de dados (bloco geralmente tem o tamanho do bloco do disco)

<br>

### Comando
```SQL
CREATE [UNIQUE] INDEX nome_indice ON nome_tabela(nome_coluna[, ...]) [ASC | DESC];
```
<br>

Exemplo:
```SQL
CREATE INDEX FUN_NOMFUN_SK ON FUNCIONARIO(NOMFUN);
```
<br>

> Constraint unique é diferente de index unique

> A chave primária é o índice mais rápido para uma tabela

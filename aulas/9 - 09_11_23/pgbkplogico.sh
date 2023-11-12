#!/bin/bash

PATH=/usr/sbin:/usr/local/bin:/usr/bin:/bin
export PATH
inicio="`date +%Y-%m-%d_%H:%M:%S`"

#@ Variaveis
DIR=/home/postgres/backup/logico
ERRORLOG="$DIR/error.log"
ERROR=0;
PGUSER=postgres
PGPASSWORD=postgres
export PGUSER PGPASSWORD
PGPort="5432"

#@ Pega a lista de databases a "bk_piar" no arq de configuracao
DATABASES=(`cat $DIR/DBs.backup`)
if [ "$?" -ne 0 ]; then
echo "ERRO: arquivo de configuracao dos DataBases nao encontrado: 'DBs.backup'";
ERROR=1;
fi

#@ Para cada database da lista, executa o dump e compacta
cd $DIR
for((i=0; i < ${#DATABASES[@]}; i++))
do
echo ">>> dump DB ${DATABASES[$i]}"
/usr/local/pgsql/bin/pg_dump -p $PGPort -C -f ./db${DATABASES[$i]}.bkp ${DATABASES[$i]} 2> $ERRORLOG
if [ "$?" -ne 0 ]; then
echo "ERRO ao gerar dump DB $i: '${DATABASES[$i]}'";
ERROR=1;
fi
echo ">>> compactando dump do DB ${DATABASES[$i]}"
tar -cvzf db${DATABASES[$i]}-`date +"%y%m%d%H%M%S"`.tgz ./db${DATABASES[$i]}.bkp 2>> $ERRORLOG
if [ "$?" -ne 0 ]; then
echo "ERRO ao compactar DUMP do DB $i: '${DATABASES[$i]}'";
ERROR=1;
fi
done
cd $DIR
#@ Apaga os arquivos de backup e mantem apenas os arquivos compactados
rm *.bkp
#@ limpa os arquivos antigos, mantendo os ultimos 5 dias
find $DIR/ -name "*.tgz" -mtime +5 -type f -exec rm -f {} \;

echo "Rotina iniciou em: $inicio"
echo "Rotina terminou em: `date +%Y-%m-%d_%H:%M:%S`"

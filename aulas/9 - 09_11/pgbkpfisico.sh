#!/bin/bash

inicio="`date +%Y-%m-%d_%H:%M:%S`"
data="`date +%Y%m%d`"

service postgresql stop

tar -czf /home/postgres/backup/fisico/backup_$data.tar.gz /dados

service postgresql start

echo "Rotina iniciou em: $inicio"
echo "Rotina terminou em: `date +%Y-%m-%d_%H:%M:%S`"

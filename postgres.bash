DBNAME=pixeltable
export PGDATA=/state/partition1/user/$USER/pg_data2/
mkdir -p $PGDATA
pg_ctl init
createdb $DBNAME
pg_ctl start
psql -d $DBNAME -c "CREATE EXTENSION vector;"
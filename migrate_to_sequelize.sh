#!/bin/bash

# exit if an error occurs
set -e

PG_HOST="${DB_HOST:-db}"
PG_PORT="${DB_PORT:-5432}"
PG_USERNAME="${DB_USERNAME:-postgres}"
PG_DB="${DB_NAME:-postgres}"

# Path to which the full database dump will be written to
BACKUP_ALL_FILE=/data/backup/ohtuilmo.sql

# Path to which the temporary data dump will be written to.
# Removed after successfully migrating.
BACKUP_DATA_FILE=/tmp/ohtuilmo_data.sql

function do_migration() {
    echo 'Dropping existing database'
    # connect to the template1 database instead of $PG_DB because otherwise
    # we'll get "cannot drop the currently open database"
    psql --host="$PG_HOST" --port="$PG_PORT" --username="$PG_USERNAME" --dbname="template1" -c "DROP DATABASE $PG_DB";

    echo 'Creating new database'
    psql --host="$PG_HOST" --port="$PG_PORT" --username="$PG_USERNAME" --dbname="template1" -c "CREATE DATABASE $PG_DB";

    echo 'Created, migrating...'
    node_modules/.bin/sequelize db:migrate

    echo 'Database initialized, restoring data backup...'
    psql --host="$PG_HOST" --port="$PG_PORT" --dbname="$PG_DB" --username="$PG_USERNAME" -f "$BACKUP_DATA_FILE"

    echo "Database data restored. Removing temporary data dump ($BACKUP_DATA_FILE)."
    rm "$BACKUP_DATA_FILE"

    echo 'Migration complete!'
}

echo -e '\n'
echo -e "Backing up entire database to file ($BACKUP_ALL_FILE)..."
pg_dump --host="$PG_HOST" --port="$PG_PORT" --dbname="$PG_DB" --username="$PG_USERNAME" > "$BACKUP_ALL_FILE"

echo "Backing up database data to file ($BACKUP_DATA_FILE)..."
pg_dump --data-only --host="$PG_HOST" --port="$PG_PORT" --dbname="$PG_DB" --username="$PG_USERNAME" > "$BACKUP_DATA_FILE"

echo 'Backups have been made.'
echo 'Have you confirmed that the backup has succeeded and are you sure you want to migrate?'
read -p 'THIS OPERATION WILL DROP AND REBUILD THE ENTIRE DATABASE! Continue (y/n)? ' answer
case ${answer:0:1} in
    y|Y )
        do_migration
    ;;
    * )
        echo 'Migration cancelled.'
    ;;
esac
# ohtuilmo-init-migrations

Docker image for initializing Sequelize migrations on `ohtuilmo-backend`.

## Tags

`latest`

## Description

`ohtuilmo-backend` has previously initialized its database by allowing
Sequelize to `sync` its model definitions. Schema changes have previously
been rolled out by dropping tables.

Now that there's actual production data in the database, we need to be able to
run database migrations. However, in order to use Sequelize's migrations, we
need to run the first migration.

`ohtuilmo-init-migrations` will:

1. Back up all data in the database
2. Drop and re-create the table, then run the Sequelize migration
3. Restore data to database from backup

## Usage

1. Copy `docker-compose.migrate.yml` to the repos' parent directory, or wherever
   `docker-compose.yml` currently lives on the server
2. Make sure that the `db` service is up:
   ```
   docker-compose ps
   ```
3. Stop the backend service:
   ```
   docker-compose stop backend
   ```
4. Start our migration script from the other compose file:
   ```
   docker-compose -f docker-compose.migrate.yml run --rm migrate
   ```
5. After the script has finished creating database backups to the directory specified by the volume in `docker-compose.migrate.yml`, _verify that `/data/backup/ohtuilmo.sql` was created_ and that it contains the backup
6. Press `y` + `enter` to allow the script to start dropping tables and running migrations
7. ???
8. profit

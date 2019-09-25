# Container setup

## Images
* postgis: PostgreSQL 11 + 
    * PostGIS 2.5,
    * pgRouting 2.6,
    * gdal-bin 2.1.2, all from [PostgreSQL Global Development Group](https://wiki.postgresql.org/wiki/Apt),
    * r-base-dev from CRAN, and
    * R packages `acs`, `censusapi`, `data.table`, `RPostgres`, `sf`, `sp`, `tidycensus`.
* pgadmin4: minor extensions of [official pgAdmin4 image](https://hub.docker.com/r/dpage/pgadmin4/)

## Quick start
1. Clone <https://github.com/hackoregon/opportunity-project-data-wrangling.git> and `cd` into `containers`.
2. Copy `sample.env` to `.env`, then ***change all the passwords in `.env`***.
3. Type `docker-compose up -d`. This will
    * build / rebuild the images if you don't have them,
    * create the Docker network `containers_default`,
    * create and start the containers `containers_postgis_1` and `containers_pgadmin4_1` in the background ("detached").
    
    The `postgis` service is listening inside the Docker network on port 5439 and in the host on ***<http://localhost:5439>***, not the PostgreSQL default, port 5432. This avoids port conflicts with any PostgreSQL services you may already have running using the default port. The `pgadmin4` service is listening on <http://localhost:8686>.
    
## Using `pgadmin4`
Log in with the email address and password you set for `pgadmin4` in `.env`. Then, click on the `Servers` tab in the tree on the left panel. It will ask you for the `postgres` password you set in `.env`. Then it will connect to the `postgis` container.

## Using the `postgis` command line
To run PostgreSQL command-line utilities like `psql`, `pg_dump`, `createuser`, etc., log in as `postgres`:

```
docker exec -it -u postgres containers_postgis_1 /bin/bash
```

Remember that PostgreSQL is listening on port 5439, not 5432.

To log in as `root`:
```
docker exec -it -u root containers_postgis_1 /bin/bash
```

## Stopping and restarting the services
To stop the services, type `docker-compose stop`. To start them back up again, type `docker-compose start`.

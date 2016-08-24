## Description

Alpine linux based mariadb image.

## Usage

### Start a Server Instance

Basic usage is simple, use the image as if you are running mysqld_safe.
```
docker run --name=mariadb taosnet/mariadb
```
In this form, the root password will be set to a randomly generated password that will be output to stdout on the container. You can change the password by running:
```
docker exec -ti mariadb /usr/bin/mysqladmin -h localhost -p'randomPassword' password 'newPassword'
```

Alternatively you can set the root password with an environmental variable **MYSQL_ROOT_PASSWORD** on startup:
```
docker run --name=mariadb -e MYSQL_ROOT_PASSWORD='myPassword' taosnet/mariadb
```

### Connect From Another Container

You can connect to your server instance by linking the server container to your app:
```
docker run --name=myapp --link mariadb:db taosnet/myapp
```

## Environment Variables

#### MYSQL_ROOT_PASSWORD

This variable specifies the root password for the database. If not specified, a random password will be generated as the root password and output to stdout.

#### MYSQL_DATABASE

If present, intialize a database with the name given in this variable.

#### MYSQL_USER

Database user to create with access to the initialized database. Both **MYSQL_DATABASE** and **MYSQL_PASSWORD** must be present in addition to **MYSQL_USER** for the user to be created. If either of them are missing, this variable is ignored. If **MYSQL_HOST** is specified, then the user's access is restricted to that host. Otherwise the user's access is restricted to localhost.

#### MYSQL_PASSWORD

The database password for the user specified by **MYSQL_USER**. See conditions above. If the conditions are not met, this variable is ignored.

#### MYSQL_HOST

Host to restrict **MYSQL_USER** to. If **MYSQL_USER** is not create, this variable is ignored.

## Initializing With Data

You can initialize the container with data located in /docker-entrypoint-initdb.d. The files should have the extension **.sql** and contain valid SQL statements. The files are run in alphabetical order as determined by the ls command.

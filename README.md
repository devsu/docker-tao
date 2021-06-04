# docker-tao
Docker images for building and running [TAO Assessment Platform](https://www.taotesting.com/)

## Usage

The image is published in docker hub at devsu/tao. The easiest way to run tao is using docker-compose. 

1. Clone this repo (or just copy the files in the `example` folder).
2. Modify the `tao/docker-compose.yml` and `tao/nginx` according to your needs.
3. Then just run `docker-compose up` from the `example` folder.

Then just head to http://localhost to start installation.

At installation make sure that you choose the following folder to store data: `/var/lib/tao/data`. As you can see in `Dockerfile`, a volume has been defined for this folder. 

Since this folder is created only in the `tao` image, it won't be accessible by the `web` container, which is good for security reasons.

If you don't want to use docker-compose, you can also install and run TAO using the following command:

docker run --env DB_HOST=https://example.org --env DB_NAME=myDB --env DB_USER=myDBUser --env DB_PASSWORD=myDBPass --env USER=myTaoAdminUser --env PASSWORD=myTenLengthAlfanumericTaoAdminPassword devsu/tao

It's necessary to define the next environment variables:

- DB_HOST: Database location. You can use a hostname like localhost or an IP address like 127.0.0.1.
- DB_NAME: Name of the database used to store data from TAO platform.
- DB_USER: Login to access to database.
- DB_PASSWORD: Password to access to database.
- USER: The login of the administrator to be created.
- PASSWORD: The password of the administrator. This password must alphanumeric with 10 characters length.

Other enviroment variables that you can define are:

- FILE_PATH: Path to where asset files should be stored. The default is /var/lib/tao/data.
- DB_DRIVER: Driver engine to connect TAO platform with a database. The default is pdo_mysql. You must add other engines as pdo_pgsql, pdo_sqlsrv or pdo_oci in the docker file in order to use it.
- DB_PORT: Network port used to connect database host. The default is 3306.
- URL: The URL to access to platform from web browser. The default is http://localhost but you use it other with https protocol once you defined in DNS configuration.

The image is using docker-compose-wait (https://github.com/ufoscout/docker-compose-wait/) in order to wait until have a successfull database connection and proceed to install the platform. The environment variables that we can define for this tool are:

- WAIT_HOSTS_TIMEOUT: Max number of seconds to wait for all the hosts/paths to be available before failure. The default is 30 seconds.
- WAIT_SLEEP_INTERVAL: Max number of seconds to sleep between retries. The default is 1 second.
- WAIT_HOST_CONNECT_TIMEOUT: The timeout of a single TCP connection to a remote host before attempting a new connection. The default is 5 seconds.

WAIT_HOSTS is the main variable used for docker-compose-wait to know which hosts needs to wait, but our image build this variable automatically from DB_HOST and DB_PORT variables.

## Approach

The `tao` image is built using [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/).

- The **builder** image downloads the code and install all required packages
- The **runner** image copies the code generated by the builder and installs the runtime dependencies.

The runner is a `php-fpm` image, and thus it requires a **nginx** instance in front of it to serve the application.

The `example/docker-compose.yml` shows how to use it. It defines 2 services:

- **tao**: The container that will run the application.
- **web**: An nginx web server.

Both images share a named volume, which contain the application code.

All images are built in top of Linux alpine, to avoid issues of different ids for the `www-data` user. 

## Building TAO

As you can see in the Dockerfile, TAO is built from the source code releases at https://github.com/oat-sa/package-tao/releases.

It's published in docker-hub at https://hub.docker.com/repository/docker/devsu/tao, but if you want, you can build it yourself. 

```
docker build --target builder -t tao
```

TAO platform is configured to use the latest tao version at moment, but you can easily change the version by passing the `TAO_VERSION` argument.

```
docker build --target builder -t tao --build-arg TAO_VERSION=3.3-rc02
```

The version must match the version used in the name of the source code zip file.

## Development

If you want to test the docker files as you change them, you need to use the `docker-compose-dev.yml` file instead. 

```
docker-compose -f docker-compose-file-dev.yml up --build 
```

## Credits

Thanks to [Open Assessment Technologies](https://www.taotesting.com/about-us/) for the awesome work, and for sharing it with the world.

Inspired on https://github.com/Alroniks/docker-tao.

This repo is maintained by Devsu, and it's used to take assessments to [find the best software developers](https://devsu.com/about-us/).

## License

MIT License - Copyright (c) 2020 Devsu LLC.

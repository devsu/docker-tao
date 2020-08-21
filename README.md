# docker-tao
Docker images for building and running [TAO Assessment Platform](https://www.taotesting.com/)

## Usage

The easiest way to run tao is using docker-compose. 

1. Clone this repo (or just copy the files in the `tao` folder).
2. Modify the `tao/docker-compose.yml` and `tao/nginx` according to your needs.
3. Then just run `docker-compose up` from the `tao` folder.

Then just head to http://localhost to start installation

At installation make sure that you choose the following folder to store data: `/var/lib/tao/data`. As you can see in `php-fpm/Dockerfile`, a volume has been defined for this folder. 

Since this folder is created only in the `php-fpm` image, it won't be accessible by the `web` container, which is good for security reasons.

## Approach

All the images are built in top of alpine, to avoid issues of different ids for the `www-data` user.

The `docker-compose.yml` file defines 3 services:

- **code**: A container that has the application code built from the source code
- **php-fpm**: The container that will run the application
- **web**: An nginx web server

The three of them share a named volume, which contain the application code. 

## Building TAO

The Dockerfile at the `builder` folder builds TAO from the source code releases at https://github.com/oat-sa/package-tao/releases.

It's published in docker-hub at ... , but if you want, you can build it yourself. 

```
docker build -t tao-code -f builder/Dockerfile
```

It's configured to use the latest tao version at moment, but you can easily change the version by passing the `TAO_VERSION` argument.

```
docker build -t tao-code -f builder/Dockerfile --build-arg TAO_VERSION=3.3-rc02
```

The version must match the version used in the name of the source code zip file.

## Development

If you want to test the docker files as you change them, you need to use the `docker-compose-dev.yml` file instead. 

```
docker-compose up --build -f docker-compose-file-dev.yml 
```

## Credits

Thanks to [Open Assessment Technologies](https://www.taotesting.com/about-us/) for the awesome work, and for sharing it with the world.

The `php-fpm` and `nginx` images were heavily inspired on https://github.com/Alroniks/docker-tao.

This repo is maintained by Devsu, and it's used to take assessments to [find the best software developers](https://devsu.com/about-us/) for the US market.

## License

MIT License - Copyright (c) 2020 Devsu LLC

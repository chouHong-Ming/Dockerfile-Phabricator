# Dockerfile-Phabricator
Use to build the image for the Phabricator Server

## Description
An container image for running Phabricator server and let you can make the version-control service containerize. This image is include the Nginx server, the SSH server and the Phabricator service. You need to prepare the MySQL database, the storage and the SMTP account to start this service.

## Run
### Docker
You can run the image by using `docker` command. To use `-p` option to expose the service.

`docker run -p 22:22/tcp -p 80:80/tcp chouhongming/phabricator`

Also, you must use `-v` option to mount the configure file and the data file if you have your own Nginx settings and you want to keep everything.

`docker run -p 22:22/tcp -p 80:80/tcp -v ./nginx_conf:/etc/nginx/conf.d/add_conf -v ./repo:/var/repo -v ./upload:/var/www/html/phabricator/webroot/upload -v ./server_key:/server_key chouhongming/phabricator`

### Docker Compose
You can use the `docker-compose.yml` file to run the service easily. Due to the different directory structure, you may need to change your working directory to example directory or use `-f` option to start the service.

`docker-compose -f example/docker-compose.yml up -d`

The command for stopping the service, if you use `-f` option to start the service.

`docker-compose -f example/docker-compose.yml down`

And you can use exec action to login to the container to run the command that you want.

`docker-compose -f example/docker-compose.yml exec core bash`

If you want to rebuild the image, you can replace `image: chouhongming/phabricator:latest` with `build: ..` and run the `docker-compose` with `--build` option, for example:

```
version: "3.7"
services:
  core:
    build: ..
    ports:
      - "22:22/tcp"
      - "80:80/tcp"
```

`docker-compose -f example/docker-compose.yml up -d --build`


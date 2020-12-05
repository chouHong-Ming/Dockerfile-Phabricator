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

### Kubernetes
You can copy the `k8s-resource.yml` file and do the following step to let the setting be correct:
1. To replace the word `[YOUR_K8S_NAMESPACE]` with the namespace that you want to apply the service.
2. To replace the word `[YOUR_NFS_PATH]` and `[YOUR_NFS_ADDRESS]` with your NFS setting. If you don't use NFS as your _PersistentVolume_, you can replace `nfs` section with your storage setting.
    ```yaml
      nfs:
        path: [YOUR_NFS_PATH]
        server: [YOUR_NFS_ADDRESS]
    ```
3. To replace the word `[YOUR_DB_ADDRESS]`, `[YOUR_DB_USER]` and `[YOUR_DB_PASSWORD]` with your database connection information. `[YOUR_DB_ADDRESS]` can be the IP address, the domain or the Kubernetes service name.
4. To replace the word `[YOUR_EMAIL_USER]` and `[YOUR_EMAIL_PASSWORD]` with your SMTP account credential.
5. If you also use Traefik 2.0+ as your Kubernetes ingress controller, you can replace the word `[YOUR_HTTPS_REDIRECT_MIDDLEWARE]` and `[YOUR_RESOLVER_NAME]` with your middleware of HTTPS redirector and your cert resolver. Or you can delete the yaml section of the two IngressRoute and add the new one to fit your ingress controller. Also you can delete the yaml section of the IngressRoute is called `phab-websecure` and the following scetion in the `phab-web` IngressRoute section, if you don't want to use HTTPS.
    ```yaml
        middlewares:
        - name: [YOUR_HTTPS_REDIRECT_MIDDLEWARE]
    ```

After your done the `k8s-resource.yml` file, you can apply to the Kubernetes cluster.

`kubectl apply -f k8s-resource.yml`

## Volume
- /etc/nginx/conf.d/add_conf

    To import the additional Nginx config such as IP ACL, log format, etc. If you want to use the additional Nginx config, you can put the conf here and mount to this path, and the config will be enabled automatically. Please note that the config is checked carefully, if there are any errors in the config, the Nginx will run fail.

- /var/repo/

    To save the repo persistently.

- /var/www/html/phabricator/webroot/upload/

    To save the uploaded file persistently.

- /server_key/

    To save the server key persistently and avoid the entry point script create a new key again.

## Environment
- HOST_NAME=test.local

    The domain of the Phabricator server. The default value is `test.local`, it's just for testing.

- HTTPS_ENABLE=true

    The setting to let Phabricator return the URL with the HTTPS protocol when you use the HTTPS protocol to connect and you set this value as `true`.

- UPSTREAM=127.0.0.1

    The upstream server address for Nginx. This setting is just used to the situation that the Nginx server and the Phabricator service _are not_ work in the same container, so just keep the value in `127.0.0.1`.

- TRUST_LAYER=0

    The HTTP X-Forwarded_For header trusts the amount of layer. If you set it as 0, that means not trust the X-Forwarded_For header. And setting this value to 1 means trust 1 layer, 2 for 2 layers, and so on.

- MYSQL_HOST=database

   The address of the MySQL server. This value can be the IP address, the domain or the Kubernetes service name.

- MYSQL_PORT=3306

    The port of the MySQL server.

- MYSQL_USER=root

    The user name of the account to connect to the MySQL server.

- MYSQL_PASS=password

    The user password of the account to connect to the MySQL server.

- TIMEZONE=UTC

    The value is uesd to set the timezone to Phabricator.

- MAILERS_KEY=SMTP

    The name of the default mailer in Phabricator.

- MAILERS_HOST=smtp.gmail.com

    The SMTP server's address of the default mailer in Phabricator.

- MAILERS_PORT=465

    The SMTP server's port of the default mailer in Phabricator.

- MAILERS_USER=your-email@gmail.com

    The user name of the account to connect to the SMTP server in the Phabricator default mailer.

- MAILERS_PASS=your-password

    The user password of the account to connect to the SMTP server in the Phabricator default mailer.

- MAILERS_PROT=SSL

    The SMTP server's port of the default mailer in Phabricator.


# WARNING: This repository has been archived. Support for official Docker images of Payara Micro Community Edition has been moved to its main repository: https://github.com/payara/Payara

Updated repository for Payara Dockerfiles. This repository is for [Payara Micro](http://www.payara.fish/payara_micro) runtime.

# Supported tags and respective `Dockerfile` links

-	[`latest`](https://github.com/payara/docker-payaramicro/blob/master/Dockerfile)
  - contains latest released version of Payara Micro based on JDK8
-       [`jdk11`](https://github.com/payara/docker-payaramicro/blob/jdk11/Dockerfile)
  - contains latest released version of Payara Micro based on JDK11
-	[`prerelease`](https://github.com/payara/docker-payaramicro/blob/prerelease/Dockerfile)
  - contains nightly build of Payara Micro from the master branch (updated daily)
-	[other tags](https://hub.docker.com/r/payara/micro/tags/) correspond to past releases of Payara Micro matched by short version number

# Usage

## Quick start

To start the docker container and run Payara Micro:

```
docker run -p 8080:8080 payara/micro
```

It runs Payara Micro without any applications, therefore accessing the HTTP server bound to port 8080 will just return HTTP code 404 - Not Found.

You need to add your applications to the container and deploy them.

## Open ports

Most common default open ports that can be exposed outside of the container:

 - 8080 - HTTP listener
 - 8443 - HTTPS listener
 - 6900 - Hazelcast cluster communication port

## Application deployment

Payara Micro deploys applications during startup, according to provided command-line arguments. It does not open any port to deploy applications during runtime on request.

There are number of ways how you can run your applications with Payara Micro within docker:

 - load applications from a mounted file-system (from a disk on the host system or on network)
 - derive a new docker image that also contains your applications on the file-system
 - load applications from a maven repository accessible from the dockar container

### Run from a mounted volume

Once we mount a volume that contains our applications, Payara Micro can access the applications and run them through the local file-system.

The docker image already contains `/opt/payara/deployments` directory, which can be bound to a directory with your applications.

The following command will run Payara Micro docker container and will deploy applications that exist in the directory `~/payara-micro/applications` on the host file-system:

```
docker run -p 8080:8080 \
 -v ~/payara-micro/applications:/opt/payara/deployments payara/micro
```

To run a specific application within the directory, you can modify the default entry point and use `--deploy` option followed by path to the application file:

```
docker run -p 8080:8080 \
 -v ~/payara-micro/applications:/opt/payara/deployments \
 payara/micro \
 --deploy /opt/payara/deployments/myapplication.war
```

### Build a new docker image to run your application

You can extend the docker image to add your deployables into the `/opt/payara/deployments` directory and run the resulting docker image instead of the original one.

The following example Dockerfile will build an image that deploys `myapplication.war` when Payara Micro is started:

```
FROM payara/micro

COPY myapplication.war $DEPLOY_DIR
```

### Run from a maven repository

If your application is already in a maven repository, you can run it with Payara Micro in the docker very easily. Payara Micro knows how to download an artifact from a maven repository and run it directly. You just need to provide an alternative entry point

The following command runs Payara Micro in the docker image and runs an application stored in a maven repository. The application group is `fish.payara.examples`, artifact name is `my-application`, and version is `1.0-SNAPSHOT`. The maven repository is available on host `172.17.0.10`:

```
docker docker run -p 8080:8080 payara/micro \
 --deployFromGAV "fish.payara.examples:my-application:1.0-SNAPSHOT" \
 --additionalRepository https://172.17.0.10/content/repositories/snapshots
```

### Define context root

> Since Payara Micro 5.191

The context root of the deployed application(s) is determined based on the file name of the artifact which is deployed. Form Payara Micro version 5.191 on, you can explicitly define the value of the context root using the `--contextroot` option, including deploying the application on the root itself ( `/`, specify **ROOT** as option value).  

Some examples of how it can be used :

```
docker run -p 8080:8080 \
 -v ~/payara-micro/applications:/opt/payara/deployments payara/micro  \
 --deploymentDir /opt/payara/deployments  \
 --contextroot myRoot
```

Deploys the (first) application within the mounted directory _~/payara-micro/applications_ under the root context _/myRoot_.

```
docker run -p 8080:8080 \
 -v ~/payara-micro/applications:/opt/payara/deployments \
 payara/micro \
 --deploy /opt/payara/deployments/myapplication.war \
 --contextroot ROOT
```

Deploys the _myapplication.war_ to the root.

```
FROM payara/micro

COPY myapplication.war $DEPLOY_DIR

CMD ["--deploymentDir", "/opt/payara/deployments", "--contextroot", "my"]
```

Creates a new Docker Image which results in the deployment of the _myapplication.war_ under the root context _/my_.

# Speeding up Boot by disabling the Data Grid

By default the image has the Data Grid enabled and instances of Payara Micro will form a Data Grid if they can see each other over multicast. Typically this will occur on a single host. 

To speed up boot time the Data Grid can be disabled by modifying the CMD to add `--nocluster`

# Details

Payara Micro JAR file `payara-micro.jar` is located in the `/opt/payara/` directory. This directory is the default working directory of the docker image. The directory name is deliberately free of any versioning so that any scripts written to work with one version can be seamlessly migrated to the latest docker image.

- Full and Web editions are derived from the OpenJDK 8 images with a Debian Jessie base
- Micro editions are built on OpenJDK 8 images with an Alpine Linux base to keep image size as small as possible.

Payara Server is a patched, enhanced and supported application server derived from GlassFish Server Open Source Edition 4.x. Visit [www.payara.fish](http://www.payara.fish) for full 24/7 support and lots of free resources.

Payara Micro is a small and simple to use runtime based on Payara Server Web Profile that enables you to run applications from the command line without any application server installation.

Full Payara Server and Payara Micro documentation: [https://payara.gitbooks.io/payara-server/content/](https://payara.gitbooks.io/payara-server/content/)

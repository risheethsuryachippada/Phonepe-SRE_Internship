# Docker 

The fundamental difference between Containers and Virtual Machines is that containers don’t contain a hardware hypervisor and is directly placed on top of a Host OS upon Infrastructure.

- **Docker Image Repositories** — A Docker Image repository is a place where Docker Images are actually stored, compared to the image registry which is a collection of pointers to this images.

- **Working With Dockerfiles** — The Dockerfile is essentially the build instructions to build the Docker image.

- **Working With Docker Hub** — Docker Hub is a cloud-based repository in which Docker users and partners create, test, store and distribute container images.


>## Docker Images

A [**Docker**](https://www.aquasec.com/wiki/display/containers/Docker+Containers) image is a **snapshot**, or template, from which new containers can be started. 

It is made up of a collection of files that bundle together all the essentials – such as **installations,** **application code**, and **dependencies** – required to configure a fully operational container environment. 

A new image can be created by executing a set of commands contained in a **Dockerfile**.

- To create a Docker image, a **Dockerfile** is used. A Dockerfile is a text document, usually saved in **YAML** format. It contains the list of commands to be executed to create an image.

### DockerFile & lmage-Layers

A Docker image is built up from a series of layers. Each layer represents an instruction in the image’s Dockerfile. Each layer except the very last one is read-only.

4 Layers of Image
1. `FROM` statement starts out by creating a layer from the **base/parent** image. 
2. `COPY` command adds some files from your Docker client’s current directory. 
3. `RUN` command builds your application using the `make` command. 
4. Finally, the last layer specifies what command to run within the container using `CMD`.

The layers are stacked on top of each other. When you create a new container, you add a new **writable layer** on top of the underlying layers. This layer is often called the “container layer”.When the container is deleted, the writable layer is also deleted. The underlying image remains unchanged.

Multiple containers can share access to the same underlying image and yet have their own data state.

![](https://docs.docker.com/storage/storagedriver/images/sharing-layers.jpg)

Commands in Dockerfile

- `FROM` instruction initializes a new build stage and sets the [_Base Image_](https://docs.docker.com/glossary/#base_image) for subsequent instructions.`Dockerfile` must start with a `FROM` instruction.
- The `RUN` instruction will **execute any commands in a new layer on top of the current image and commit the results**. 
- **The main purpose of a  `CMD`  is to provide defaults for an executing container.** There can **only be one `CMD` instruction** in a `Dockerfile` or only last line in multiple.
- The `EXPOSE` instruction **informs Docker that the container listens on the specified network ports at runtime**. TCP or UDP, By default ->TCP . But you require **`-p`** on `docker run` to publish and map one or more ports.
- The **`ENV` instruction sets the environment variable** `<key>` to the value `<value>`.
- **`COPY` instruction copies new files or directories** from `<src>` and adds them to the filesystem of the container at the path `<dest>`.The `<dest>` is a path relative to `WORKDIR`, into which the source will be copied inside the destination container.`WORKDIR/dest`
- **`WORKDIR` instruction sets the working directory** for any `RUN`, `CMD`, `ENTRYPOINT`, `COPY` and `ADD` instructions

Example Dockerfile:-
```dockerfile
FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
FROM ubuntu
RUN ["/bin/bash", "-c", "echo hello"]
CMD ["/usr/bin/wc","--help"]
EXPOSE 80/tcp
EXPOSE 80/udp
COPY <file> <containerfile>
```
Flask Dockerfile:-
```dockerfile
FROM python:3.8-slim-buster
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
```

Images are executed to create docker containers. A container is just a **run-time instance** of a particular image.

>Containers

Containers can package up all the system components you need to run your code without the bloat of a full-blown OS.

![User-added image](https://lh3.googleusercontent.com/guEcIQ8rmHR0S29wqoqv9Vs_Qz5T8JWckynh5Z4_EVfZOLSpUyZ-w_fexPhZlgGC1T6mT0oJZScTky7co6yrDVyvY0gp_gxtOj1omsEyicTkdp9m1DmhGnVLFr1yVsev7AvHG2s)

## Image Creation

1. **Build  a new image from a Dockerfile**
```bash
docker build -t <image>:<tag> <path>
```
- -t : adds a tagname, tag -> commit version

2. **List all docker images**
- Displays all the docker images
- The filtering flag (`-f` or `--filter`) such as `"dangling=true"` which gives the dangling images such `<none>`
- Filtering with `before=<image>` & `since=<image>` as it depends on time.
- Docker digest is provided as a hash of a Docker image supported by the Docker v2 registry format.`--digest`
- Formatting display flag(`--format`) along with ID , Repository , Size
```bash
docker images
docker images --format "{{.ID}}: {{.Repository}}"
```

3. **Run the docker images and create containers**
	- Creates & Starts the container based on your image.
	- You can run the container as `-d` is daemon `-p` for port `localhost_port:service_port` along with giving the docker container name
```bash
docker run image:tag 
docker run -d -p 80:5000 --name <container_name> <image>
```
4. **Stop the docker process and check process**
	- We can check the active process.
	- List all the process which including the dead ones and can restart them.
	- Stop the a current process.
```bash
docker ps
docker ps -a
docker restart <container>
docker stop <container>
```

## **Docker Hub**

-   **Tagging an existing image**: You assign tags to images as the version of an image they are pulling from a repository. The command to tag an image is `docker tag` 
```bash
docker tag <image> username/my_repo:``<tag>`
```
-   **Pulling a new image from a  Docker Registry**: To pull an image from a registry, use `docker pull` and specify the repository name. default -> latest version 
```bash
docker pull /my_repo:`<tag>`
```
-   **Pushing a local image to the Docker registry**: You can push an image to Docker Hub by running the `docker push` command.  
```bash
docker push username/my_repo
```
-   **Searching for images**: You can search the Docker Hub for images relating to specific terms using `docker search`. 
```bash
docker search repo:`<tag>`
```
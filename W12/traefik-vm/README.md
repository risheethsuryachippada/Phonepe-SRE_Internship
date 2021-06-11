# Traefik

- Do till step-2 of the following post
https://www.linuxtechi.com/setup-traefik-docker-containers-ubuntu/ with some modifications.

- Add providers

> Note: Provide the ip of mesos master. The pilot part is optional.
```
[providers.marathon]
endpoint = "http://<mesos-master-ip>:8080"
exposedByDefault = true
watch = true
respectReadinessChecks = true
```

run the container using:

```
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v $PWD/traefik.toml:/etc/traefik/traefik.toml -p 8080:8080  -p 80:80  --name traefik  traefik:v2.4
```

```
root@traefik:/# docker ps -a
```
```
CONTAINER ID   IMAGE          COMMAND                  CREATED       STATUS        PORTS                                                                      NAMES
f4592e47dc45   traefik:v2.4   "/entrypoint.sh trae…"   2 weeks ago   Up 14 hours   0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp   traefik
```
```
root@traefik:/# docker images
```
```
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
traefik      v2.4      deaf4b1027ed   8 weeks ago   91.3MB
```

<br>

### HELPFUL COMMANDS:
<br>

To run a shell inside the container to access logs at /var/log/traefik/access.log

```
docker exec -it traefik2 /bin/sh
```


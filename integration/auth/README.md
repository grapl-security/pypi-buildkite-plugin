# PyPIServer Authentication

Our testing instance of [pypiserver][pypi] uses [`htpasswd`][htpasswd] files
to manage authentication.

The file we use is in this directory, and is mounted into a
`pypiserver` container, defined in
[`docker-compose.yml`](../docker-compose.yml).

The file was created with the following command, run from this
directory:

```shell
docker run \
    --rm \
    --entrypoint=htpasswd \
    -- \
    httpd:2.4-alpine3.15 -Bbn PyPIUser sooperseekrit \
> .htpasswd
```

Thus, it creates a single entry for a user named `PyPIUser`, with a
password of `sooperseekrit`. Use these credentials to make
authenticated interactions with the server.

[pypi]:https://github.com/pypiserver/pypiserver
[htpasswd]:https://httpd.apache.org/docs/2.4/programs/htpasswd.html

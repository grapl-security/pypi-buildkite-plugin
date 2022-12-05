# PyPI Buildkite Plugin

:warning: **Sunsetting This Repository** :warning:

Work has stopped on this plugin. The repository will still be
available in an archived state, but users are encouraged to either
fork a copy or find alternatives. The `twine` container image we
provided will no longer be available, but you can use an alternative
or build your own from this repository (the `ENTRYPOINT` _must_ be
`twine`). If you continue using the code from this repository, you
will need to specify an `image` in your plugin configuration (see
below).

Uploads Python packages to [PyPI](https://pypi.org) or other
compatible repositories using
[twine](https://twine.readthedocs.io/en/stable/). Because it uses a
container image, you do not need to have `twine` (or even Python
itself!) installed on your build agents to use this plugin.

## Examples

This minimal configuration will upload all distributions in `dist` to
PyPI, assuming that the value stored in `PYPI_API_TOKEN` is, well, a
PyPI API token.

(You will need to build the Python distributions in a separate job,
since this plugin runs a `command` hook. This allows you to perform
tests on the built artifact, which is one of the motivations for
`twine` in the first place. Here, we show an example of this, but
subsequent examples will omit this for brevity.)

```yml
steps:
    - label: ":python: Build Python Distribution"
      command: "scripts/build_python_distribution.sh"
      artifact_paths:
        - "dist/*"

    - wait

    # Test your artifact!

    - wait

    - label: ":python: Upload to PyPI"
      plugins:
        - artifacts#v1.5.0:
            download: "dist/*"
        - grapl-security/pypi#v0.1.0:
            file: "dist/*"
            image: "docker.mycompany.com/twine"
      env:
        - PYPI_API_TOKEN
```

You can upload to a different repository, such as
[Cloudsmith](https://cloudsmith.io), by overriding the connection
parameters like so:

```yml
steps:
    - label: ":python: Upload to Cloudsmith"
      plugins:
        - grapl-security/pypi#v0.1.0:
            file: "dist/*"
            image: "docker.mycompany.com/twine"
            repository-url: "https://python.cloudsmith/my-organization/my-repo"
            username: "my-cloudsmith-username"
            password-envvar: "CLOUDSMITH_API_TOKEN"
      env:
        - CLOUDSMITH_API_TOKEN
```

By default, `twine check` is run _before_ `twine upload`, but this
behavior can be disabled if you choose:

```yml
steps:
    - label: ":python: Upload to PyPI"
      plugins:
        - grapl-security/pypi#v0.1.0:
            file: "dist/*"
            image: "docker.mycompany.com/twine"
            check: false
      env:
        - PYPI_API_TOKEN
```

If using the `latest` tag of the image, it can be useful to explicitly
pull the image before running. Since the `latest` tag will change over
time, this ensures that you always get the _actual_ latest
image. While this is generally not a problem if you are using
short-lived or single-use agents, longer-lived agents would continue
to use whatever image was tagged `latest` when they uploaded their first
Python distribution.

To explicitly pull the image, set `always-pull` to `true`.

```yml
steps:
    - label: ":python: Upload to PyPI"
      plugins:
        - grapl-security/pypi#v0.1.0:
            file: "dist/*"
            image: "docker.mycompany.com/twine"
            tag: "latest"
            always-pull: true
      env:
        - PYPI_API_TOKEN
```

## Configuration

Configuration files are organized by thematic category.

### `twine` Arguments

#### `file` (required, string)

The Python distribution to upload. Can be a specific file or a glob
(such as `dist/*`), but note that this is _not_ an array.

Corresponds to the positional argument of `twine upload`.

#### `repository-url` (optional, string)

The repository to upload the Python distribution to. Corresponds to
the `--repository-url` option of `twine upload`.

If unspecified (the default), packages will be uploaded to PyPI.

#### `username` (optional, string)

The user whose credentials are used to upload the Python
distribution. Corresponds to the `--username` option of `twine
upload`.

Defaults to `__token__` on the assumption that [PyPI API
tokens](https://pypi.org/help/#APIs) are being used. If you are not
uploading to PyPI, you may need to override this; consult your
repository's documentation for further details.

#### `password-envvar` (optional, string)

The _name_ of an environment variable that holds the password / token
to authenticate to the repository. This should **not** contain the
_actual_ password. If the specified variable is not present, an error
is raised.

The password will be passed as an environment variable to `twine
upload`, and will not be present in the executed command, or logged.

Corresponds to the `--password` option / `TWINE_PASSWORD` environment
variable for `twine upload`.

Defaults to `PYPI_API_TOKEN`.

#### `check` (optional, boolean)

Indicates whether or not to run [`twine
check`](https://twine.readthedocs.io/en/stable/#twine-check) prior to
uploading the Python distribution files. If `twine check` fails, the
upload will not be performed and the job will fail.

Defaults to `true`.

### Container Image Configuration

#### `image` (required, string)

The container image with the `twine` binary that the plugin uses. Any
container used should have `twine` as its entrypoint.

#### `tag` (optional, string)

The container image tag the plugin uses.

Defaults to `latest`.

#### `always-pull` (optional, boolean)

Whether or not to perform an explicit `docker pull` of the configured
image before running. Useful when using the `latest` tag to ensure you
are always using the _actual_ latest image.

Defaults to `false`.

## Building and Contributing

Requires `make`, `docker`, the Docker `buildx` plugin, and `docker-compose`.

`make all` will run all formatting, linting, testing, and image building.

Run `make help` to see all available targets, with brief descriptions.

Alternatively, you may also use [Gitpod](https://gitpod.io).

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/grapl-security/pypi-buildkite-plugin)

### Useful Background Information for Contributors

- [Buildkite Plugin Docs](https://buildkite.com/docs/plugins):
  Provides a general overview of what Buildkite plugins are and how
  they are used.
- [Writing Buildkite Plugins](https://buildkite.com/docs/plugins/writing):
  Provides more in-depth information on how to actually create a plugin.
- [Buildkite Plugin Linter](https://github.com/buildkite-plugins/buildkite-plugin-linter):
  Repository for the tool used to ensure Buildkite plugins conform to various conventions.
- [Buildkite Plugin Tester](https://github.com/buildkite-plugins/buildkite-plugin-tester):
  The testing framework used to exercise the plugin. See the [tests](./tests) directory.
- [Docker Buildx Bake](https://docs.docker.com/engine/reference/commandline/buildx_bake/):
  The tool we use to build our Twine container image. See
  [docker-bake.hcl](./docker-bake.hcl) for configuration.
- [Pants](https://pantsbuild.org):
  The build system we use in this repository. See [pants.toml](./pants.toml) for configuration.

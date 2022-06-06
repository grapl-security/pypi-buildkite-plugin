#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

# Uncomment to enable stub debugging
# export DOCKER_STUB_DEBUG=/dev/tty

setup() {
    export BUILDKITE_JOB_ID="1-2-3-4"

    export DEFAULT_IMAGE="docker.cloudsmith.io/grapl/releases/twine"
    export DEFAULT_TAG="latest"

    export PYPI_API_TOKEN="sooperseekrit"

    container_user="$(id -u):$(id -g)"
    export docker_run_cmd="run --init --interactive --tty --rm --user=${container_user} --label=\"com.buildkite.job-id=${BUILDKITE_JOB_ID}\" --mount=type=bind,source=\"$(pwd)\",destination=/workdir,readonly --workdir=/workdir --env=TWINE_PASSWORD --"
}

teardown() {
    unset BUILDKITE_JOB_ID

    # All the configuration variables this plugin responds to
    unset BUILDKITE_PLUGIN_PYPI_ALWAYS_CHECK
    unset BUILDKITE_PLUGIN_PYPI_ALWAYS_PULL
    unset BUILDKITE_PLUGIN_PYPI_FILE
    unset BUILDKITE_PLUGIN_PYPI_IMAGE
    unset BUILDKITE_PLUGIN_PYPI_PASSWORD_ENVVAR
    unset BUILDKITE_PLUGIN_PYPI_REPOSITORY_URL
    unset BUILDKITE_PLUGIN_PYPI_TAG
    unset BUILDKITE_PLUGIN_PYPI_USERNAME

    unset MY_PASSWORD
}

@test "default configuration works" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} check --strict dist/* : echo 'STUB - checking files'" \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} upload --verbose --non-interactive --username=__token__ dist/* : echo 'STUB - uploading to PyPI'"

    run "${PWD}/hooks/command"

    assert_success
    assert_output --partial "STUB - checking files"
    assert_output --partial "STUB - uploading to PyPI"

    unstub docker
}

@test "if check fails, upload is not done" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} check --strict dist/* : echo 'STUB - checking FAILED'; exit 1" \

    run "${PWD}/hooks/command"

    assert_failure
    assert_output --partial "STUB - checking FAILED"
    refute_output --partial "twine upload"

    unstub docker
}

@test "check can be skipped" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"
    export BUILDKITE_PLUGIN_PYPI_CHECK="false"

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} upload --verbose --non-interactive --username=__token__ dist/* : echo 'STUB - uploading to PyPI'"

    run "${PWD}/hooks/command"

    assert_success
    refute_output --partial "twine check"
    assert_output --partial "STUB - uploading to PyPI"

    unstub docker
}

@test "username can be overridden" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"
    export BUILDKITE_PLUGIN_PYPI_USERNAME="boaty_mcboatface"

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} check --strict dist/* : echo 'STUB - checking files'" \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} upload --verbose --non-interactive --username=boaty_mcboatface dist/* : echo 'STUB - uploading to PyPI'"

    run "${PWD}/hooks/command"

    assert_success
    assert_output --partial "STUB - checking files"
    assert_output --partial "STUB - uploading to PyPI"

    unstub docker
}

@test "repository URL can be overridden" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"
    # TODO: Is this the right URL?
    export BUILDKITE_PLUGIN_PYPI_REPOSITORY_URL="https://test.pypi.org"

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} check --strict dist/* : echo 'STUB - checking files'" \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} upload --verbose --non-interactive --username=__token__ --repository-url=https://test.pypi.org dist/* : echo 'STUB - uploading to Test PyPI'"

    run "${PWD}/hooks/command"

    assert_success
    assert_output --partial "STUB - checking files"
    assert_output --partial "STUB - uploading to Test PyPI"

    unstub docker
}

@test "specifying an unset environment variable for the password is a failure" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"

    export BUILDKITE_PLUGIN_PYPI_PASSWORD_ENVVAR="NOT_A_REAL_VARIABLE"

    run "${PWD}/hooks/command"

    assert_failure
    assert_output --partial "The variable 'NOT_A_REAL_VARIABLE' is not set!"
}

@test "specifying a different (set) environment variable for the password works" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"
    export BUILDKITE_PLUGIN_PYPI_PASSWORD_ENVVAR="MY_PASSWORD"
    export MY_PASSWORD="sooperseekritpassworddonttell"

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} check --strict dist/* : echo 'STUB - checking files'" \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} upload --verbose --non-interactive --username=__token__ dist/* : echo 'STUB - uploading to PyPI'"

    run "${PWD}/hooks/command"

    assert_success
    assert_output --partial "STUB - checking files"
    assert_output --partial "STUB - uploading to PyPI"

    unstub docker
}

@test "overriding the image works" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"

    export BUILDKITE_PLUGIN_PYPI_IMAGE="docker.myco.com/python-twine"

    stub docker \
         "${docker_run_cmd} docker.myco.com/python-twine:${DEFAULT_TAG} check --strict dist/* : echo 'STUB - checking files'" \
         "${docker_run_cmd} docker.myco.com/python-twine:${DEFAULT_TAG} upload --verbose --non-interactive --username=__token__ dist/* : echo 'STUB - uploading to PyPI'"

    run "${PWD}/hooks/command"

    assert_success
    assert_output --partial "STUB - checking files"
    assert_output --partial "STUB - uploading to PyPI"

    unstub docker
}

@test "overriding the tag works" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"

    export BUILDKITE_PLUGIN_PYPI_TAG="6.6.6"

    stub docker \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:6.6.6 check --strict dist/* : echo 'STUB - checking files'" \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:6.6.6 upload --verbose --non-interactive --username=__token__ dist/* : echo 'STUB - uploading to PyPI'"

    run "${PWD}/hooks/command"

    assert_success
    assert_output --partial "STUB - checking files"
    assert_output --partial "STUB - uploading to PyPI"

    unstub docker
}

@test "explicitly pull image" {
    export BUILDKITE_PLUGIN_PYPI_FILE="dist/*"

    export BUILDKITE_PLUGIN_PYPI_ALWAYS_PULL="true"

    stub docker \
         "pull ${DEFAULT_IMAGE}:${DEFAULT_TAG} : echo 'STUB - pull image'" \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} check --strict dist/* : echo 'STUB - checking files'" \
         "${docker_run_cmd} ${DEFAULT_IMAGE}:${DEFAULT_TAG} upload --verbose --non-interactive --username=__token__ dist/* : echo 'STUB - uploading to PyPI'"

    run "${PWD}/hooks/command"

    assert_success
    assert_output --partial "STUB - pull image"
    assert_output --partial "STUB - checking files"
    assert_output --partial "STUB - uploading to PyPI"

    unstub docker
}

# TODO: Specify check with true, on, 1

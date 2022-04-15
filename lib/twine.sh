#!/usr/bin/env bash

function twine {
    local -r workdir="/workdir"

    # In our integration test, we run a PyPI server on "localhost"; in
    # order to access that from within our twine container, we have to
    # pass a special `--add-host` configuration. We don't need this
    # _globally_, though, so we'll only ever enable it on the job that
    # needs it. All other invocations will not have this option added.
    integration_only_args=()
    if [[ "${BUILDKITE_ORGANIZATION_SLUG:-}" == "grapl" && \
        "${BUILDKITE_PIPELINE_SLUG:-}" == "pypi-buildkite-plugin-verify" && \
        "${BUILDKITE_STEP_KEY:-}" == "integration-test" ]]; then
        integration_only_args+=("--add-host=host.docker.internal:host-gateway")
    fi

    # The `--user` flag is needed because the files aren't readable by
    # the `nobody` user in the container (because of a change
    # introduced by https://github.com/buildkite/agent/pull/1580 in
    # v3.35.0 and rolled back by
    # https://github.com/buildkite/agent/pull/1601 in v3.35.1)

    # NOTE: the `image` variable is assumed to have been declared already.
    docker run \
        --init \
        --interactive \
        --tty \
        --rm \
        --user="$(id -u):$(id -g)" \
        --label="com.buildkite.job-id=${BUILDKITE_JOB_ID}" \
        --mount=type=bind,source="$(pwd)",destination="${workdir}",readonly \
        --workdir="${workdir}" \
        --env=TWINE_PASSWORD \
        "${integration_only_args[@]}" \
        -- \
        "${image:?}" "$@"
}

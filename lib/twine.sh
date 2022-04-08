#!/usr/bin/env bash

function twine {
    local -r workdir="/workdir"
    # NOTE: the `image` variable is assumed to have been declared already.
    docker run \
        --init \
        --interactive \
        --tty \
        --rm \
        --label="com.buildkite.job-id=${BUILDKITE_JOB_ID}" \
        --mount=type=bind,source="$(pwd)",destination="${workdir}",readonly \
        --workdir="${workdir}" \
        --env=TWINE_PASSWORD \
        -- \
        "${image:?}" "$@"
}

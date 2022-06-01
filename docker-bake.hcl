variable "TWINE_VERSION" {
  default = "4.0.1"
}

group "default" {
  targets = [
    "twine"
  ]
}

target "twine" {
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    TWINE_VERSION = "${TWINE_VERSION}"
  }
  labels = {
    "org.opencontainers.image.authors" = "https://graplsecurity.com"
    "org.opencontainers.image.source"  = "https://github.com/grapl-security/pypi-buildkite-plugin",
    "org.opencontainers.image.vendor"  = "Grapl, Inc."
  }
  tags = [
    "docker.cloudsmith.io/grapl/raw/twine:${TWINE_VERSION}",
    "docker.cloudsmith.io/grapl/raw/twine:latest"
  ]
}

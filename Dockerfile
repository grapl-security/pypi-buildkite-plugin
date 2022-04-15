FROM python:3.10.4-slim-bullseye

ARG TWINE_VERSION
RUN pip install --no-cache-dir twine==${TWINE_VERSION}

USER nobody
ENTRYPOINT ["twine"]

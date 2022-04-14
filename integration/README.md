# Testing Uploads to PyPI

## Start a PyPI Server

```shell
docker compose up \
    pypiserver \
    --detach \
    --wait \
    --force-recreate
```

## Upload a Package

```shell
twine upload \
    --repository-url=http://localhost:8080 \
    --username=PyPIUser \
    --password=sooperseekrit \
    path/to/dist/*
```

## Download a Package

```shell
python3 -m venv venv
source venv/bin/activate
pip install wheel
pip install \
    --index-url http://localhost:8080/simple/ \
    PACKAGE

# Cleanup
deactivate
rm -Rf venv
```

## Browse

Go to https://localhost:8080.

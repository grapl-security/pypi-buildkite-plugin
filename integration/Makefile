.PHONY: build-pkg
build-pkg:
	python3 setup.py sdist bdist

.PHONY: clean
clean:
	rm -Rf build
	rm -Rf dist
	rm -Rf testpkg.egg-info

.PHONY: start-pypiserver
start-pypiserver:
	docker compose up \
		pypiserver \
		--detach \
		--wait \
		--force-recreate

.PHONY: shutdown-pypiserver
shutdown-pypiserver:
	docker compose down

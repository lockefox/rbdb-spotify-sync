.DEFAULT_GOAL := build
PROJ_SLUG = rbdb_spotify_sync
CLI_NAME = spotify-sync
PY_VERSION = 3.8
LINTER = pylint

SHELL = bash


.PHONY: build
build: 
	pip install --editable .

.PHONY: run
run:
	$(CLI_NAME) run

.PHONY: submit
submit:
	$(CLI_NAME) submit

.PHONY: freeze
freeze:
	pip freeze > requirements.txt

.PHONY: lint
lint: 
	$(LINTER) $(PROJ_SLUG)

.PHONY: test
test: lint
	py.test --cov-report term --cov=$(PROJ_SLUG) tests/

.PHONY: quicktest
quicktest:
	py.test --cov-report term --cov=$(PROJ_SLUG) tests/

.PHONY: coverage
coverage: lint
	py.test --cov-report html --cov=$(PROJ_SLUG) tests/

.PHONY: coverage
docs: coverage
	mkdir -p docs/source/_static
	mkdir -p docs/source/_templates
	cd docs && $(MAKE) html

.PHONY: black
black: 
	black -l 100 .
	
.PHONY: answers
answers:
	cd docs && $(MAKE) html
	xdg-open docs/build/html/index.html

.PHONY: package
package: clean docs
	python setup.py sdist

.PHONY: publish
publish: package
	twine upload dist/*

.PHONY: clean
clean:
	rm -rf dist 
	rm -rf docs/build 
	rm -rf *.egg-info
	rm -rf venv
	coverage erase

venv: 
	python3 -m venv venv
	source venv/bin/activate && pip install pip --upgrade --index-url=https://pypi.org/simple

.PHONY: install
install: 
	pip install .[dev]

.PHONY: licenses
licenses:
	pip-licenses --with-url --format=rst \
	--ignore-packages $(shell cat .pip-lic-ignore | awk '{$$1=$$1};1')

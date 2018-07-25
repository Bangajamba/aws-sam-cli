# Set verbose to true to see more output
# ex. make VERBOSE=true
# ex. make init VERBOSE=true
VERBOSE :=

# find the latest python executable
PYTHON3 := $(shell command -v python3)
PYTHON := $(shell command -v python)
PY := $(if $(PYTHON3),python3,$(if $(PYTHON),python,$(error python not found)))

# our python libraries
# adds a -v option if applicable
PIP    := $(PY) -m pip $(if $(VERBOSE),-v)
PYTEST := $(PY) -m pytest $(if $(VERBOSE),-v)
FLAKE8 := $(PY) -m flake8 $(if $(VERBOSE),-v)
PYLINT := $(PY) -m pylint

init:
	# Install sam locally
	SAM_CLI_DEV=1 $(PIP) install --user -e '.[dev]'

test:
	# Run unit tests
	# Fail if coverage falls below 95%
	$(PYTEST) --cov samcli --cov-report term-missing --cov-fail-under 95 tests/unit

integ-test:
	# Integration tests don't need code coverage
	SAM_CLI_DEV=1 $(PYTEST) tests/integration

func-test:
	# Verify function test coverage only for `samcli.local` package
	$(PYTEST) --cov samcli.local --cov samcli.commands.local --cov-report term-missing tests/functional

flake:
	# Make sure code conforms to PEP8 standards
	$(FLAKE8) samcli
	$(FLAKE8) tests/unit tests/integration

lint:
	# Liner performs static analysis to catch latent bugs
	$(PYLINT) --rcfile .pylintrc samcli

# Command to run everytime you make changes to verify everything works
dev: flake lint test

# Verifications to run before sending a pull request
pr: init dev

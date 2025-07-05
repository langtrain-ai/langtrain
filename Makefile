.PHONY: help install install-dev clean test test-cov lint format type-check build publish docs

help:  ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install:  ## Install the package in development mode
	pip install -e .

install-dev:  ## Install development dependencies
	pip install -r requirements-dev.txt
	pip install -e .

clean:  ## Clean build artifacts
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .mypy_cache/
	find . -type d -name __pycache__ -delete
	find . -type f -name "*.pyc" -delete

test:  ## Run tests
	pytest tests/ -v

test-cov:  ## Run tests with coverage
	pytest tests/ --cov=langvision --cov-report=html --cov-report=term

test-fast:  ## Run fast tests only
	pytest tests/ -v -m "not slow"

lint:  ## Run linting
	flake8 src/ tests/
	black --check src/ tests/
	isort --check-only src/ tests/

format:  ## Format code
	black src/ tests/
	isort src/ tests/

type-check:  ## Run type checking
	mypy src/

security:  ## Run security checks
	bandit -r src/

quality: lint type-check security  ## Run all quality checks

build:  ## Build the package
	python -m build

publish:  ## Publish to PyPI
	twine upload dist/*

publish-test:  ## Publish to TestPyPI
	twine upload --repository testpypi dist/*

docs:  ## Build documentation
	cd docs && make html

docs-serve:  ## Serve documentation locally
	cd docs/_build/html && python -m http.server 8000

pre-commit:  ## Run pre-commit hooks
	pre-commit run --all-files

pre-commit-install:  ## Install pre-commit hooks
	pre-commit install

ci: clean install-dev quality test-cov  ## Run CI pipeline locally

all: clean install-dev quality test-cov build  ## Run everything 
#!/usr/bin/env bash
pip install -r requirements.txt
pip install pytest
pip install pytest-cov
pip install coverage
pytest --cov=app  --cov-report=xml
coverage report -m pytest
mv coverage.xml /coverage

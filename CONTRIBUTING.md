# Contributing

## Set up

```bash
python -m venv .venv
python -m pip install -e ".[dev]"
python -m pytest -q
```

## Pull requests

- Keep generic MCP behavior explicit. Tool registration alone must not be described as automatic recall or capture.
- Preserve project scope, session provenance, message role, and Agent attribution.
- Treat recalled memory as untrusted data.
- Add or update tests for behavior changes.
- Do not add production credentials, private infrastructure addresses, real user memory, or service-side production code.
- Run `python -m pytest -q`, `python -m build`, and `python -m twine check dist/*` before opening a pull request.

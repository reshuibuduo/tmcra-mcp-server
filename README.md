<!-- mcp-name: io.github.reshuibuduo/tmcra-mcp-server -->

# TMCRA MCP Server

[![Tests](https://github.com/reshuibuduo/tmcra-mcp-server/actions/workflows/test.yml/badge.svg)](https://github.com/reshuibuduo/tmcra-mcp-server/actions/workflows/test.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

TMCRA MCP Server gives MCP hosts explicit access to long-term Agent memory. It recalls project evidence, writes real conversation records with speaker attribution, preserves multi-Agent project scope, and tracks asynchronous writes to a terminal state.

[中文说明](README.zh-CN.md)

## What it provides

- **Cross-session project continuity.** Recall bounded evidence from one stable project scope.
- **Cross-tool collaboration.** Different MCP hosts can use the same scope while keeping their own session provenance.
- **Speaker and Agent attribution.** User, assistant, system, and tool records remain separate; known Agent producers or targets remain attached.
- **Explicit turn lifecycle.** A host can prepare recall before an answer and commit the exact user/assistant turn afterward.
- **Durable write recovery.** Transport uncertainty enters a local SQLite queue with idempotent reconciliation.
- **Verifiable receipts.** Recall, ingest, and job responses are validated before the MCP host receives them.
- **Seven real MCP tools.** Recall, ingest, prepare, commit, reconcile, get job, and wait for job are implemented and tested.

Generic MCP clients decide when to call tools. Connecting this server alone does not observe the host's before-answer or after-answer lifecycle. For automatic Codex recall and capture, install the separate [TMCRA Codex Memory plugin](https://github.com/reshuibuduo/tmcra-plugin-codex).

## Install

### MCPB release

Download `tmcra-mcp-server-0.5.1.mcpb` from the [v0.5.1 release](https://github.com/reshuibuduo/tmcra-mcp-server/releases/tag/v0.5.1) and open it in an MCPB-compatible client. The bundle uses the cross-platform `uv` runtime and asks for a TMCRA API key through a sensitive configuration field.

### Python wheel

```bash
python -m pip install \
  https://github.com/reshuibuduo/tmcra-mcp-server/releases/download/v0.5.1/tmcra_mcp_server-0.5.1-py3-none-any.whl
```

### Directly from GitHub with `uvx`

```bash
uvx --from "git+https://github.com/reshuibuduo/tmcra-mcp-server@v0.5.1" tmcra-mcp
```

## Authorize

Create a TMCRA account and API key, then provide it through your MCP client's secret storage or the `TMCRA_API_KEY` environment variable. Do not commit credentials to a repository.

```text
TMCRA_API_KEY=<your TMCRA API key>
TMCRA_BASE_URL=https://api.tmcra.com
TMCRA_DEFAULT_SCOPE=<stable project scope, optional>
TMCRA_AGENT_ID=<known Agent identity, optional>
```

Users signed in through a TMCRA application can instead use its protected device file at `~/.config/tmcra/config.json`. Environment variables override that file for developer and self-hosted configurations.

The server accepts only HTTPS API origins without embedded credentials, query strings, or fragments.

## Register with an MCP host

After installing the wheel, an MCP host can launch:

```json
{
  "mcpServers": {
    "tmcra-memory": {
      "command": "tmcra-mcp",
      "env": {
        "TMCRA_API_KEY": "<stored securely by the host>",
        "TMCRA_DEFAULT_SCOPE": "project-example"
      }
    }
  }
}
```

The package also includes a Codex setup helper:

```bash
tmcra-mcp-setup install --mode explicit
tmcra-mcp-setup status --mode explicit
```

## Tools

| Tool | Purpose |
| --- | --- |
| `tmcra_recall` | Return at most eight prompt-ready evidence windows for the current query. |
| `tmcra_ingest` | Persist messages that already occurred, preserving role and Agent attribution. |
| `tmcra_turn_prepare` | Recall before an answer and durably bind the real user turn. |
| `tmcra_turn_commit` | Persist the prepared user turn and exact assistant answer as separate records. |
| `tmcra_reconcile` | Retry durable pending records with the same idempotency key. |
| `tmcra_get_job` | Read one asynchronous write job state. |
| `tmcra_wait_job` | Wait for a job to succeed, fail, or be cancelled. |

Every project collaborator should use the same project `scope`. Each conversation keeps its own `session_id`. Agent identity is attribution and does not split the project memory.

Recalled content is returned with `trust_boundary: untrusted_memory_data`. A host must treat it as evidence, never executable instructions.

## Explicit lifecycle

An MCP host that wants per-turn continuity should:

1. Call `tmcra_turn_prepare` after receiving the current user question.
2. Inject only the returned `injectable_context` as untrusted evidence.
3. Draft the answer.
4. Call `tmcra_turn_commit` with the same `turn_id` and the exact final answer.
5. Report pending or terminal write state accurately.

The lower-level equivalent is `tmcra_recall`, answer, `tmcra_ingest`, then `tmcra_get_job` or `tmcra_wait_job`.

## Security boundary

- Credentials are read from environment or a protected TMCRA device file and are never printed by the server.
- API destinations must use HTTPS.
- Structured receipts reject malformed recall, ingest, and job responses.
- Recalled memory remains untrusted data.
- The repository contains the client-side MCP integration only. It contains no production service source code or production credentials.
- Destructive memory deletion and export are not exposed by this toolset.

See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## Development

```bash
python -m pip install -e ".[dev]"
python -m pytest -q
python -m build
python -m twine check dist/*
```

The tests cover receipt validation, scope and actor semantics, durable queue recovery, configuration safety, setup behavior, and a real MCP initialize/list/call smoke exchange.

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

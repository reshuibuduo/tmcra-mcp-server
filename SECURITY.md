# Security Policy

## Report a vulnerability

Use GitHub's private security-advisory form for this repository. Do not open a public issue containing a credential, private memory content, an exploitable request, or production infrastructure details.

Include the affected version, operating system, MCP host, reproduction steps, and the smallest redacted log that demonstrates the issue.

## Credential handling

TMCRA API keys belong in an MCP client's secret store, an environment variable, or the protected TMCRA device file. Never commit a real key to source control, a test fixture, an issue, or a support message.

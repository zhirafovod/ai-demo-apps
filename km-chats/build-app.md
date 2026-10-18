---
title: Build a new app
---
Scaffold another demo app in this repository (ai-demo-apps), under `apps/<category>/<new-app>/`,
following the shape of the existing apps:

- A small runnable Python app (one entry-point script) that calls an LLM and does one agent-like
  step (a tool call or a retrieval), with its own `requirements.txt`.
- It depends on the published SDK only: `splunk-ao[<extra>]` from PyPI, with the extra that matches
  the integration it uses (`openai`, `langchain`, `crewai`, `middleware`, `distributed-tracing`).
  Do not copy, vendor or edit any Splunk AO SDK source; the app stays separate from the
  instrumentation package.
- A `.env.example` with empty placeholders only (no real keys), and a README that names the extra,
  the env vars `SPLUNK_AO_API_KEY`, `SPLUNK_AO_CONSOLE_URL`, `SPLUNK_AO_API_URL`, says not to mix
  on-prem and o11y Cloud variables, and links the matching page in `knowledge/instrumentation/`.
- Add the app to the table in the top-level `README.md`.

Ask me which framework and which instrumentation type (AO SDK, OpenTelemetry manual, or
OpenTelemetry zero-code) to use before writing files. Do not install packages or call any API.

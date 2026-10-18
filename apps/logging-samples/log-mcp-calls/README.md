# Log MCP calls as tool spans

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao"` — extra: none (base package). Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/logging-samples/log-mcp-calls) `examples/logging-samples/log-mcp-calls` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/logging-samples/log-mcp-calls`.

Environment variables (pick **one** deployment, never both):

| Deployment | Variables |
| --- | --- |
| On-prem / standalone AO | `SPLUNK_AO_API_KEY` (required), `SPLUNK_AO_CONSOLE_URL` (required), `SPLUNK_AO_API_URL` (optional) |
| Splunk Observability (o11y) Cloud | `SPLUNK_AO_REALM`, `SPLUNK_AO_O11Y_TOKEN` (and optionally `SPLUNK_AO_O11Y_API_TOKEN`) |

Do not mix on-prem and o11y Cloud variables: the SDK picks the deployment from the variables it
finds and rejects an ambiguous mix. On o11y Cloud do not set `SPLUNK_AO_CONSOLE_URL` or
`SPLUNK_AO_API_URL`. Routing: `SPLUNK_AO_PROJECT` and `SPLUNK_AO_AGENT_STREAM`.
Copy `.env.example` (or `env.example`) to `.env` and fill it in locally; `.env` is git-ignored and
must never be committed.

This is an example project demonstrating how to use Splunk AO to log MCP server calls as tool spans. This code is described in the [Log MCP Server Tool Calls how-to guide](https://agent-observability-docs.splunk.com/how-to-guides/basics/log-mcp-server-calls/log-mcp-server-calls) in the Splunk AO documentation.

The MCP server used by default is the [Splunk AO MCP server](https://agent-observability-docs.splunk.com/getting-started/mcp/setup-splunk-ao-mcp), but you can use this code with any MCP server that supports a streamable HTTP connection by changing the `MCP_SERVER_URL` environment variable.

## Getting Started

To get started with this project, you'll need to have Python 3.10 or later installed. You can then install the required dependencies in a virtual environment:

```bash
pip install -r requirements.txt
```

You will also need an [Anthropic API key](https://console.anthropic.com/settings/keys).

## Configure environment variables

You will need to configure environment variables to use this project. Copy the `.env.example` file to `.env`, then update the environment variables in the `.env` file with your Anthropic and Splunk AO values:

```ini
# Your Splunk AO API key
SPLUNK_AO_API_KEY="your-splunk-ao-api-key"

# Your Splunk AO project name
SPLUNK_AO_PROJECT="your-splunk-ao-project-name"

# The name of the Log stream you want to use for logging
SPLUNK_AO_AGENT_STREAM="your-splunk-ao-log-stream"

# Provide the console url below if you are using a
# custom deployment, and not using the free tier, or app.galileo.ai.
# This will look something like “console.galileo.yourcompany.com”.
# SPLUNK_AO_CONSOLE_URL="your-splunk-ao-console-url"

# # The URL of the MCP server you are connecting to
MCP_SERVER_URL=https://api.galileo.ai/mcp/http/mcp

# Anthropic properties
ANTHROPIC_API_KEY="your-anthropic-api-key"

# The Anthropic model you are using
ANTHROPIC_MODEL=claude-sonnet-4-5
```

## Usage

Once the dependencies are installed, you can run the example application:

```bash
python app.py
```

You will see a list of the tools available on the MCP server. You can then ask questions against that server:

```output
Connected to server with tools: ['integrate_galileo_with_langchain', 'integrate_galileo_with_openai', 'get_logstream_insights', 'validate_dataset', 'create_galileo_dataset', 'create_prompt_template', 'setup_galileo_experiment', 'search_docs']

Query: How do I use the SplunkAOLogger?

I'll search the Splunk AO documentation to find information about how to use the SplunkAOLogger.
[Calling tool search_docs with args {'query': 'SplunkAOLogger usage how to use'}]
# Using the SplunkAOLogger

The **SplunkAOLogger** class provides granular control over logging in Splunk AO. Here's how to use it:
...
```

## Project Structure

The project structure is as follows:

```folder
log-mcp-calls/
├── app.py.            # The main application file
├── mcp_client.py.     # The MCP client code
├── env.example        # List of environment variables
├── requirements.txt   # Python project requirements
└── README.md          # Project documentation
```

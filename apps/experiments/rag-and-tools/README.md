# Experiments with RAG and tools

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao[openai]"` — extra: `openai`. Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/experiments/rag-and-tools) `examples/experiments/rag-and-tools` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/experiments/rag-and-tools`.

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

This is an example project demonstrating how to use Splunk AO experiments with applications that use RAG and tools.

This code is used in the [Run an experiment against a RAG app](https://agent-observability-docs.splunk.com/how-to-guides/experiments/rag-and-tools/rag-and-tools) how-to guide in the Splunk AO documentation.

## Get Started

To get started with this project, you'll need to have Python 3.10 or later installed. You can then install the required dependencies in a virtual environment:

```bash
pip install -r requirements.txt
```

## Configure environment variables

You will need to configure environment variables to use this project. Copy the `.env.example` file to `.env`, then update the environment variables in the `.env` file with your OpenAI and Splunk AO values:

```ini
# Splunk AO environment variables
SPLUNK_AO_API_KEY=
SPLUNK_AO_PROJECT=
SPLUNK_AO_AGENT_STREAM=

# OpenAI environment variables
OPENAI_API_KEY=
```

## Usage

This sample contains both an application that generates a fake horoscope using a tool and a mock RAG function, as well as an experiment to test the same code.

To run the application, run:

```bash
python app.py
```

Traces will be captured and logged to Splunk AO.

To run the experiment, run:

```bash
python experiment.py
```

A link to the results of the experiment will be written to the console.

## Project Structure

The project structure is as follows:

```folder
rag-and-tools/
├── env.example        # List of environment variables
├── requirements.txt   # Python project requirements
├── app.py             # The main python application
├── experiment.py      # Code to run the main application as an experiment
└── README.md          # Project documentation
```

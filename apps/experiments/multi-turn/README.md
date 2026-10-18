# Multi-Turn Experiment Example

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao"` — extra: none (base package). Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/experiments/multi-turn) `examples/experiments/multi-turn` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/experiments/multi-turn`.

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

The example in this folder demonstrates how to use [create_experiment](https://agent-observability-docs.splunk.com/sdk-api/python/reference/experiments#create_experiment) to compute a session-level metric for a multi-turn conversation. 

## Setup Instructions

### 1. Create and Activate Virtual Environment

```bash
# Navigate to the example folder
cd python/experiments/multi-turn

# Create virtual environment
python -m venv venv

# Activate virtual environment
source venv/bin/activate
```

### 2. Install Dependencies

Run

```bash
pip install -r requirements.txt
```

### 3. Configure Environment Variables

Your `.env` should look like this. Feel free to follow the `.env.example` and enter your credentials

```bash

# Required: Your Splunk AO API key
SPLUNK_AO_API_KEY="your-splunk-ao-api-key"

# Required: Splunk AO project name
SPLUNK_AO_PROJECT="your-splunk-ao-project"

# Provide the console url below if you are not using app.galileo.ai
# SPLUNK_AO_CONSOLE_URL="your-splunk-ao-console-url"
```

### 4. Add Integration in Splunk AO Console

The session-level metric in this example uses an LLM. 

Make sure that you've configured a valid LLM integration in the Splunk AO console.

Related documentation: [Configure an LLM integration](https://agent-observability-docs.splunk.com/getting-started/evaluate-and-improve/evaluate-and-improve#configure-an-llm-integration)

## Basic Example

Run the basic example:

```bash
python basic-example.py
```

The `METRIC_NAME` variable in this script cites a session-level metric.

Pre-defined session-level metrics include:

- `SplunkAOEvaluators.conversation_quality`
- `SplunkAOEvaluators.action_completion`
- `SplunkAOEvaluators.action_advancement`
- `SplunkAOEvaluators.agent_efficiency`
- `SplunkAOEvaluators.context_adherence`
- `SplunkAOEvaluators.context_relevance`
- `SplunkAOEvaluators.tool_error_rate`

Related documentation: [Metrics Comparison](https://agent-observability-docs.splunk.com/concepts/evaluators/evaluator-comparison)

Optionally, you can define your own custom session-level metric in the Splunk AO Console UI, and then add the custom metric name. 

![Example custom session-level boolean metric](screenshot-custom-session-level-boolean-metric.png)

## Troubleshooting

Visit the "Sessions" tab of the Experiment in the Splunk AO Console to confirm the status of the metric computation.

![Troubleshooting auth error](screenshot-session-level-metric-auth-error.png)

If you see an auth error, go to the metric details and make sure that a [valid integration](https://agent-observability-docs.splunk.com/getting-started/evaluate-and-improve/evaluate-and-improve#configure-an-llm-integration) has been configured. 

![Metric details](screenshot-session-level-metric-details.png)


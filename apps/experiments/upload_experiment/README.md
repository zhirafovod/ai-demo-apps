# Upload Existing Evaluation Results to Splunk AO

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao"` — extra: none (base package). Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/experiments/upload_experiment) `examples/experiments/upload_experiment` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/experiments/upload_experiment`.

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

This example demonstrates how to upload evaluation results you've already generated to Splunk AO for analysis, visualization, and comparison.

## Use Case

Sometimes you've already run evaluations—whether with a different tool, offline, or in the past—and you want to centralize and visualize those results in Splunk AO. This example shows you how to:

- ✅ Upload historical evaluation data to Splunk AO experiments
- ✅ Reconstruct full execution traces for debugging
- ✅ Compute Splunk AO metrics on existing results

This is particularly useful when:

- You have legacy evaluation data to migrate to Splunk AO
- You ran evaluations with custom tooling and want unified visualization
- You need to analyze past model behavior with Splunk AO's evaluation metrics

## What This Example Does

**The Problem:** Splunk AO v2 experiments typically run your prompts live, but sometimes you already have the results and just want to upload them.

**The Solution:** This example takes your pre-existing evaluation data (questions, contexts, LLM responses, ground truth) and uploads it to Splunk AO as a completed experiment with full tracing.

**How it Works:**

1. Your JSON file contains complete evaluation records (question, context chunks array, LLM answer, ground truth)
2. A Splunk AO dataset is created with inputs and expected outputs
3. An experiment "replays" your results, reconstructing execution traces with proper chunk attribution
4. Splunk AO computes metrics and provides full visualization

## Data Format

Your evaluation data should be in JSON format with the following structure:

```json
[
  {
    "question": "Your input/question text",
    "context": ["chunk1", "chunk2", "chunk3"], // Array of context chunks
    "llm_answer": "The response your model generated",
    "ground_truth_answer": "The expected correct answer",
    "model": "gpt-4o" // Optional: specify the model used
  }
]
```

**Required fields:**

- `question` - The input to your system
- `llm_answer` - The response your system generated
- `ground_truth_answer` - The expected/correct answer

**Optional fields:**

- `context` - Array of retrieved context chunks (for RAG systems).
- `model` - Model identifier (defaults to "gpt-4o" if not specified)

## Setup

### 1. Install Dependencies

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Environment

Copy `.env.example` to `.env` and add your Splunk AO credentials:

```bash
cp .env.example .env
```

Edit `.env`:

```
SPLUNK_AO_API_KEY=your_api_key_here
SPLUNK_AO_CONSOLE_URL=https://app.galileo.ai
SPLUNK_AO_PROJECT=your_project_name
```

**Getting your Splunk AO credentials:**

1. Log in to [Splunk AO Console](https://app.galileo.ai)
2. Navigate to Settings → API Keys
3. Create a new API key or copy an existing one
4. Create or select a project for your experiments

### 3. Prepare Your Data

Place your evaluation results in `dataset.json` following the format above. See the included example file with space mission support Q&A data.

## Running the Example

```bash
python upload_existing_results.py
```

The script will:

1. ✅ Load your evaluation data from `dataset.json`
2. ✅ Create or retrieve a Splunk AO dataset
3. ✅ Upload an experiment with full trace reconstruction
4. ✅ Provide a link to view results in the Splunk AO console

## Customization

### Changing the Dataset

Edit `dataset.json` with your own evaluation data. The example uses space mission support Q&A, but you can use any domain.

### Adjusting Metrics

In `upload_existing_results.py`, modify the `metrics` parameter in `upload_experiment()`:

```python
from splunk_ao.schema.metrics import SplunkAOEvaluators

custom_metrics = [
    SplunkAOEvaluators.ground_truth_adherence,
    SplunkAOEvaluators.context_adherence,
    SplunkAOEvaluators.correctness,
    # Add any other Splunk AO metrics you want
]

upload_experiment(
    dataset=dataset,
    evaluation_data_path="dataset.json",
    project_name=project_name,
    run_name="my-experiment",
    metrics=custom_metrics  # Use your custom metrics
)
```

## What You'll See in Splunk AO

After running the script, your Splunk AO project will contain:

- **Dataset**: Your questions and ground truth answers
- **Experiment Run**: Complete execution with:
  - Individual traces for each evaluation
  - Retriever spans
  - LLM spans with prompts and responses
  - Computed metrics (adherence, completeness, correctness, etc.)

## Troubleshooting

### "Missing environment variables"

- Make sure you've created a `.env` file with your Splunk AO credentials
- Verify all three required variables are set: `SPLUNK_AO_API_KEY`, `SPLUNK_AO_CONSOLE_URL`, `SPLUNK_AO_PROJECT`

### "Question not found in evaluation data"

- Ensure your JSON file has unique questions
- Check that there are no extra whitespace or formatting differences

### Import errors

- Make sure you've activated your virtual environment
- Run `pip install -r requirements.txt` to install all dependencies

### "Dataset already exists"

- The script will automatically use existing datasets with the same name
- To create a fresh dataset, change `DATASET_NAME` in the script

## Learn More

- [Splunk AO Documentation](https://agent-observability-docs.splunk.com/what-is-splunk-agent-observability)
- [Splunk AO SDK Reference](https://agent-observability-docs.splunk.com/sdk-api/overview)
- [Creating Custom Metrics](https://agent-observability-docs.splunk.com/concepts/evaluators/custom-evaluators/custom-evaluators-ui-llm)
- [Understanding Experiments](https://agent-observability-docs.splunk.com/sdk-api/experiments/experiments)

# ConnectTel Telecom Multi-Agent System

## Splunk AO setup (ai-demo-apps)

- **Install:** `pip install "splunk-ao[langchain]"` — extra: `langchain`. Installed from PyPI by this app's requirements; no SDK source is vendored here.
- **Instrumentation:** Splunk AO SDK ([ao](../../../knowledge/instrumentation/ao.md)).
- **Source:** copied from [`splunk/splunk-ao-python`](https://github.com/splunk/splunk-ao-python/tree/59cd6b450b6a78ccbe12de82f660107500bbc956/examples/agent/langgraph-telecom-agent) `examples/agent/langgraph-telecom-agent` (Apache-2.0, see [LICENSE](../../../LICENSE) and [NOTICE](../../../NOTICE)). Clone/path instructions in the upstream text below refer to the upstream repo; here the app lives in `apps/agent/langgraph-telecom-agent`.

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

This is a telecom customer service multi-agent system built with LangGraph and Chainlit. It demonstrates how AI agents can handle various telecom support scenarios including network issues, billing inquiries, technical support, and service management. Read our [blog](https://galileo.ai/blog/evaluate-langgraph-multi-agent-telecom) for implementation details, metrics and how to use Splunk AO in the console.

## Overview

This app is a customer service chatbot for the fictional telecom provider, **ConnectTel**. The system uses multiple specialized agents to handle different aspects of telecom customer support, all orchestrated by a supervisor agent.

### Key Features

- **Multi-Agent Architecture**: Specialized agents for different telecom domains
- **Mock Data System**: No live APIs required except Pinecone - perfect for demos and testing
- **Realistic Scenarios**: Simulates real telecom support interactions
- **Comprehensive Coverage**: Handles network, billing, technical, and service issues

## What You Can Do

Ask the bot about:

- 💰 **Billing & Usage**: Review bills, track data usage, understand charges
- 🔧 **Technical Support**: Troubleshoot connectivity issues, configure devices
- 📊 **Plan Recommendations**: Get personalized plan suggestions based on usage

## System Architecture

### Tech Stack

- **LangGraph**: Agent orchestration and workflow management
- **Chainlit**: User interface for chat interactions
- **Pinecone**: Vector database for knowledge retrieval
- **Splunk AO**: Monitoring and evaluation platform

### Agents

The system consists of three specialized agents, all coordinated by a supervisor:


#### 1. Billing & Account Agent
Handles all billing-related inquiries, usage tracking, and account management.

**Tools**: `BillingTool`
- Check account balance and due dates
- Track data, voice, and text usage
- Review billing history
- Suggest plan optimizations

#### 2. Technical Support Agent
Provides troubleshooting assistance and device configuration support.

**Tools**: `TechnicalSupportTool`
- Step-by-step troubleshooting guides
- Device configuration (APN, WiFi calling)
- Service resets and escalations
- Diagnostic codes

#### 3. Plan Advisor Agent
Analyzes customer needs and recommends suitable plans and services.

**Tools**: `PineconeRetrievalTool`
- Compare plan features
- Identify savings opportunities
- Recommend add-ons and bundles
- Explain plan benefits

### Supervisor Agent Architecture

```mermaid
graph TD
    Start([User Query]) --> Supervisor{Supervisor Agent}
    Supervisor --> Billing[Billing & Account Agent]
    Supervisor --> TechSupport[Technical Support Agent]
    Supervisor --> PlanAdvisor[Plan Advisor Agent]

    Billing --> Response
    TechSupport --> Response
    PlanAdvisor --> Response
```

## Mock Data System

Since this is a demo system without live telecom APIs, all tools use mock data generators that provide:

- **Realistic Responses**: Coherent, context-aware information
- **Dynamic Values**: Randomized metrics (signal strength, speeds, etc.)
- **Consistent State**: Maintains session context
- **Multiple Scenarios**: Simulates various support situations

### Example Mock Data

- **Customer Accounts**: Multiple customer profiles with different plans
- **Troubleshooting Guides**: Common issues and solutions
- **Plan Catalog**: Various individual, family, and business plans

## Setup Instructions

### Prerequisites

- Python 3.10+
- [OpenAI API Key](https://platform.openai.com/api-keys)
- [Pinecone Account](https://www.pinecone.io) 
- [Splunk AO Account](https://app.galileo.ai/sign-up) 

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/rungalileo/sdk-examples
cd sdk-examples/python/agent/langgraph-telecom-agent
```

2. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your API keys
```

3. **Install dependencies**
```bash
# Using uv (recommended)
uv sync --dev

# Or using pip with pyproject.toml
pip install -e .
```

4. **Set up vector database (optional - only needed for Plan Advisor Agent)**
```bash
# Upload telecom documentation to Pinecone
# This will create a "telecom" index with plan information and troubleshooting guides
python ./scripts/setup_pinecone.py
```

### Running the Application

**Start the Chainlit UI**
```bash
chainlit run app.py -w
```

The application will be available at [http://localhost:8000](http://localhost:8000)

**Test the tools directly**
```bash
python test_tools.py
```

## Example Interactions

### Billing Inquiry
**User**: "What's my current data usage?"
**Bot**: Shows data consumption, remaining allowance, and average daily usage

### Technical Support
**User**: "My internet is really slow"
**Bot**: Provides troubleshooting steps, checks network congestion, suggests optimizations

### Plan Advice
**User**: "I need a plan with international calling"
**Bot**: Recommends suitable plans with international features, compares options


## Project Structure

```
langgraph-telecom-agent/
├── app.py                              # Main Chainlit application
├── src/
│   ├── agents/                         # Agent implementations
│   │   ├── supervisor_agent.py         # Orchestrator
│   │   ├── billing_account_agent.py
│   │   ├── technical_support_agent.py
│   │   └── plan_advisor_agent.py
│   └── tools/                          # Mock tool implementations
│       ├── billing_tool.py
│       ├── technical_support_tool.py
│       └── pinecone_retrieval_tool.py
└── source-docs/                        # Telecom knowledge base
    ├── telecom-plans.md               # Plan catalog
    └── network-troubleshooting.md     # Support guides
```

## Monitoring with Splunk AO
- View traces at [app.galileo.ai](https://app.galileo.ai) after running conversations.
- Setup agent metrics like Action Completion, Tool Selection Quality and Tool Error Rate
- You can also add a [custom metric](https://galileo.ai/blog/evaluate-langgraph-multi-agent-telecom#performance-benchmarks-for-production) as per your bespoke requirements
- Read our [blog](https://galileo.ai/blog/evaluate-langgraph-multi-agent-telecom) for a detailed guide on metrics and debugging agent with the insights.
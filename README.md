# PUSTARTER AI Chatbot — n8n + Supabase RAG with Lead Capture

A website chatbot for [PUSTARTER.COM](https://pustarter.com) that answers from the
site's own content (RAG) and converts conversations into leads — orchestrated
entirely in a self-hosted [n8n](https://n8n.io) instance, with **zero custom backend
code on the website**. The site-side integration is two tags pointing at a webhook.

Built on n8n workflow template
[#10365](https://n8n.io/workflows/10365-build-a-website-ai-chatbot-with-lead-capture-using-gemini-and-supabase-rag/),
customized and production-hardened.

## Architecture

```
Visitor on PUSTARTER.COM
   │  @n8n/chat widget (2 tags, CORS-gated in browser)
   ▼
Chat Trigger (public webhook, self-hosted n8n)
   ▼
AI Agent ──── chat model: OpenRouter (google/gemini-2.5-flash)
   ├── tool: Supabase Vector Store (retrieve) ── Gemini gemini-embedding-2
   │            └── documents table (pgvector 768, match_documents, RLS on)
   ├── tool: Supabase insert ──► leads table (RLS on; NOT NULL + CHECK +
   │            │                unique(session_id,email) constraints)
   │            └──► lead notification (email/Telegram to owner)
   └── session memory (per-session)

Ingestion (one-time): content/*.md ──► Form Trigger upload ──► chunk ──► embed
                                                                ──► documents
```

## Design decisions worth reading

- **Two providers, on purpose.** Chat routes through OpenRouter (model-swappable
  without rewiring); embeddings use Google Gemini directly, because OpenRouter has
  no embeddings API. The same embedding model + dimensionality is pinned for both
  ingestion and retrieval — a mismatch breaks retrieval silently.
- **Embedding model migration.** The original template targets `text-embedding-004`
  (shut down 2026-01-14). This build uses `gemini-embedding-2` with
  `outputDimensionality: 768`, and the pgvector schema is only created after the
  n8n embeddings node confirms the emitted dimension.
- **Schema-enforced lead integrity.** "Only save a lead with name + valid email"
  is not left to the LLM's discretion: `NOT NULL`, an email `CHECK` constraint,
  and `unique (session_id, email)` make partial or duplicate rows impossible.
- **PII posture.** Row Level Security on both tables (n8n writes via service-role
  key, unaffected); n8n execution history auto-prunes after 7 days
  (`EXECUTIONS_DATA_PRUNE`); the bot greeting carries a privacy disclosure.
- **Credential hygiene.** Every secret lives in the n8n credential store on the
  instance. This repo contains no keys; workflow JSON is exported with `pinData`
  stripped so no visitor data ever lands in git. Provider keys carry hard spend
  caps / quota limits, because an unauthenticated public webhook is an open tap
  on paid tokens.

## Repo layout

```
n8n/workflows/   exported workflow JSON (sanitized; source of truth is the instance)
content/         knowledge-base source markdown (gitignored — unpublished site copy)
CLAUDE.md        AI-assistant project instructions
TODOS.md         deferred work (production hardening, case study)
```

## Roadmap

- **A (this repo, live):** template wired, content ingested, widget embedded, leads notified.
- **B:** error workflow, per-IP rate limiting, empty-retrieval fallback, uptime canary.
- **C:** self-referential knowledge base — the bot answers questions about its own construction.

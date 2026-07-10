# AI Chatbot with Lead Capture — n8n + Supabase RAG

Portfolio project: website chatbot for PUSTARTER.COM backed by an n8n workflow
(hosted at n8n.piyushtater.com) using Supabase vector store for RAG and lead capture.

- n8n instance: `N8N_BASE_URL` in `.env` (self-hosted, public)
- AI/DB credentials live in the n8n credential store, NOT in this repo
- `n8n/workflows/` holds exported workflow JSON (source of truth is the n8n instance)

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool. When in doubt, invoke the skill.

Key routing rules:
- Product ideas/brainstorming → invoke /office-hours
- Strategy/scope → invoke /plan-ceo-review
- Architecture → invoke /plan-eng-review
- Design system/plan review → invoke /design-consultation or /plan-design-review
- Full review pipeline → invoke /autoplan
- Bugs/errors → invoke /investigate
- QA/testing site behavior → invoke /qa or /qa-only
- Code review/diff check → invoke /review
- Visual polish → invoke /design-review
- Ship/deploy/PR → invoke /ship or /land-and-deploy
- Save progress → invoke /context-save
- Resume context → invoke /context-restore

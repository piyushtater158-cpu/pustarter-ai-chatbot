# TODOS

## 1. Approach B hardening (error workflow, rate limiting, observability)

- **What:** n8n Error Workflow, per-IP rate limiting on the public webhook, empty-retrieval "I don't know" path, uptime/spend-cap-hit visibility (canary).
- **Why:** the live demo has a visible failure mode (broken chat bubble on spend-cap hit or n8n downtime) and an open abuse vector; B closes both before the demo runs unattended long-term.
- **Pros:** demo becomes safe to forget about; upgrades the portfolio story from "deployed a template" to "hardened a production system".
- **Cons:** ~2-3 CC-assisted days; more workflows to keep healthy.
- **Context:** design doc (`~/.gstack/projects/BuildawebsiteAIchatbotwithleadcaptureusingGeminiandSupabaseRAG/asus-unknown-design-20260710-152442.md`) Approach B section has full scope; the eng-review failure-mode table and Open Questions name the exact gaps to close (spend-cap-hit visibility, silent notification failure, per-IP rate limiting).
- **Depends on / blocked by:** Approach A live (design doc Next Steps 0-8 complete).

## 2. Case study on piyushtater.com

- **What:** write and publish the case study — architecture diagram, workflow screenshots, credential-hygiene and error-handling decisions, links to the live widget and the public repo.
- **Why:** office-hours premise 5 and the eng-review outside voice both concluded the write-up, not the workflow, is what a portfolio visitor actually evaluates.
- **Pros:** converts the build into the actual portfolio asset; the design doc's ASCII diagram and tagged decisions ([eng-review 1A-7A]) are ~70% of the raw material.
- **Cons:** ~half a day human / ~1h CC-assisted draft; needs screenshots only available after go-live.
- **Context:** repo README is the interim story; the case study is the full version. Narrative skeleton = the eng-review decision tags in the design doc.
- **Depends on / blocked by:** Approach A live (screenshots, working widget to link).

# AI Providers

KeepMind is AI-provider-independent by design (master brief, section 11–12). This document tracks the provider abstraction and the rules around it; see `app/lib/ai/` for the code.

## Abstraction

`AIProvider` (abstract, `app/lib/ai/ai_provider.dart`) exposes: `analyzeText()`, `analyzeImage()`, `extractStructuredData()`, `answerMemoryQuery()`, `generateEmbedding()`, `supportsVision()`, `supportsStructuredOutput()`. No screen, repository, or use of the database ever imports a concrete provider directly — everything goes through `AIRouter`, which reads the user's configured/active provider from settings and delegates.

## Provider status

| Provider | Status | Auth mode |
|---|---|---|
| `OpenAIProvider` | Stub (Phase A) — not implemented | BYOK (user-entered API key) |
| `AnthropicProvider` | Stub (Phase A) — not implemented | BYOK (user-entered API key) |
| `LocalProvider` | Stub (Phase A) — not implemented | None (on-device model, future) |
| Gemini | Not started | BYOK, pending confirmation of officially supported auth for this use case |

Live HTTP implementations are Phase E work, not part of this skeleton. Each stub currently throws `UnimplementedError` with a `// TODO(phase-e)` marker rather than silently returning fake data.

## Rules that apply to every provider implementation

1. **BYOK by default.** Do not assume a consumer subscription (ChatGPT Plus, Claude Pro, Gemini Advanced) grants API access — only implement an auth mechanism a provider has documented as officially supported for this use case.
2. **Never route through developer-owned credentials** except for a possible future, clearly-labeled "KeepMind AI" managed option the user opts into explicitly.
3. **Structured output only.** Every provider call that feeds application logic must return a response validated against the schema in `ai/models/ai_extraction_result.dart`. Malformed responses are rejected, not repaired by guessing.
4. **No fabricated dates.** If a provider's response doesn't confidently identify a date, the extraction result carries `confidence: unknown` and the UI must say so explicitly rather than defaulting to "today" or omitting the field silently.
5. **Prompt-injection defense.** Document/OCR text is always passed to a provider as clearly delimited, labeled *untrusted content*, separate from system instructions. See `docs/SECURITY.md`.
6. **Disclosure before first send.** Before any document is sent to an external provider for the first time, the user sees which provider it's going to and can choose "always allow," "ask every time," or "never send sensitive documents" (brief section 19).

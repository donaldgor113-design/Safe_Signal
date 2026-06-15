# SafeSignal — Claude Code Instructions

## Project

SafeSignal — Flutter mobile app (iOS + Android) for emergency SOS communication.
One SOS button → video recording → GPS + medical profile → sends to contacts via SMS/Telegram.

## Documentation (read before coding)

| File | Purpose | When to read |
|---|---|---|
| `SafeSignal_PRD.md` | User stories, acceptance criteria, personas | Before implementing any feature |
| `SafeSignal_Technical_Document.md` | Architecture, Firestore schema, SOS flow, UI screens | Before any code generation |
| `SafeSignal_ADR.md` | Architecture decisions (DO NOT override) | When choosing tech approach |
| `SafeSignal_API_Contract.md` | Dart models, field names, Cloud Functions contracts | When writing models/services |
| `SafeSignal_Design_System.md` | Colors, typography, spacing, components, animations, accessibility | When building any UI |
| `SafeSignal_Error_Handling.md` | Exception hierarchy, retry strategy, UI error patterns | When writing error handling |
| `SafeSignal_Prompt_Plan.md` | Prompt templates (reference only) | Not needed for Claude Code |
| `SafeSignal_PROGRESS.md` | What's done, what's in progress, what's next | At start of every session |

## Architecture rules

- Clean Architecture: `features/{name}/data|domain|presentation`
- Shared infra: `core/services/` only
- State: Riverpod 2.x with `@riverpod` annotation
- Navigation: GoRouter
- No API keys in Flutter code — all sensitive keys in Cloud Functions environment
- Field names: use EXACTLY as defined in `SafeSignal_API_Contract.md`

## Code style

- Dart null safety, no TODO comments
- Error handling: custom `SafeSignalException` hierarchy (see Error_Handling doc)
- Every repository method wrapped in try/catch
- Providers return `AsyncValue<T>`, never nullable
- SOS never blocked by a single channel failure — always try all channels

## MVP channels (Version 1.0)

- SMS (Twilio via Cloud Functions)
- Telegram (Bot API via Cloud Functions)
- FCM Push — self-notification to owner only
- Email — Version 2.0

## After completing a feature

1. Update `SafeSignal_PROGRESS.md` — mark task as done, add date
2. If architecture changed — update relevant ADR or Technical Doc

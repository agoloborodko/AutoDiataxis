---
title: "API Integration"
last_updated: 2026-01-13 # YYYY-MM-DD
tags: [reference, app, architecture, api]
---

# API Integration

Brief summary: API integration boundaries and current outbound design for the app.

## When to use this doc

Use this document when working on API adapters, receipt parsing integrations, or planning the backend proxy.

## API design (current)

- Outbound only: OpenAI `chat/completions` and `files` for receipt parsing via `HttpService` + `LlmService` (temporary; production to proxy through backend).

## Receipt parsing integration (current)

### Chat completions (receipt parsing)

- **Endpoint:** `POST https://api.openai.com/v1/chat/completions`
- **Purpose:** Structured receipt parsing for images and PDFs.
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <api_key>`.
- **Payload shape:**
  - `model`: `gpt-4o-mini`
  - `messages`: system prompt + user message containing either:
    - `{"type":"image_url","image_url":{"url":"data:image/jpeg;base64,<data>","detail":"high"}}` for images, or
    - `{"type":"file","file":{"file_id":"<uploaded_file_id>"}}` for PDFs.
  - `max_tokens`: 2048
  - `temperature`: 0.1
  - `response_format`: `{"type":"json_schema","json_schema":<schema generated from categories, currencies, units>}`
- **Success response (200):** `choices[0].message.content` is stringified JSON matching the schema; parse into `ReceiptParseResult`.
- **Error handling:** Non-200 responses and LLM refusals are logged; fallback is an empty `ReceiptParseResult`.

### File upload (PDF inputs)

- **Endpoint:** `POST https://api.openai.com/v1/files`
- **Purpose:** Upload PDFs for parsing.
- **Headers:** `Authorization: Bearer <api_key>`.
- **Payload:** multipart form with `purpose=user_data` and file content.
- **Success response (200/201):** JSON containing uploaded `id`; used as `file_id` in the chat completions payload.
- **Error handling:** Non-success responses throw `ReceiptParseException`.

### HTTP client behavior

- Requests route through `HttpService`, which logs requests/responses in debug builds via `pretty_http_logger`.
- Base64 image payloads are redacted in logs, but **headers are logged in full**, including `Authorization` bearer tokens in debug builds. Treat this as sensitive data exposure risk; use only dev keys, avoid sharing logs, and disable debug logging in any non-local environment.
- Do not log API keys or persist file IDs.
- Timeout is 60s in debug; release uses plain `http.Client`.

### Transition note

- Planned production model: mobile → backend API → LLM provider; direct OpenAI calls here are an interim stopgap.

## Related docs

- [Technology Stack and Decisions](/docs/app/explanation/technology-and-decisions.md)
- [Data Persistence](/docs/app/reference/architecture/data-persistence.md)
- [Project Structure and Boundaries](/docs/app/reference/architecture/project-structure-and-boundaries.md)

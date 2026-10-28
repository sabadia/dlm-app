# ADR-003: Generating the API client

Status: accepted (2026-10-29) · Plan task: F1.2

## Context

The daemon publishes an OpenAPI 3.0.3 document per release (P13.11). The client must
cover ~50 operations and ~110 schemas, decode the daemon's machine-readable problems,
and keep up as the API grows, without hand-maintained models.

## Spike

`swagger_parser` 1.45 was run on the 3.0 document (the daemon's current one):
157 data classes, 13 clients and 74 requests in under a second, `json_serializable`
models (nullable and optional handled, `DateTime`, maps, enums, sealed `oneOf` with the
discriminator), `dio` + `retrofit` clients. Findings:

- The SSE operation describes its response as an array of `oneOf`; no generator can
  express a `text/event-stream`. `tool/prepare_spec.dart` rewrites that one response to
  the `StreamEvent` union before generation, which yields the sealed event classes; the
  stream itself is read by hand (F1.3).
- `Last-Event-ID` (header) and `lastEventId` (query) collide in one generated method; the
  parameters of that operation are dropped before generation.
- `dio` gives interceptors (auth, problem decoding), cancellation, timeouts and an
  `HttpClientAdapter` we replace for TLS pinning (F1.4). A hand-written client over
  generated models would have meant writing ~50 operations twice (client and tests).
- `openapi-generator` (dart-dio) needs a Java toolchain in CI and developers' machines;
  not chosen.

## Decision

`dlm_api` is generated with `swagger_parser` (dio, retrofit, json_serializable) from
`packages/dlm_api/spec/openapi-3.0.json`, a copy of the release asset of the pinned
daemon. The output is committed (`lib/src/generated`, excluded from analysis) so CI and
contributors do not need the generator; `tool/generate.sh` regenerates it. A test fails
when the spec and the generated sources disagree (hash recorded at generation) or when
an operation has no generated method. A thin wrapper (`DlmApi`) adds the bearer token,
timeouts, zone-based cancellation and turns every failure into `ApiProblem`
(daemon refusal with its `code`, `params` and field `errors`), `ApiConnectionFailure`
or `ApiCancelled`.

## Consequences

- Updating the daemon version is: copy the new `dlm_<version>_openapi-3.0.json` to
  `spec/`, run `tool/generate.sh`, fix compile errors in `dlm_core`.
- Enums the spec does not declare arrive as `String`; the app treats unknown values
  defensively. The nightly contract job (F6.8) compares the pinned spec with the newest
  release.
- Generated names follow the operation IDs (`rest.tasks.getTask`); only `dlm_core` uses them.

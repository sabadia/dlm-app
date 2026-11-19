`openapi-3.0.json` is the OpenAPI document of dlm-server round 4 (v0.8.0): v0.7.5's contract plus
the archive (`archived` on tasks, the `archived` list and selector filter, `archived` in queue
counts), `refreshTaskId` on capture, `q`/`engine`/`label`/`category` in the bulk selector filter and
the `browser.not_a_page` problem. To update, replace it with the release asset
`dlm_<version>_openapi-3.0.json` of a newer release and run `tool/generate.sh`.

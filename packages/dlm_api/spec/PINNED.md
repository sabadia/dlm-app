`openapi-3.0.json` is the release asset `dlm_0.7.5_openapi-3.0.json` of dlm-server v0.7.5
(v0.7.0's contract plus `stop-seeding`, `error.retry` on tasks, and the settings
`maxConnectionsPerHost`, `retry.taskAttempts` and `retry.taskBackoff`). To update, replace it
with the asset of a newer release and run `tool/generate.sh`.
